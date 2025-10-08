## 📄 3. `.github/pull_request_template.md`

```markdown
# 🚀 Pull Request – Aelion

## 📋 Descripción
> Explica brevemente qué hace este PR y por qué es necesario.

---

## ✅ Checklist antes del merge
- [ ] Código pasa `flutter analyze` sin errores.
- [ ] Tests unitarios y de widgets (`flutter test`) en verde.
- [ ] Build web (`flutter build web --release`) exitoso.
- [ ] Si toca backend, endpoints `/health`, `/outline`, `/quiz` probados localmente.
- [ ] No se subieron `.env` ni secretos (gitleaks pasa).
- [ ] Documentación (`README.md`, `CONTRIBUTING.md`) actualizada si aplica.

---

## 🔀 Tipo de cambio
- [ ] 🚀 Feature (nueva funcionalidad)
- [ ] 🐛 Fix (corrección de bug)
- [ ] 🛠 Chore (infraestructura/configuración)
- [ ] 📖 Docs (solo documentación)

---

## 🔎 Evidencia de QA
Adjunta logs, capturas o descripciones de cómo validaste los cambios.

---

## 🏷 Notas adicionales
- Tag sugerido (si es release): `vX.Y.Z`
- Rollback: `git checkout <tag-estable>`