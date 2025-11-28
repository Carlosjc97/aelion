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
- [ ] `applicationId` definido (ej: `com.edaptia.Edaptia`)
- [ ] Signing keys configuradas (keystore)

### Assets
- [ ] 6+ screenshots (phone: 1080x1920 mÃ­nimo)
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500)
- [ ] Short description (80 chars max)
- [ ] Full description (4000 chars max)
- [ ] Privacy Policy URL

---

## 2. Build Release APK/AAB

### OpciÃ³n A: Android App Bundle (AAB) - Recomendado
```bash
# Build release AAB
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

### OpciÃ³n B: APK (para testing local)
```bash
# Build release APK
flutter build apk --release --split-per-abi

# Output location:
# build/app/outputs/apk/release/
```

**Nota:** Play Store requiere AAB para uploads desde Agosto 2021.

---

## 3. Google Play Console - Primera ConfiguraciÃ³n

### 3.1 Crear aplicaciÃ³n
1. Ir a Google Play Console â†’ "Todas las aplicaciones"
2. Click "Crear aplicaciÃ³n"
3. Llenar formulario:
   - Nombre: Edaptia (o Edaptia)
   - Idioma predeterminado: EspaÃ±ol (EspaÃ±a / LatinoamÃ©rica)
   - Tipo: AplicaciÃ³n / Juego
   - Gratis / De pago: Gratis
   - Declaraciones: Aceptar tÃ©rminos

### 3.2 Configurar ficha de Play Store (obligatorio)
**SecciÃ³n "Presencia en Play Store":**

**Detalles de la aplicaciÃ³n:**
- Nombre: Edaptia
- DescripciÃ³n breve (80 chars)
- DescripciÃ³n completa (hasta 4000 chars)
- App icon (512x512)
- Feature graphic (1024x500)

**Capturas de pantalla:**
- TelÃ©fono: 6-8 screenshots (1080x1920 mÃ­nimo)
- Tablet (7" y 10"): Opcional
- Android TV/Wear OS: Opcional

**CategorizaciÃ³n:**
- CategorÃ­a: EducaciÃ³n
- Etiquetas: SQL, Aprendizaje, Marketing, Datos

### 3.3 ClasificaciÃ³n de contenido
1. Ir a "ClasificaciÃ³n de contenido"
2. Completar cuestionario (5 min)
3. Seleccionar:
   - PÃºblico objetivo: 18+
   - Contenido educativo sin violencia/drogas/etc.
4. Enviar para clasificaciÃ³n

### 3.4 PÃºblico objetivo y contenido
1. Ir a "PÃºblico objetivo"
2. Seleccionar: Adultos (18+)
3. Confirmar que no hay anuncios para niÃ±os

### 3.5 PolÃ­tica de privacidad
1. Ir a "PolÃ­tica de privacidad"
2. Agregar URL de tu Privacy Policy
   - Ejemplo: https://tudominio.com/privacy
   - Puede ser pÃ¡gina simple en Firebase Hosting

### 3.6 Seguridad de los datos
1. Ir a "Seguridad de los datos"
2. Completar formulario sobre:
   - Datos que recopilas (email, nombre, progreso)
   - CÃ³mo compartes datos (Firebase)
   - Cifrado en trÃ¡nsito (SÃ­ - HTTPS)
   - OpciÃ³n de eliminar datos (SÃ­/No)

---

## 4. Configurar Internal Testing

### 4.1 Crear Internal Testing Track
1. En Google Play Console â†’ Tu app
2. Ir a "Testing" â†’ "Internal testing"
3. Click "Crear versiÃ³n"

### 4.2 Upload AAB
1. En "Crear versiÃ³n":
   - Upload `app-release.aab`
   - Esperar validaciÃ³n (1-5 min)
2. Revisar warnings (si hay)
3. Agregar notas de versiÃ³n:
   ```
   Primera versiÃ³n MVP:
   - CalibraciÃ³n SQL adaptativa
   - 6 mÃ³dulos de contenido
   - Paywall con trial 7 dÃ­as
   - M1 gratis para todos
   ```

### 4.3 Configurar lista de testers
**OpciÃ³n 1: Lista de emails**
1. Ir a "Internal testing" â†’ "Testers"
2. Click "Crear lista de correos electrÃ³nicos"
3. Nombre: "MVP Testers Wave 1"
4. Agregar emails (uno por lÃ­nea):
   ```
   tester1@gmail.com
   tester2@gmail.com
   ...
   ```
5. Guardar lista

**OpciÃ³n 2: Grupo de Google**
1. Crear Google Group (https://groups.google.com)
2. Agregar miembros al grupo
3. En Play Console: Agregar email del grupo

### 4.4 Publicar en Internal Testing
1. Click "Guardar" â†’ "Revisar versiÃ³n"
2. Verificar que no hay errores bloqueantes
3. Click "Iniciar el lanzamiento para Internal testing"
4. Esperar procesamiento (1-2 horas)

---

## 5. Invitar Testers

### 5.1 Obtener enlace de Internal Testing
1. Ir a "Internal testing" â†’ "Testers"
2. Copiar "Enlace para testers":
   ```
   https://play.google.com/apps/internaltest/[ID]
   ```

### 5.2 Enviar invitaciones
**Template de email:**
```
Asunto: InvitaciÃ³n Beta - Edaptia (Aprende SQL en 3 semanas)

