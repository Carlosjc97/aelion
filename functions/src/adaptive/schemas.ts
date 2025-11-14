// JSON Schemas for adaptive generation (AJV v8+)
// $id values are used for validator lookup as well as OpenAI structured outputs.

export const CalibrationQuizSchema = {
  $id: "https://aelion.ai/schemas/CalibrationQuiz.json",
  type: "object",
  additionalProperties: false,
  required: ["topic", "language", "questions"],
  properties: {
    topic: { type: "string", minLength: 1, maxLength: 200 },
    language: { type: "string", minLength: 2, maxLength: 16 },
    questions: {
      type: "array",
      minItems: 10,
      maxItems: 10,
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "id",
          "stem",
          "options",
          "correct",
          "difficulty",
          "skillTag",
          "explanation",
          "motivation",
        ],
        properties: {
          id: { type: "string", minLength: 1, maxLength: 24 },
          stem: { type: "string", minLength: 1, maxLength: 240 },
          options: {
            type: "object",
            additionalProperties: false,
            required: ["A", "B", "C", "D"],
            properties: {
              A: { type: "string", minLength: 1, maxLength: 240 },
              B: { type: "string", minLength: 1, maxLength: 240 },
              C: { type: "string", minLength: 1, maxLength: 240 },
              D: { type: "string", minLength: 1, maxLength: 240 },
            },
          },
          correct: { type: "string", enum: ["A", "B", "C", "D"] },
          difficulty: { type: "string", enum: ["easy", "medium", "hard"] },
          skillTag: { type: "string", minLength: 1, maxLength: 60 },
          explanation: { type: "string", minLength: 1, maxLength: 240 },
          motivation: { type: "string", minLength: 1, maxLength: 80 },
        },
      },
    },
  },
} as const;

export const AdaptivePlanDraftSchema = {
  $id: "https://aelion.ai/schemas/AdaptivePlanDraft.json",
  type: "object",
  additionalProperties: false,
  required: ["suggestedModules", "skillCatalog", "notes"],
  properties: {
    suggestedModules: {
      type: "array",
      minItems: 412,
      maxItems: 412,
      items: {
        type: "object",
        additionalProperties: false,
        required: ["moduleNumber", "title", "skills", "objective"],
        properties: {
          moduleNumber: { type: "integer", minimum: 1 },
          title: { type: "string", minLength: 1, maxLength: 120 },
          skills: {
            type: "array",
            minItems: 1,
            maxItems: 6,
            items: { type: "string", minLength: 1, maxLength: 60 },
          },
          objective: { type: "string", minLength: 1, maxLength: 200 },
        },
      },
    },
    skillCatalog: {
      type: "array",
      minItems: 2,
      maxItems: 60,
      items: {
        type: "object",
        additionalProperties: false,
        required: ["tag", "desc"],
        properties: {
          tag: { type: "string", minLength: 1, maxLength: 60 },
          desc: { type: "string", minLength: 1, maxLength: 200 },
        },
      },
    },
    notes: { type: "string", minLength: 20, maxLength: 240 },
  },
} as const;

