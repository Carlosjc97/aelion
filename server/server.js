// server.js
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
  try { return JSON.parse(text); } catch { return fallback; }
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

// ---- Outline (opcional, por si luego lo quieres usar directo)
app.post("/outline", async (req, res) => {
  try {
    const { topic = "Curso" } = req.body || {};
    if (!OPENAI_API_KEY) return res.status(500).json({ error: "Falta OPENAI_API_KEY en .env" });

    const messages = [
      { role: "system", content: "Responde SOLO JSON válido." },
      {
        role: "user",
        content: `
Devuelve SOLO JSON con este shape:
{
  "courseId": "string",
  "title": "string",
  "completed": false,
  "modules": [
    {
      "id": "m1",
      "title": "string",
      "locked": false,
      "lessons": [
        { "id": "l1", "title": "string", "content": "string", "locked": false, "status": "todo" }
      ]
    }
  ]
}
Reglas:
- Al menos 2 módulos, 3–4 lecciones cada uno.
- Solo la primera lección del primer módulo desbloqueada; el resto locked=true.
Tema: ${topic}
        `.trim()
      }
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
    const json = safeParse(raw, { error: "bad_json", raw });
    res.json(json);
  } catch (e) {
    console.error("[/outline]", e);
    res.status(500).json({ error: "server_error" });
  }
});

app.listen(PORT, () => {
  console.log(`[server] listening on http://localhost:${PORT}`);
});
