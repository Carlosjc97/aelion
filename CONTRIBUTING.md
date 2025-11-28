## ðŸ“„ 2. `CONTRIBUTING.md`

```markdown
# Contribuir a Edaptia

Gracias por querer aportar a Edaptia ðŸš€. AquÃ­ te dejamos las pautas bÃ¡sicas.

---

## ðŸ”€ Flujo de ramas

- `main`: rama estable y protegida.
- `feat/*`: nuevas funcionalidades.
- `fix/*`: correcciones o hotfixes.
- `release/*`: preparaciÃ³n de lanzamientos.

---

## ðŸ§ª ValidaciÃ³n antes de PR

1. Ejecuta:
   ```bash
   flutter analyze
   flutter test --reporter expanded
   flutter build web --release
Si modificaste el backend:

bash
Copiar cÃ³digo
npm ci --prefix server
npm run start --prefix server
curl http://localhost:8787/health
Verifica que no subes .env ni secretos:

bash
Copiar cÃ³digo
gitleaks detect --source .
ðŸ“¦ CI/CD
GitHub Actions valida cada PR:

Linter (flutter analyze).

Pruebas (flutter test).

Build web (flutter build web).

Gitleaks.

El merge a main dispara despliegue a Firebase Hosting/Functions.

ðŸ· Tags y releases
Cada estado estable se etiqueta:

bash
Copiar cÃ³digo
git tag -a vX.Y.Z -m "DescripciÃ³n"
git push origin vX.Y.Z
ProducciÃ³n se despliega desde tags.

Rollback rÃ¡pido: git checkout vX.Y.Z.

âœ… Buenas prÃ¡cticas
Commits claros y pequeÃ±os (feat:, fix:, chore:).

PRs con checklist de QA (tests, build, endpoints).

Documenta cambios en README.md si afectan configuraciÃ³n.

Usa Secrets Manager en lugar de .env para prod.