export const ModuleAdaptiveSchema = {
  $id: "https://aelion.ai/schemas/ModuleAdaptive.json",
  type: "object",
  additionalProperties: false,
  required: [
    "moduleNumber",
    "title",
    "durationMinutes",
    "skillsTargeted",
    "lessons",
    "challenge",
    "checkpointBlueprint",
  ],
  properties: {
    moduleNumber: { type: "integer", minimum: 1 },
    title: { type: "string", minLength: 1, maxLength: 120 },
    durationMinutes: { type: "integer", minimum: 25, maximum: 45 },
    skillsTargeted: {
      type: "array",
      minItems: 1,
      maxItems: 6,
      items: { type: "string", minLength: 1, maxLength: 60 },
    },
    lessons: {
      type: "array",
      minItems: 8,
      maxItems: 20,
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "title",
          "hook",
          "lessonType",
          "theory",
          "exampleLATAM",
          "practice",
          "microQuiz",
          "takeaway",
        ],
        properties: {
          title: { type: "string", minLength: 1, maxLength: 120 },
          hook: { type: "string", minLength: 1, maxLength: 140 },
          lessonType: {
            type: "string",
            enum: [
              "welcome_summary",
              "diagnostic_quiz",
              "guided_practice",
              "activity",
              "mini_game",
              "theory_refresh",
              "applied_project",
              "reflection",
            ],
          },
          theory: { type: "string", minLength: 1, maxLength: 1000 },
          exampleGlobal: { type: "string", minLength: 1, maxLength: 400 },
          practice: {
            type: "object",
            additionalProperties: false,
            required: ["prompt", "expected"],
            properties: {
              prompt: { type: "string", minLength: 1, maxLength: 240 },
              expected: { type: "string", minLength: 1, maxLength: 360 },
            },
          },
          microQuiz: {
            type: "array",
            minItems: 2,
            maxItems: 4,
            items: {
              type: "object",
              additionalProperties: false,
              required: ["id", "stem", "options", "correct", "skillTag", "rationale"],
              properties: {
                id: { type: "string", minLength: 1, maxLength: 24 },
                stem: { type: "string", minLength: 1, maxLength: 240 },
                options: {
                  type: "object",
                  additionalProperties: false,
                  required: ["A", "B", "C", "D"],
                  properties: {
                    A: { type: "string", minLength: 1, maxLength: 240 },
                    B: { type: "string", minLength: 1, maxLength: 240 },
                    C: { type: "string", minLength: 1, maxLength: 240 },
                    D: { type: "string", minLength: 1, maxLength: 240 },
                  },
                },
                correct: { type: "string", enum: ["A", "B", "C", "D"] },
                skillTag: { type: "string", minLength: 1, maxLength: 60 },
                rationale: { type: "string", minLength: 1, maxLength: 140 },
              },
            },
          },
          hint: { type: "string", minLength: 0, maxLength: 200 },
          motivation: { type: "string", minLength: 0, maxLength: 140 },
          takeaway: { type: "string", minLength: 1, maxLength: 100 },
        },
      },
    },
    challenge: {
      type: "object",
      additionalProperties: false,
      required: ["desc", "expected", "rubric"],
      properties: {
        desc: { type: "string", minLength: 1, maxLength: 300 },
        expected: { type: "string", minLength: 1, maxLength: 300 },
        rubric: {
          type: "array",
          minItems: 3,
          maxItems: 5,
          items: { type: "string", minLength: 1, maxLength: 140 },
        },
      },
    },
    checkpointBlueprint: {
      type: "object",
      additionalProperties: false,
      required: ["items", "targetReliability"],
      properties: {
        items: {
          type: "array",
          minItems: 5,
          maxItems: 10,
          items: {
            type: "object",
            additionalProperties: false,
            required: ["id", "skillTag", "type"],
            properties: {
              id: { type: "string", minLength: 1, maxLength: 24 },
              skillTag: { type: "string", minLength: 1, maxLength: 60 },
              type: { type: "string", enum: ["mcq"] },
            },
          },
        },
        targetReliability: { type: "string", enum: ["low", "medium", "high"] },
      },
    },
  },
} as const;

export const CheckpointQuizSchema = {
  $id: "https://aelion.ai/schemas/CheckpointQuiz.json",
  type: "object",
  additionalProperties: false,
  required: ["module", "items"],
  properties: {
    module: { type: "integer", minimum: 1 },
    items: {
      type: "array",
      minItems: 5,
      maxItems: 10,
      items: {
        type: "object",
        additionalProperties: false,
        required: ["id", "stem", "options", "correct", "skillTag", "rationale", "difficulty"],
        properties: {
          id: { type: "string", minLength: 1, maxLength: 24 },
          stem: { type: "string", minLength: 1, maxLength: 240 },
          options: {
            type: "object",
            additionalProperties: false,
            required: ["A", "B", "C", "D"],
            properties: {
              A: { type: "string", minLength: 1, maxLength: 240 },
              B: { type: "string", minLength: 1, maxLength: 240 },
              C: { type: "string", minLength: 1, maxLength: 240 },
              D: { type: "string", minLength: 1, maxLength: 240 },
            },
          },
          correct: { type: "string", enum: ["A", "B", "C", "D"] },
          skillTag: { type: "string", minLength: 1, maxLength: 60 },
          rationale: { type: "string", minLength: 1, maxLength: 140 },
          difficulty: { type: "string", enum: ["easy", "medium", "hard"] },
        },
      },
    },
  },
} as const;

