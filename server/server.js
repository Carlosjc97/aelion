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

// Salud
app.get("/health", (_, res) => res.json({ ok: true }));

// POST /quiz  -> {topic} => {questions:[...]}
app.post("/quiz", async (req, res) => {
  try {
    const { topic } = req.body || {};
    if (!topic) return res.status(400).json({ error: "topic requerido" });
    if (!OPENAI_API_KEY) {
      return res.status(500).json({ error: "Falta OPENAI_API_KEY en .env" });
    }

    // Prompt conciso para 5 preguntas nivel básico
    const content = [
      {
        role: "system",
        content:
          "Eres un asistente educativo. Devuelve solo JSON con el formato {questions:[{q, a, b, c, d, correct}]} sin texto extra.",
      },
      {
        role: "user",
        content:
          `Genera 5 preguntas tipo test sobre "${topic}" para principiantes. ` +
          `Cada pregunta con 4 opciones (a,b,c,d) y la clave 'correct' (a|b|c|d).`,
      },
    ];

    // OpenAI responses (chat.completions)
    const resp = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: content,
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
    let parsed;
    try {
      parsed = JSON.parse(raw);
    } catch {
      parsed = { questions: [] };
    }

    // Normalizamos por si falta algo
    const questions = Array.isArray(parsed.questions) ? parsed.questions : [];

    return res.json({ topic, questions });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "server_error" });
  }
});

app.listen(PORT, () =>
  console.log(`[server] listening on http://localhost:${PORT}`)
);
