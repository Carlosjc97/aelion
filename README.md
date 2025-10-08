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

### 1. Configurar Firebase Auth (Google)

Para que el inicio de sesión con Google funcione, necesitas configurar tu proyecto de Firebase:

1.  **Ejecuta `flutterfire configure`**: Sigue los pasos para conectar tu app a Firebase. Esto generará `lib/firebase_options.dart`.
2.  **Configura el `google-services.json`**: Asegúrate de que tu fichero `android/app/google-services.json` contiene la configuración `oauth_client` con `client_type` igual a 3. Esto es necesario para el login de Google en Android. Si no tienes este fichero, descárgalo desde la consola de Firebase.

    ```json
    "oauth_client": [
      {
        "client_id": "TU-WEB-CLIENT-ID.apps.googleusercontent.com",
        "client_type": 3
      }
    ]
    ```

### 2. Backend (Emuladores de Firebase)

La nueva API de `/outline` se ejecuta en Firebase Functions. Para desarrollo local, usamos el emulador de Firebase.

```bash
cd functions
npm install
firebase emulators:start --only functions,firestore,auth
```

El emulador de Functions se ejecutará en `http://localhost:5001` y el de Auth en `http://localhost:9099`.

### 3. App Flutter

1.  **Crea `env.public`**: En la raíz del proyecto, crea un fichero `env.public` con la URL base de tu emulador de functions:

    ```
    # Para emulador local
    API_BASE_URL=http://localhost:5001/<TU_PROJECT_ID>/us-central1
    ```

2.  **Ejecuta la app**:
    ```bash
    flutter pub get
    flutter run -d chrome
    ```

---

## 🚀 Arquitectura de Producción (Firebase)

*   **Firebase Hosting**: Sirve el contenido web estático desde `build/web`.
*   **Firebase Functions**:
    *   `outline`: Nueva función HTTPS que genera el contenido del curso con cache en Firestore y TTL.
*   **App Hosting**: El backend en `server/` se mantiene para desarrollo local o como referencia, pero ya no se usa en producción para el endpoint `/outline`.

### Consumir `/outline` desde Functions

El servicio `CourseApiService` ahora usa la variable `API_BASE_URL` de `env.public` para llamar a la función.

```dart
// lib/services/course_api_service.dart
static Future<Map<String, dynamic>> generateOutline({
  required String topic,
  String depth = 'medium',
}) async {
  // ...
  final response = await http.post(
    _uri('/outline'), // -> https://<region>-<project>.cloudfunctions.net/outline
    // ...
  );
  // ...
}
```

### Skeletons de Carga y Fallback

*   **Skeletons de carga**: La pantalla de `ModuleOutlineView` ahora muestra un esqueleto de la UI mientras se carga el contenido, mejorando la experiencia de usuario.
*   **Modo demo / fallback**: Si el contenido se sirve desde la caché de la función (`source: 'cache'`), se muestra un banner indicando que el contenido puede no ser el más reciente. Si hay un error de red, se muestra un mensaje de error con un botón para reintentar.

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
# URL para producción (ejemplo)
API_BASE_URL=https://us-central1-aelion-c90d2.cloudfunctions.net

# Otras variables
AELION_ENV=production
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