import express from "express";
import cors from "cors";
import { getOpenAI } from "./openai.mjs";

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

app.get("/health", (_req, res) => res.json({ ok: true }));

app.post("/outline", async (req, res) => {
  try {
    const { topic } = req.body ?? {};
    if (!topic) return res.status(400).json({ error: "topic requerido" });
    const client = getOpenAI();
    const completion = await client.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are Aelion outline generator." },
        { role: "user", content: `Create a course outline about: ${topic}` }
      ]
    });
    const text = completion.choices?.[0]?.message?.content ?? "";
    res.json({ outline: text });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "outline_failed" });
  }
});

app.post("/quiz", async (req, res) => {
  try {
    const { topic, level = "basic" } = req.body ?? {};
    if (!topic) return res.status(400).json({ error: "topic requerido" });
    const client = getOpenAI();
    const completion = await client.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: "You are Aelion quiz generator." },
        { role: "user", content: `Create a ${level} quiz for: ${topic}` }
      ]
    });
    const text = completion.choices?.[0]?.message?.content ?? "";
    res.json({ quiz: text });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: "quiz_failed" });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Aelion API listening on :${PORT}`));