export const EvaluationResultSchema = {
  $id: "https://aelion.ai/schemas/EvaluationResult.json",
  type: "object",
  additionalProperties: false,
  required: ["score", "masteryDelta", "updatedMastery", "weakSkills", "recommendation"],
  properties: {
    score: { type: "number", minimum: 0, maximum: 100 },
    masteryDelta: {
      type: "object",
      additionalProperties: { type: "number", minimum: -1, maximum: 1 },
    },
    updatedMastery: {
      type: "object",
      additionalProperties: { type: "number", minimum: 0, maximum: 1 },
    },
    weakSkills: {
      type: "array",
      minItems: 0,
      maxItems: 10,
      items: { type: "string", minLength: 1, maxLength: 60 },
    },
    recommendation: { type: "string", enum: ["advance", "remedial"] },
  },
} as const;

export const RemedialBoosterSchema = {
  $id: "https://aelion.ai/schemas/RemedialBooster.json",
  type: "object",
  additionalProperties: false,
  required: ["boosterFor", "lessons", "microQuiz"],
  properties: {
    boosterFor: {
      type: "array",
      minItems: 1,
      maxItems: 4,
      items: { type: "string", minLength: 1, maxLength: 60 },
    },
    lessons: {
      type: "array",
      minItems: 1,
      maxItems: 2,
      items: {
        type: "object",
        additionalProperties: false,
        required: [
          "title",
          "hook",
          "lessonType",
          "theory",
          "exampleLATAM",
          "practice",
          "microQuiz",
          "takeaway",
        ],
        properties: {
          title: { type: "string", minLength: 1, maxLength: 120 },
          hook: { type: "string", minLength: 1, maxLength: 140 },
          lessonType: {
            type: "string",
            enum: [
              "welcome_summary",
              "diagnostic_quiz",
              "guided_practice",
              "activity",
              "mini_game",
              "theory_refresh",
              "applied_project",
              "reflection",
            ],
          },
          theory: { type: "string", minLength: 1, maxLength: 800 },
          exampleLATAM: { type: "string", minLength: 1, maxLength: 400 },
          practice: {
            type: "object",
            additionalProperties: false,
            required: ["prompt", "expected"],
            properties: {
              prompt: { type: "string", minLength: 1, maxLength: 240 },
              expected: { type: "string", minLength: 1, maxLength: 360 },
            },
          },
          microQuiz: {
            type: "array",
            minItems: 2,
            maxItems: 3,
            items: {
              type: "object",
              additionalProperties: false,
              required: ["id", "stem", "options", "correct", "skillTag", "rationale"],
              properties: {
                id: { type: "string", minLength: 1, maxLength: 24 },
                stem: { type: "string", minLength: 1, maxLength: 240 },
                options: {
                  type: "object",
                  additionalProperties: false,
                  required: ["A", "B", "C", "D"],
                  properties: {
                    A: { type: "string", minLength: 1, maxLength: 240 },
                    B: { type: "string", minLength: 1, maxLength: 240 },
                    C: { type: "string", minLength: 1, maxLength: 240 },
                    D: { type: "string", minLength: 1, maxLength: 240 },
                  },
                },
                correct: { type: "string", enum: ["A", "B", "C", "D"] },
                skillTag: { type: "string", minLength: 1, maxLength: 60 },
                rationale: { type: "string", minLength: 1, maxLength: 140 },
              },
            },
          },
          takeaway: { type: "string", minLength: 1, maxLength: 100 },
        },
      },
    },
    microQuiz: {
      type: "array",
      minItems: 3,
      maxItems: 4,
      items: {
        type: "object",
        additionalProperties: false,
        required: ["id", "stem", "options", "correct", "skillTag", "rationale"],
        properties: {
          id: { type: "string", minLength: 1, maxLength: 24 },
          stem: { type: "string", minLength: 1, maxLength: 240 },
          options: {
            type: "object",
            additionalProperties: false,
            required: ["A", "B", "C", "D"],
            properties: {
              A: { type: "string", minLength: 1, maxLength: 240 },
              B: { type: "string", minLength: 1, maxLength: 240 },
              C: { type: "string", minLength: 1, maxLength: 240 },
              D: { type: "string", minLength: 1, maxLength: 240 },
            },
          },
          correct: { type: "string", enum: ["A", "B", "C", "D"] },
          skillTag: { type: "string", minLength: 1, maxLength: 60 },
          rationale: { type: "string", minLength: 1, maxLength: 140 },
        },
      },
    },
  },
} as const;

export const ALL_SCHEMAS = [
  CalibrationQuizSchema,
  AdaptivePlanDraftSchema,
  ModuleAdaptiveSchema,
  CheckpointQuizSchema,
  EvaluationResultSchema,
  RemedialBoosterSchema,
];
