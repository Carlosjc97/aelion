import Ajv, { DefinedError } from "ajv";
import addFormats from "ajv-formats";
import { ALL_SCHEMAS } from "./schemas";

let ajvInstance: Ajv | null = null;

function getAjv(): Ajv {
  if (ajvInstance) {
    return ajvInstance;
  }

  const instance = new Ajv({
    strict: true,
    allErrors: true,
    removeAdditional: false,
    coerceTypes: false,
  });
  addFormats(instance);

  for (const schema of ALL_SCHEMAS) {
    instance.addSchema(schema);
  }

  ajvInstance = instance;
  return instance;
}

function stringifyParams(params: unknown): string {
  if (!params) {
    return "";
  }
  try {
    if (typeof params === "object") {
      return JSON.stringify(params);
    }
    return String(params);
  } catch {
    return "";
  }
}

/** Convert AJV errors into a concise human readable summary. */
export function formatAjvErrors(errors: DefinedError[] | null | undefined): string {
  if (!errors?.length) {
    return "";
  }
  return errors
    .slice(0, 8)
    .map((error) => {
      const path = error.instancePath || "(root)";
      const message = error.message || "invalid";
      const extras =
        error.params && Object.keys(error.params).length ? stringifyParams(error.params) : "";
      return `${path} ${message} ${extras}`.trim();
    })
    .join("; ");
}

/** Validate data against a schema by $id. Throws if validation fails. */
export function validateOrThrow<T = unknown>(schemaId: string, data: unknown): T {
  const ajv = getAjv();
  const validate = ajv.getSchema(schemaId);
  if (!validate) {
    throw new Error(`Schema not found: ${schemaId}`);
  }
  const valid = validate(data);
  if (!valid) {
    const details = formatAjvErrors(validate.errors as DefinedError[]);
    throw new Error(`Schema validation failed for ${schemaId}: ${details}`);
  }
  return data as T;
}

export { getAjv as ajv };
