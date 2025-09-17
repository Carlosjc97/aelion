import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import fetch from "node-fetch";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 8787;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

const OAI_URL = "https://api.openai.com/v1/chat/completions";
const OAI_HEADERS = {
  "Content-Type": "application/json",
  Authorization: `Bearer ${OPENAI_API_KEY || ""}`,
};

const safeParse = (text, fallback = {}) => {
  try {
    return JSON.parse(text);
  } catch (err) {
    return fallback;
  }
};

const toString = (value, fallback = "") =>
  typeof value === "string" && value.trim() ? value.trim() : fallback;

const toBoolean = (value, fallback = false) =>
  typeof value === "boolean" ? value : fallback;

const clampStatus = (value) => {
  if (typeof value !== "string") return "todo";
  const lower = value.trim().toLowerCase();
  return ["todo", "in_progress", "done"].includes(lower) ? lower : "todo";
};

const normalizeLesson = (lesson, moduleIndex, lessonIndex) => {
  const idFallback = `lesson-${moduleIndex + 1}-${lessonIndex + 1}`;
  const unlocked = moduleIndex === 0 && lessonIndex === 0;
  const descriptionRaw =
    typeof lesson?.description === "string"
      ? lesson.description
      : typeof lesson?.content === "string"
      ? lesson.content
      : "";

  const normalized = {
    id: toString(lesson?.id, idFallback),
    title: toString(
      lesson?.title,
      `Lección ${moduleIndex + 1}.${lessonIndex + 1}`
    ),
    description: toString(descriptionRaw, ""),
    locked: toBoolean(lesson?.locked, !unlocked),
    status: clampStatus(lesson?.status),
  };

  if (lesson?.premium !== undefined) {
    normalized.premium = toBoolean(lesson.premium, false);
  }

  return normalized;
};

const normalizeModule = (module, index) => {
  const lessons = Array.isArray(module?.lessons) ? module.lessons : [];
  const isFirst = index === 0;
  const normalizedLessons = lessons.map((lesson, i) =>
    normalizeLesson(lesson, index, i)
  );

  if (!normalizedLessons.length) {
    normalizedLessons.push(normalizeLesson({}, index, 0));
  }

  normalizedLessons.forEach((lesson, i) => {
    const unlocked = isFirst && i === 0;
    lesson.locked = unlocked ? false : toBoolean(lesson.locked, true);
    lesson.status = clampStatus(lesson.status);
  });

  return {
    id: toString(module?.id, `module-${index + 1}`),
    title: toString(module?.title, `Módulo ${index + 1}`),
    locked: toBoolean(module?.locked, !isFirst),
    lessons: normalizedLessons,
  };
};

const fallbackOutline = (topic) => {
  const modules = Array.from({ length: 3 }, (_, mIdx) => {
    const lessons = Array.from({ length: 3 }, (_, lIdx) =>
      normalizeLesson({}, mIdx, lIdx)
    );
    return {
      ...normalizeModule({ lessons }, mIdx),
      title: `Módulo ${mIdx + 1}: ${topic}`,
    };
  });

  return {
    topic,
    level: "beginner",
    estimated_hours: modules.length * 3,
    modules,
  };
};

const normalizeOutline = (rawOutline, topic) => {
  if (!rawOutline || typeof rawOutline !== "object") {
    return fallbackOutline(topic);
  }

  const modulesArray = Array.isArray(rawOutline.modules)
    ? rawOutline.modules
    : [];
  const normalizedModules = modulesArray.map((module, index) =>
    normalizeModule(module, index)
  );

  if (!normalizedModules.length) {
    normalizedModules.push(normalizeModule({}, 0));
  }

  normalizedModules.forEach((module, mIdx) => {
    module.locked = mIdx === 0 ? false : toBoolean(module.locked, true);
    module.lessons = module.lessons.map((lesson, lIdx) => {
      const unlocked = mIdx === 0 && lIdx === 0;
      return {
        ...lesson,
        locked: unlocked ? false : toBoolean(lesson.locked, true),
        status: clampStatus(lesson.status),
      };
    });
    if (module.lessons.length && mIdx > 0) {
      module.lessons[0].locked = module.locked;
    }
  });

  const hoursNumber = Number(rawOutline.estimated_hours);
  const estimatedHours = Number.isFinite(hoursNumber) && hoursNumber > 0
    ? hoursNumber
    : normalizedModules.length * 3;

  return {
    topic: toString(rawOutline.topic, topic),
    level: toString(rawOutline.level, "beginner"),
    estimated_hours: estimatedHours,
    modules: normalizedModules,
  };
};

