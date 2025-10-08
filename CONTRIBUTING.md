## 📄 2. `CONTRIBUTING.md`

```markdown
# Contribuir a Aelion

Gracias por querer aportar a Aelion 🚀. Aquí te dejamos las pautas básicas.

---

## 🔀 Flujo de ramas

- `main`: rama estable y protegida.
- `feat/*`: nuevas funcionalidades.
- `fix/*`: correcciones o hotfixes.
- `release/*`: preparación de lanzamientos.

---

## 🧪 Validación antes de PR

1. Ejecuta:
   ```bash
   flutter analyze
   flutter test --reporter expanded
   flutter build web --release
Si modificaste el backend:

bash
Copiar código
npm ci --prefix server
npm run start --prefix server
curl http://localhost:8787/health
Verifica que no subes .env ni secretos:

bash
Copiar código
gitleaks detect --source .
📦 CI/CD
GitHub Actions valida cada PR:

Linter (flutter analyze).

Pruebas (flutter test).

Build web (flutter build web).

Gitleaks.

El merge a main dispara despliegue a Firebase Hosting/Functions.

🏷 Tags y releases
Cada estado estable se etiqueta:

bash
Copiar código
git tag -a vX.Y.Z -m "Descripción"
git push origin vX.Y.Z
Producción se despliega desde tags.

Rollback rápido: git checkout vX.Y.Z.

✅ Buenas prácticas
Commits claros y pequeños (feat:, fix:, chore:).

PRs con checklist de QA (tests, build, endpoints).

Documenta cambios en README.md si afectan configuración.

Usa Secrets Manager en lugar de .env para prod.