# Play Store Internal Testing - Setup Guide

> **Objetivo:** Subir MVP a Play Store Internal Testing para primeros 20-30 testers

---

## 1. Pre-requisitos

### Google Play Console
- [ ] Cuenta de desarrollador activa ($25 one-time fee)
- [ ] Acceso a Google Play Console: https://play.google.com/console

### App Configuration
- [ ] `android/app/build.gradle` configurado correctamente
- [ ] `versionCode` y `versionName` actualizados
- [ ] `applicationId` definido (ej: `com.edaptia.aelion`)
- [ ] Signing keys configuradas (keystore)

### Assets
- [ ] 6+ screenshots (phone: 1080x1920 mínimo)
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500)
- [ ] Short description (80 chars max)
- [ ] Full description (4000 chars max)
- [ ] Privacy Policy URL

---

## 2. Build Release APK/AAB

### Opción A: Android App Bundle (AAB) - Recomendado
```bash
# Build release AAB
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

### Opción B: APK (para testing local)
```bash
# Build release APK
flutter build apk --release --split-per-abi

# Output location:
# build/app/outputs/apk/release/
```

**Nota:** Play Store requiere AAB para uploads desde Agosto 2021.

---

## 3. Google Play Console - Primera Configuración

### 3.1 Crear aplicación
1. Ir a Google Play Console → "Todas las aplicaciones"
2. Click "Crear aplicación"
3. Llenar formulario:
   - Nombre: Aelion (o Edaptia)
   - Idioma predeterminado: Español (España / Latinoamérica)
   - Tipo: Aplicación / Juego
   - Gratis / De pago: Gratis
   - Declaraciones: Aceptar términos

### 3.2 Configurar ficha de Play Store (obligatorio)
**Sección "Presencia en Play Store":**

**Detalles de la aplicación:**
- Nombre: Aelion
- Descripción breve (80 chars)
- Descripción completa (hasta 4000 chars)
- App icon (512x512)
- Feature graphic (1024x500)

**Capturas de pantalla:**
- Teléfono: 6-8 screenshots (1080x1920 mínimo)
- Tablet (7" y 10"): Opcional
- Android TV/Wear OS: Opcional

**Categorización:**
- Categoría: Educación
- Etiquetas: SQL, Aprendizaje, Marketing, Datos

### 3.3 Clasificación de contenido
1. Ir a "Clasificación de contenido"
2. Completar cuestionario (5 min)
3. Seleccionar:
   - Público objetivo: 18+
   - Contenido educativo sin violencia/drogas/etc.
4. Enviar para clasificación

### 3.4 Público objetivo y contenido
1. Ir a "Público objetivo"
2. Seleccionar: Adultos (18+)
3. Confirmar que no hay anuncios para niños

### 3.5 Política de privacidad
1. Ir a "Política de privacidad"
2. Agregar URL de tu Privacy Policy
   - Ejemplo: https://tudominio.com/privacy
   - Puede ser página simple en Firebase Hosting

### 3.6 Seguridad de los datos
1. Ir a "Seguridad de los datos"
2. Completar formulario sobre:
   - Datos que recopilas (email, nombre, progreso)
   - Cómo compartes datos (Firebase)
   - Cifrado en tránsito (Sí - HTTPS)
   - Opción de eliminar datos (Sí/No)

---

## 4. Configurar Internal Testing

### 4.1 Crear Internal Testing Track
1. En Google Play Console → Tu app
2. Ir a "Testing" → "Internal testing"
3. Click "Crear versión"

### 4.2 Upload AAB
1. En "Crear versión":
   - Upload `app-release.aab`
   - Esperar validación (1-5 min)
2. Revisar warnings (si hay)
3. Agregar notas de versión:
   ```
   Primera versión MVP:
   - Calibración SQL adaptativa
   - 6 módulos de contenido
   - Paywall con trial 7 días
   - M1 gratis para todos
   ```

### 4.3 Configurar lista de testers
**Opción 1: Lista de emails**
1. Ir a "Internal testing" → "Testers"
2. Click "Crear lista de correos electrónicos"
3. Nombre: "MVP Testers Wave 1"
4. Agregar emails (uno por línea):
   ```
   tester1@gmail.com
   tester2@gmail.com
   ...
   ```
5. Guardar lista

**Opción 2: Grupo de Google**
1. Crear Google Group (https://groups.google.com)
2. Agregar miembros al grupo
3. En Play Console: Agregar email del grupo

### 4.4 Publicar en Internal Testing
1. Click "Guardar" → "Revisar versión"
2. Verificar que no hay errores bloqueantes
3. Click "Iniciar el lanzamiento para Internal testing"
4. Esperar procesamiento (1-2 horas)

---

## 5. Invitar Testers

### 5.1 Obtener enlace de Internal Testing
1. Ir a "Internal testing" → "Testers"
2. Copiar "Enlace para testers":
   ```
   https://play.google.com/apps/internaltest/[ID]
   ```

### 5.2 Enviar invitaciones
**Template de email:**
```
Asunto: Invitación Beta - Aelion (Aprende SQL en 3 semanas)

