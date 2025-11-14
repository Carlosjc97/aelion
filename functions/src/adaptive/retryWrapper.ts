import { validateOrThrow } from "./validator";

/** Remove fences, normalise quotes, and trim down to the likely JSON payload. */
export function coerceJsonCandidate(raw: string): string {
  let current = raw.trim();

  // Drop common markdown fences such as ```json ... ```
  current = current.replace(/^```(?:json)?/i, "").replace(/```$/i, "");

  // Normalise smart quotes into standard ASCII quotes.
  current = current
    .replace(/[\u201C\u201D\u201E\u201F\u2033]/g, '"')
    .replace(/[\u2018\u2019\u2032]/g, "'");

  // Attempt to keep only the main JSON block.
  const braceIndexes = [current.indexOf("{"), current.indexOf("[")].filter((idx) => idx >= 0);
  if (braceIndexes.length) {
    const firstBrace = Math.min(...braceIndexes);
    const lastBrace = Math.max(current.lastIndexOf("}"), current.lastIndexOf("]"));
    if (lastBrace > firstBrace) {
      current = current.slice(firstBrace, lastBrace + 1).trim();
    }
  }

  // Remove dangling commas before closing braces/brackets.
  current = current.replace(/,\s*([}\]])/g, "$1");

  return current;
}

/** Attempt JSON.parse directly, then after coercion. */
export function safeJsonParse(raw: string): unknown {
  try {
    return JSON.parse(raw);
  } catch {
    const cleaned = coerceJsonCandidate(raw);
    return JSON.parse(cleaned);
  }
}

/** Build a follow-up prompt instructing the model to repair its JSON. */
export function buildRepairPrompt(schemaId: string, ajvErrorMessage: string): string {
  return [
    `Tu salida NO cumple el esquema ${schemaId}.`,
    "Requisitos:",
    "1) Devuelve SOLO JSON válido (sin comentarios ni markdown).",
    "2) Ajusta claves, tipos y longitudes según el esquema.",
    "3) No agregues texto fuera del JSON.",
    `Errores AJV: ${ajvErrorMessage}`,
  ].join("\n");
}

// Interface expected by the retry helper. Matches the shape returned by OpenAI's chat completions.
export interface ModelCaller {
  (args: {
    system: string;
    user: string;
    model: string;
    temperature?: number;
    max_tokens?: number;
    response_format?: unknown;
  }): Promise<string>;
}

/**
 * Call the model, parse the response, validate against schema, and retry with repair prompts on failure.
 * maxRetries includes the initial attempt (e.g. 3 = 1 initial + 2 retries).
 */
export async function generateWithSchema<T = unknown>(
  callModel: ModelCaller,
  params: {
    system: string;
    user: string;
    model: string;
    temperature?: number;
    max_tokens?: number;
    response_format?: unknown;
  },
  schemaId: string,
  maxRetries = 3,
): Promise<T> {
  let lastError: unknown;
  const baseUser = params.user;
  let currentParams = { ...params };

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    const raw = await callModel(currentParams);

    let parsed: unknown;
    try {
      parsed = safeJsonParse(raw);
    } catch (parseError) {
      lastError = new Error(`JSON parse failed (attempt ${attempt}): ${(parseError as Error).message}`);
      if (attempt < maxRetries) {
        const repair = buildRepairPrompt(schemaId, (lastError as Error).message);
        currentParams = { ...currentParams, user: `${baseUser}\n\n${repair}` };
        continue;
      }
      throw lastError;
    }

    try {
      return validateOrThrow<T>(schemaId, parsed);
    } catch (validationError) {
      lastError = validationError;
      if (attempt < maxRetries) {
        const repair = buildRepairPrompt(schemaId, (validationError as Error).message);
        currentParams = { ...currentParams, user: `${baseUser}\n\n${repair}` };
        continue;
      }
      throw lastError;
    }
  }

  throw lastError ?? new Error("Unknown generation error");
}

/** Convenience helper: invoke the model with prompts and return validated JSON. */
export async function generateJson<T = unknown>(
  callModel: ModelCaller,
  schemaId: string,
  system: string,
  user: string,
  model = "gpt-4o",
  temperature = 0.6,
  max_tokens = 3200,
  response_format?: unknown,
  maxRetries = 3,
): Promise<T> {
  return generateWithSchema<T>(
    callModel,
    { system, user, model, temperature, max_tokens, response_format },
    schemaId,
    maxRetries,
  );
}
