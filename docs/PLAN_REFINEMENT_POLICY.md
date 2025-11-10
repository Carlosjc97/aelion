# Plan Refinement Policy

Manual “regenerate plan” actions were removed from the Module Outline screen.
Learners now receive refreshed content only through:

1. The post-quiz `_finalizePlan()` flow, which already merges calibration gaps
   into a new outline.
2. The inline “Refinar plan” bottom sheet, which still allows band/depth
   adjustments or re-running the placement quiz.

This avoids unlimited regeneration loops that inflated OpenAI costs and
introduced conflicting versions of the same outline. If QA needs to force a
refresh for debugging, call the HTTPS endpoint from the CLI (`CourseApiService.generateOutline`)
or clear the cached outline via `LocalOutlineStorage`.