Hola [Nombre],

¡Estás invitado a probar Aelion antes del lanzamiento público!

Aelion es una app de aprendizaje adaptativo de SQL diseñada para marketers
y analistas en LATAM. La app ajusta el contenido a tu nivel y te ayuda a
dominar SQL en 3 semanas.

🔗 Enlace de Internal Testing:
https://play.google.com/apps/internaltest/[ID]

📱 Instrucciones:
1. Haz click en el enlace desde tu Android
2. Acepta la invitación
3. Instala la app desde Play Store
4. Completa el flujo: Calibración → M1 → Paywall

⏰ Feedback deseado:
- ¿Funciona sin crashes?
- ¿La calibración detecta tu nivel correctamente?
- ¿El paywall aparece en el momento correcto?
- ¿Algún bug o confusión?

Responde este email con cualquier feedback. ¡Gracias!

[Tu nombre]
Equipo Edaptia
```

---

## 6. Monitoreo Post-Upload

### 6.1 Estadísticas de Internal Testing
En Play Console → "Internal testing" → "Estadísticas":
- Instalaciones
- Crashes (Crashlytics + Play Console)
- ANRs (Application Not Responding)
- Desinstalaciones

### 6.2 Crashlytics
Firebase Console → Crashlytics:
- Crash-free rate (objetivo: ≥ 99%)
- Top crashes (priorizar P0/P1)
- Affected users

### 6.3 Google Analytics 4
Firebase Console → Analytics → Dashboard:
- Usuarios activos
- Calibración completa rate
- Trial start rate (objetivo: ≥ 6%)
- M1 completion rate

---

## 7. Troubleshooting

### Error: "APK/AAB no firmado"
```bash
# Verificar que tienes keystore configurado en:
# android/app/build.gradle
# android/key.properties

# Si no tienes keystore:
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### Error: "App Bundle no optimizado"
- Esto es un warning, no bloqueante
- Play Store generará APKs optimizados automáticamente

### Error: "Falta política de privacidad"
- Crear página simple con Privacy Policy
- Deploy a Firebase Hosting o GitHub Pages
- Agregar URL en Play Console

### Error: "Clasificación de contenido pendiente"
- Esperar 24-48h para revisión
- Mientras tanto, Internal Testing sigue funcionando

### Testers no pueden instalar
- Verificar que aceptaron la invitación
- Verificar que usan el email invitado en su dispositivo
- Verificar que la versión está "Live" en Internal Testing (no "Draft")

---

## 8. Checklist Pre-Launch

**Antes de subir AAB:**
- [ ] `versionCode` incrementado (ej: 1 → 2)
- [ ] `versionName` actualizado (ej: 1.0.0 → 1.0.1)
- [ ] Tests pasando (`flutter test`)
- [ ] Build AAB sin errores
- [ ] Signing configurado correctamente

**Antes de invitar testers:**
- [ ] Versión "Live" en Internal Testing
- [ ] Ficha de Play Store completa (título, descripciones, screenshots)
- [ ] Privacy Policy URL agregada
- [ ] Clasificación de contenido completada
- [ ] Lista de testers creada (20-30 emails)

**Post-invitación:**
- [ ] Template de email listo
- [ ] Crashlytics monitoreando
- [ ] GA4 dashboard configurado
- [ ] Plan de respuesta a feedback (< 24h)

---

## 9. Próximos Pasos

### Wave 1: Internal Testing (Día -1 a Día 3)
- 20-30 testers cerrados
- Smoke testing intensivo
- Corregir bugs P0/P1

### Wave 2: Closed Testing (Día 4-7)
- Mover a "Closed Testing" (hasta 100 testers)
- Expandir lista de emails
- Monitorear métricas críticas

### Wave 3: Open Testing (Semana 2-3)
- Mover a "Open Testing" (público con enlace)
- Compartir en comunidades LATAM
- Target: 500 usuarios

### Production (Mes 2)
- Promoción a "Production"
- Lanzamiento público en Play Store
- Marketing campaigns

---

## Métricas de Éxito (Primeros 7 días)

```
✅ 100+ usuarios completan calibración
✅ Trial start rate ≥ 6%
✅ Crash-free rate ≥ 99%
✅ M1 completion rate ≥ 60%
✅ D7 retention ≥ 12%
```

---

**Fecha de creación:** 2025-11-04
**Próxima revisión:** Post Wave 1 (Día 3)
