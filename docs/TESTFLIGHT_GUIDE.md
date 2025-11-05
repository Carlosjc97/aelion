# TestFlight Setup Guide - Aelion MVP

> **Objetivo:** Internal testing con 20 slots antes de beta pública
> **Timeline:** Día -2 (setup) → Día 0 (invitations) → Día 7 (review)

---

## 📱 Pre-requisitos

- [ ] Apple Developer Account activo ($99/year)
- [ ] App registrada en App Store Connect
- [ ] Bundle ID configurado: `com.aelion.app`
- [ ] Xcode 15+ instalado
- [ ] Flutter 3.5+ instalado
- [ ] Firebase configurado (ya está ✅)

---

## 🚀 Paso 1: Configurar App en App Store Connect

### **1.1 Crear App**
1. Ir a [App Store Connect](https://appstoreconnect.apple.com)
2. Click **"Apps"** → **"+"** → **"New App"**
3. Configurar:
   - **Platform:** iOS
   - **Name:** Aelion
   - **Primary Language:** Spanish (Spain)
   - **Bundle ID:** com.aelion.app
   - **SKU:** aelion-ios-2025
   - **User Access:** Full Access

### **1.2 App Information**
```
Name: Aelion
Subtitle: Aprende SQL en 3 semanas
Category: Education
Secondary Category: Productivity

Privacy Policy URL: https://aelion.dev/privacy (crear página simple)
Support URL: https://aelion.dev/support

Description (short):
Plan personalizado para aprender SQL basado en tu nivel. 7 días gratis.

Description (full):
Aelion es tu compañero de aprendizaje SQL con evaluación adaptativa.

✓ Evaluación inicial personaliza tu plan
✓ Algoritmo IRT ajusta dificultad en tiempo real
✓ 100 preguntas SQL para Marketing Analytics
✓ Mock exam de práctica
✓ 7 días gratis sin tarjeta

Freemium model:
- M1 (Fundamentos SELECT): Gratis siempre
- M2-M6: Premium después de 7 días trial
```

---

## 🔨 Paso 2: Build & Archive (Xcode)

### **2.1 Configurar Signing**
1. Abrir proyecto en Xcode:
   ```bash
   cd /c/Dev/aelion/aelion
   flutter build ios --release
   open ios/Runner.xcworkspace
   ```

2. En Xcode:
   - Target **"Runner"** → **"Signing & Capabilities"**
   - Team: Seleccionar tu Apple Developer Team
   - Signing Certificate: Distribution
   - Provisioning Profile: Automatic

### **2.2 Configurar Build Number**
```dart
// pubspec.yaml
version: 1.0.0+1

// Incrementar +1 en cada build:
// 1.0.0+1 → Internal testing
// 1.0.0+2 → Bug fixes
// 1.0.0+3 → ...
```

### **2.3 Archive**
1. Xcode → Menu → **Product** → **Archive**
2. Esperar compilación (~5-10 min)
3. Window → **Organizer** → **Archives**
4. Seleccionar build → **"Distribute App"**

### **2.4 Upload to App Store Connect**
1. Distribute App → **"App Store Connect"**
2. Destination: **"Upload"**
3. Distribution options:
   - ✅ Upload symbols (for Crashlytics)
   - ✅ Manage version and build number
4. Re-sign: **"Automatically manage signing"**
5. Review summary → **"Upload"**
6. Esperar procesamiento (~10-30 min)

---

## 🧪 Paso 3: Configurar Internal Testing

### **3.1 Crear Grupo de Testers**
1. App Store Connect → **"TestFlight"** → **"Internal Testing"**
2. Click **"+"** → **"Add Group"**
3. Nombre: **"MVP Team"**
4. Agregar testers:
   - Click **"+"** → **"Add Testers"**
   - Email: emails@example.com
   - Role: Internal Tester
   - Maximum: 20 personas

### **3.2 Seleccionar Build**
1. Internal Testing → **"MVP Team"**
2. Click **"+"** → Seleccionar build 1.0.0+1
3. **"Test Details"**:
   ```
   What to Test:
   - Complete calibration quiz (10 questions)
   - Verify paywall appears after quiz
   - Try starting trial (7 days free)
   - Access M1 for free
   - Confirm M2-M6 are locked
   - Start trial and verify M2-M6 unlock
   - Complete at least one lesson
   - Report any crashes or bugs

   Feedback:
   - Email: support@aelion.dev
   - Expected: Bugs, UX feedback, feature requests
   ```

4. Enable automatic distribution: **ON**

---

## 📧 Paso 4: Invitar Testers

### **4.1 Email de Invitación (Automático)**
Apple envía email automáticamente con:
- Link de descarga TestFlight app
- Código de invitación
- Instrucciones de instalación

### **4.2 Follow-up Manual (Opcional)**
```
Subject: 🚀 Aelion Beta - Tu acceso TestFlight está listo

Hola [Nombre],

¡Gracias por ayudarme a probar Aelion!

INSTRUCCIONES:
1. Descarga TestFlight app: https://apps.apple.com/us/app/testflight/id899247664
2. Abre el email de invitación de Apple
3. Click "View in TestFlight" o redeem code
4. Instala Aelion
5. Prueba el flujo completo (~10 min)

QUÉ PROBAR:
✓ Calibration quiz (10 preguntas)
✓ Paywall después del quiz
✓ M1 gratis (sin paywall)
✓ M2-M6 bloqueados (con candado)
✓ Trial start → M2-M6 se desbloquean
✓ Completar al menos 1 lección

REPORTAR BUGS:
- Email: support@aelion.dev
- Screenshot si es posible
- Device + iOS version

¡Gracias! 🙏

PD: Feedback brutal es bienvenido. No te preocupes por herir sentimientos 😅
```

---

## 📊 Paso 5: Monitorear Feedback

### **5.1 TestFlight Analytics**
App Store Connect → TestFlight → Analytics

**Métricas disponibles:**
- Invitations sent
- Testers accepted
- Sessions (total)
- Crashes (count)
- Feedback submitted

### **5.2 Crashlytics**
Firebase Console → Crashlytics

**Alertas:**
- Crash-free users: Target ≥ 99%
- Stack traces con líneas de código
- Device distribution

### **5.3 GA4 Events**
Firebase Console → Analytics → DebugView

**Validar eventos:**
```
✓ user_identified
✓ paywall_viewed
✓ trial_start
✓ module_started
✓ module_completed
```

---

## 🐛 Paso 6: Iterar Basado en Feedback

### **6.1 Priorizar Bugs**
**P0 - Blocker (fix en < 24h):**
- App crashea al abrir
- Calibración no completa
- Paywall no aparece
- M1 muestra paywall (debe ser gratis)

**P1 - High (fix en < 3 días):**
- Trial no desbloquea M2-M6
- Progreso no persiste
- Navegación rota

**P2 - Medium (fix en < 1 semana):**
- UI bugs menores
- Loading states faltantes
- Copy typos

**P3 - Low (backlog):**
- Feature requests
- Nice-to-haves
- Optimizaciones

### **6.2 Release New Build**
1. Fix bugs
2. Increment build number: `1.0.0+2`
3. Archive → Upload to App Store Connect
4. TestFlight → Internal Testing → Add build
5. Testers reciben auto-update notification

---

## 🚀 Paso 7: Preparar External Testing (Post-MVP)

**Solo cuando:**
- ✅ Internal testing completo (20+ testers)
- ✅ Crash-free rate ≥ 99%
- ✅ Trial start rate ≥ 6%
- ✅ M1 completion rate ≥ 60%

**Process:**
1. App Store Connect → TestFlight → **"External Testing"**
2. Submit for review (Apple review required, ~24-48h)
3. Create public link (max 10,000 testers)
4. Share link en redes sociales

---

## 📋 Checklist Pre-Launch

**Antes de enviar invitaciones:**

### **Technical**
- [ ] Build compiló sin errores
- [ ] Crashlytics recibiendo crashes (test forzado)
- [ ] GA4 events llegando en DebugView
- [ ] Paywall funciona (post_calibration + module_locked)
- [ ] Trial desbloquea M2-M6
- [ ] M1 accesible sin premium
- [ ] Progreso persiste (close/reopen app)

### **Content**
- [ ] Privacy Policy live
- [ ] Support URL live
- [ ] Landing page deployada
- [ ] Screenshots preparados
- [ ] App icon actualizado

### **Communication**
- [ ] Email template de invitación
- [ ] Script de feedback request
- [ ] Dashboard de tracking (Google Sheets)

---

## 🆘 Troubleshooting

### **"Processing" stuck por > 1 hora**
- Refresh App Store Connect
- Check email de Apple (puede haber error)
- Reupload si es necesario

### **Testers no reciben invitación**
- Check spam folder
- Reenviar: TestFlight → Testers → Resend Invitation
- Verificar email correcto en App Store Connect

### **Crashes no aparecen en Crashlytics**
- Verificar `firebase_crashlytics` en `pubspec.yaml`
- Check `FirebaseCrashlytics.instance.recordFlutterError` en `main.dart`
- Esperar 5-10 min después del crash

### **Build rejected by Apple**
- Review error message en email
- Common issues:
  - Missing privacy policy
  - App uses private APIs
  - Incomplete metadata
- Fix → Resubmit

---

## 📚 Recursos

**Official Docs:**
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)

**Troubleshooting:**
- [Firebase Crashlytics Setup](https://firebase.google.com/docs/crashlytics/get-started?platform=flutter)
- [GA4 for Firebase](https://firebase.google.com/docs/analytics/get-started?platform=flutter)

---

**Última actualización:** 2025-11-04
**Owner:** iOS Team
**Próxima revisión:** Día 7 post-internal testing