Hola [Nombre],

Â¡EstÃ¡s invitado a probar Edaptia antes del lanzamiento pÃºblico!

Edaptia es una app de aprendizaje adaptativo de SQL diseÃ±ada para marketers
y analistas en LATAM. La app ajusta el contenido a tu nivel y te ayuda a
dominar SQL en 3 semanas.

ðŸ”— Enlace de Internal Testing:
https://play.google.com/apps/internaltest/[ID]

ðŸ“± Instrucciones:
1. Haz click en el enlace desde tu Android
2. Acepta la invitaciÃ³n
3. Instala la app desde Play Store
4. Completa el flujo: CalibraciÃ³n â†’ M1 â†’ Paywall

â° Feedback deseado:
- Â¿Funciona sin crashes?
- Â¿La calibraciÃ³n detecta tu nivel correctamente?
- Â¿El paywall aparece en el momento correcto?
- Â¿AlgÃºn bug o confusiÃ³n?

Responde este email con cualquier feedback. Â¡Gracias!

[Tu nombre]
Equipo Edaptia
```

---

## 6. Monitoreo Post-Upload

### 6.1 EstadÃ­sticas de Internal Testing
En Play Console â†’ "Internal testing" â†’ "EstadÃ­sticas":
- Instalaciones
- Crashes (Crashlytics + Play Console)
- ANRs (Application Not Responding)
- Desinstalaciones

### 6.2 Crashlytics
Firebase Console â†’ Crashlytics:
- Crash-free rate (objetivo: â‰¥ 99%)
- Top crashes (priorizar P0/P1)
- Affected users

### 6.3 Google Analytics 4
Firebase Console â†’ Analytics â†’ Dashboard:
- Usuarios activos
- CalibraciÃ³n completa rate
- Trial start rate (objetivo: â‰¥ 6%)
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
- Play Store generarÃ¡ APKs optimizados automÃ¡ticamente

### Error: "Falta polÃ­tica de privacidad"
- Crear pÃ¡gina simple con Privacy Policy
- Deploy a Firebase Hosting o GitHub Pages
- Agregar URL en Play Console

### Error: "ClasificaciÃ³n de contenido pendiente"
- Esperar 24-48h para revisiÃ³n
- Mientras tanto, Internal Testing sigue funcionando

### Testers no pueden instalar
- Verificar que aceptaron la invitaciÃ³n
- Verificar que usan el email invitado en su dispositivo
- Verificar que la versiÃ³n estÃ¡ "Live" en Internal Testing (no "Draft")

---

## 8. Checklist Pre-Launch

**Antes de subir AAB:**
- [ ] `versionCode` incrementado (ej: 1 â†’ 2)
- [ ] `versionName` actualizado (ej: 1.0.0 â†’ 1.0.1)
- [ ] Tests pasando (`flutter test`)
- [ ] Build AAB sin errores
- [ ] Signing configurado correctamente

**Antes de invitar testers:**
- [ ] VersiÃ³n "Live" en Internal Testing
- [ ] Ficha de Play Store completa (tÃ­tulo, descripciones, screenshots)
- [ ] Privacy Policy URL agregada
- [ ] ClasificaciÃ³n de contenido completada
- [ ] Lista de testers creada (20-30 emails)

**Post-invitaciÃ³n:**
- [ ] Template de email listo
- [ ] Crashlytics monitoreando
- [ ] GA4 dashboard configurado
- [ ] Plan de respuesta a feedback (< 24h)

---

## 9. PrÃ³ximos Pasos

### Wave 1: Internal Testing (DÃ­a -1 a DÃ­a 3)
- 20-30 testers cerrados
- Smoke testing intensivo
- Corregir bugs P0/P1

### Wave 2: Closed Testing (DÃ­a 4-7)
- Mover a "Closed Testing" (hasta 100 testers)
- Expandir lista de emails
- Monitorear mÃ©tricas crÃ­ticas

### Wave 3: Open Testing (Semana 2-3)
- Mover a "Open Testing" (pÃºblico con enlace)
- Compartir en comunidades LATAM
- Target: 500 usuarios

### Production (Mes 2)
- PromociÃ³n a "Production"
- Lanzamiento pÃºblico en Play Store
- Marketing campaigns

---

## MÃ©tricas de Ã‰xito (Primeros 7 dÃ­as)

```
âœ… 100+ usuarios completan calibraciÃ³n
âœ… Trial start rate â‰¥ 6%
âœ… Crash-free rate â‰¥ 99%
âœ… M1 completion rate â‰¥ 60%
âœ… D7 retention â‰¥ 12%
```

---

**Fecha de creaciÃ³n:** 2025-11-04
**PrÃ³xima revisiÃ³n:** Post Wave 1 (DÃ­a 3)

