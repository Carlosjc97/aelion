# Aelion

Aplicación Flutter para explorar planes de estudio generados con IA.

## Requisitos

- Flutter (canal **stable**)
- Node.js 18+
- Cuenta con clave de OpenAI (`OPENAI_API_KEY`)

## Puesta en marcha rápida

1. **Backend**
   ```powershell
   cd server
   npm install
   npm run dev
   ```
   El servidor expone `POST /outline` y `POST /quiz` en `http://localhost:8787` (configurable con `PORT`). Asegúrate de crear un `.env` en `server/` con la variable `OPENAI_API_KEY`.

2. **Configurar la app Flutter**
   Crea un archivo `.env` en la raíz del proyecto Flutter (`aelion/.env`) con la URL LAN del backend para que tu dispositivo físico pueda accederlo, por ejemplo:
   ```env
   API_BASE_URL=http://192.168.0.21:8787
   ```
   > Usa tu IP local: la app leerá `API_BASE_URL` en caliente.

3. **Ejecutar Flutter**
   ```powershell
   flutter pub get
   flutter run
   ```

## Utilidades

- **Probar el endpoint /outline** desde PowerShell:
  ```powershell
  ./scripts/test-outline.ps1 -Topic "Introducción a Flutter" -BaseUrl http://localhost:8787
  ```
  Ajusta `-BaseUrl` a tu IP LAN cuando pruebes desde un dispositivo.

## Notas

- El endpoint `/outline` genera módulos y lecciones reales con `gpt-4o-mini` en formato JSON.
- La app Flutter persiste el progreso y desbloquea lecciones secuenciales en `SharedPreferences`.
- El manifiesto Android ya referencia `android:networkSecurityConfig="@xml/network_security_config"` para permitir HTTP en desarrollo.
