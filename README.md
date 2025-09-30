# Aelion

Aplicación Flutter para explorar planes de estudio generados con IA.

---

## 🚀 Estado del proyecto

- ✅ CI/CD en verde (analyze, tests, build web).
- ✅ Firebase Hosting configurado (`build/web` + rewrites a Functions).
- ✅ App Hosting estable (`apphosting.yaml` corregido con `env.variable`).
- ✅ Google Sign-In funcionando (Web Client ID en `google-services.json`).
- ✅ Outline/Quiz activos.
- 🔒 Punto de rollback seguro: tag `v0.9.0-mvp-ready`.

---

## 📦 Requisitos

- **Flutter** canal stable (3.5+).
- **Node.js** 20 (App Hosting runtime).
- **Firebase CLI**.
- Cuenta con clave de **OpenAI** (`OPENAI_API_KEY` en Secret Manager).

---

## 🛠 Puesta en marcha rápida (desarrollo local)

1. **Backend local**
   ```bash
   cd server
   npm ci
   npm run start   # escucha en http://localhost:8787
👉 crea .env en server/ con:

env
Copiar código
OPENAI_API_KEY=tu_api_key_local
PORT=8787
App Flutter

bash
Copiar código
flutter pub get
flutter run -d chrome --web-renderer html
👉 .env local en la raíz del proyecto:

env
Copiar código
API_BASE_URL=http://192.168.0.21:8787
Endpoints disponibles

POST /outline

POST /quiz

GET /health

🌐 Producción (Firebase)
Hosting: sirve build/web.

Cloud Functions: API bajo /api/*.

App Hosting: backend Node (server/server.js).

firebase.json
json
Copiar código
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      { "source": "/api/**", "function": "api" },
      { "source": "**", "destination": "/index.html" }
    ]
  },
  "functions": { "source": "functions" }
}
apphosting.yaml
yaml
Copiar código
runtime: nodejs20

runConfig:
  entrypoint: node server/server.js

env:
  - variable: OPENAI_API_KEY
    secret: OPENAI_API_KEY
    availability: [RUNTIME]

  - variable: NODE_ENV
    value: production
    availability: [RUNTIME]
env.public
env
Copiar código
AELION_ENV=production
BASE_URL=https://us-east4-aelion-c90d2.cloudfunctions.net/api
CV_STUDIO_API_KEY=changeme
📊 QA y validación
bash
Copiar código
flutter analyze
flutter test --reporter expanded
flutter build web --release
firebase emulators:start --only hosting,functions
Login con Google funciona con el Web Client ID.

Outline y Quiz generan contenido real.

/health responde 200.

📈 Flujo de trabajo
Ramas:

main (protegida).

feat/* (features).

fix/* (hotfixes).

release/* (estabilización).

CI/CD: GitHub Actions (analyze, test, build, gitleaks).

Tags para releases estables:

bash
Copiar código
git tag -a v0.9.0-mvp-ready -m "MVP estable"
git push origin v0.9.0-mvp-ready


🧠 Notas

El endpoint /outline usa gpt-4o-mini.

La app Flutter guarda progreso en SharedPreferences.

Android ya tiene network_security_config para HTTP en dev.

Para rollback: Firebase Console → Hosting → Releases → Rollback o usar el tag en Git.