// ---- Health
app.get("/health", (_req, res) => res.json({ ok: true }));

// ---- Quiz: {topic} -> {questions:[{q,a,b,c,d,correct}]}
app.post("/quiz", async (req, res) => {
  try {
    const { topic } = req.body || {};
    if (!topic) return res.status(400).json({ error: "topic requerido" });
    if (!OPENAI_API_KEY) return res.status(500).json({ error: "Falta OPENAI_API_KEY en .env" });

    const messages = [
      {
        role: "system",
        content:
          "Eres un asistente educativo. Devuelve SOLO JSON con el formato {\"questions\":[{\"q\":\"...\",\"a\":\"...\",\"b\":\"...\",\"c\":\"...\",\"d\":\"...\",\"correct\":\"a|b|c|d\"}]}. Sin texto extra.",
      },
      {
        role: "user",
        content:
          `Genera 5 preguntas para principiantes sobre "${topic}". ` +
          `Cada pregunta con 4 opciones (a,b,c,d) y la clave 'correct' (a|b|c|d).`,
      },
    ];

    const resp = await fetch(OAI_URL, {
      method: "POST",
      headers: OAI_HEADERS,
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages,
        temperature: 0.4,
        response_format: { type: "json_object" },
      }),
    });

    if (!resp.ok) {
      const err = await resp.text();
      return res.status(502).json({ error: "OpenAI error", detail: err });
    }

    const data = await resp.json();
    const raw = data.choices?.[0]?.message?.content ?? "{}";
    const parsed = safeParse(raw, { questions: [] });
    const questions = Array.isArray(parsed.questions) ? parsed.questions : [];

    res.json({ topic, questions });
  } catch (e) {
    console.error("[/quiz]", e);
    res.status(500).json({ error: "server_error" });
  }
});

// ---- Outline
app.post("/outline", async (req, res) => {
  try {
    const { topic } = req.body || {};
    if (!topic || typeof topic !== "string" || !topic.trim()) {
      return res.status(400).json({ error: "topic requerido" });
    }
    if (!OPENAI_API_KEY) {
      return res
        .status(500)
        .json({ error: "Falta OPENAI_API_KEY en .env" });
    }

    const trimmedTopic = topic.trim();
    const messages = [
      {
        role: "system",
        content:
          "Eres un asistente educativo que crea planes de estudio prácticos. Responde ÚNICAMENTE con JSON válido en UTF-8.",
      },
      {
        role: "user",
        content: JSON.stringify({
          instruction:
            "Genera un plan de estudio estructurado para la persona que quiere aprender el tema indicado. Usa solo JSON.",
          topic: trimmedTopic,
          schema: {
            topic: "string",
            level: "beginner|intermediate|advanced",
            estimated_hours: "number",
            modules: [
              {
                id: "string",
                title: "string",
                locked: "boolean",
                lessons: [
                  {
                    id: "string",
                    title: "string",
                    description: "string opcional",
                    locked: "boolean",
                    status: "todo|in_progress|done",
                    premium: "boolean opcional",
                  },
                ],
              },
            ],
          },
          rules: [
            "Incluye entre 3 y 5 módulos con 3 a 4 lecciones cada uno",
            "Solo el primer módulo y su primera lección deben estar desbloqueados",
            "El resto de módulos y lecciones deben tener locked=true",
            "Usa títulos accionables y orientados a resultados",
            "La propiedad status debe iniciar en 'todo'",
            "Incluye estimated_hours realista para completar el plan",
          ],
        }),
      },
    ];

    const resp = await fetch(OAI_URL, {
      method: "POST",
      headers: OAI_HEADERS,
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages,
        temperature: 0.3,
        response_format: { type: "json_object" },
      }),
    });

    if (!resp.ok) {
      const err = await resp.text();
      console.error("[/outline] openai", err);
      return res.status(502).json({ error: "openai_error", detail: err });
    }

    const data = await resp.json();
    const rawContent = data.choices?.[0]?.message?.content ?? "{}";
    const parsed = safeParse(rawContent, null);
    const outline = normalizeOutline(parsed, trimmedTopic);

    res.json(outline);
  } catch (e) {
    console.error("[/outline]", e);
    const fallback = normalizeOutline(null, req.body?.topic ?? "Curso");
    res.status(200).json(fallback);
  }
});

app.listen(PORT, () => {
  console.log(`[server] listening on http://localhost:${PORT}`);
});
