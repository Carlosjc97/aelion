# Estrategia Web Launch - edaptia.io

> **Objetivo:** Capturar 50-100 emails pre-launch + lanzar landing page antes de Play Store

---

## ¿Por qué Landing Page Primero?

### Beneficios
1. **Lead generation:** Capturar emails antes de tener app lista
2. **Credibilidad:** edaptia.io > Firebase subdomain
3. **SEO:** Comenzar a rankear para "aprender SQL", "curso SQL", etc.
4. **Multi-canal:** Web → Play Store (mejor funnel que solo app)
5. **Feedback early:** Validar propuesta de valor antes de launch

### Riesgos
- DNS propagation delay (4-24h)
- Mantenimiento adicional (landing + app)
- Posible confusión si messaging no está claro

**Decisión:** ✅ **VALE LA PENA** - El lead gen y credibilidad compensan

---

## Timeline Recomendado

### **DÍA -3 (HOY - 2025-11-06): Web Launch**

**AM (Mañana):**
```bash
# 1. Deploy landing a Firebase Hosting
firebase init hosting  # public: landing
firebase deploy --only hosting

# 2. Configurar DNS en Namecheap
# - Agregar registros A (IPs de Firebase)
# - Agregar CNAME www → edaptia.io
# - Ver: docs/NAMECHEAP_DEPLOYMENT.md
```

**PM (Tarde):**
```
1. Esperar DNS propagation (1-4h)
2. Verificar https://edaptia.io funciona
3. Verificar SSL activo (candado verde)
4. Hacer primera publicación LinkedIn/Twitter
```

**Post en LinkedIn (Día -3):**
```
🚀 Estoy construyendo Edaptia

Aprende SQL en 3 semanas (no 3 meses) con aprendizaje adaptativo.

Landing: edaptia.io

✅ Plan personalizado a tu nivel
✅ 100 preguntas SQL curadas
✅ Enfoque en entrevistas técnicas

Beta Android próximamente. ¿Quién quiere probarlo? 👇
```

**Métricas Día -3:**
- ✅ 50+ visitas landing
- ✅ 10+ emails waitlist
- ✅ 5+ comentarios/reacciones LinkedIn

---

### **DÍA -2 (2025-11-07): Build Play Store**

**AM:**
```bash
# 1. Build release AAB
flutter build appbundle --release

# 2. Upload a Play Store Internal Testing
# - Google Play Console
# - Internal testing track
# - Ver: docs/PLAYSTORE_GUIDE.md
```

**PM:**
```
1. Crear lista de testers (20-30 emails)
2. Obtener link Internal Testing
3. Actualizar landing:
   - Cambiar waitlist form → Play Store link
   - Desplegar: firebase deploy --only hosting
```

**Email a Waitlist (Día -2 tarde):**
```
Asunto: ¡Beta de Edaptia ya disponible! 🚀

Hola [Nombre],

¡La beta de Edaptia ya está lista!

Hace 2 días te registraste en la waitlist. Ahora puedes ser
de los primeros en probar la app.

📱 Descargar Beta (Android):
https://play.google.com/apps/internaltest/[ID]

📋 Qué esperar:
- Calibración SQL (5-10 min)
- Módulo 1 gratis
- Paywall después de calibración

🐛 Reportar bugs:
Reply a este email con cualquier problema que encuentres.

¡Gracias por ser early adopter!

[Tu nombre]
Fundador, Edaptia
```

**Métricas Día -2:**
- ✅ AAB subido a Play Store
- ✅ 50-100 emails en waitlist
- ✅ 20% open rate email
- ✅ 10+ instalaciones

---

### **DÍA -1 (2025-11-08): Internal Testing**

**Todo el día:**
```
1. Monitorear instalaciones Play Store
2. Responder preguntas de testers
3. Revisar Crashlytics cada 4h
4. Fix bugs P0 (si hay)
```

**Métricas Día -1:**
- ✅ 10+ instalaciones
- ✅ 5+ calibraciones completadas
- ✅ Crash-free rate ≥ 95%
- ✅ 0 bugs P0

---

### **DÍA 0 (2025-11-09): Lanzamiento Público**

**AM:**
```
1. Expandir lista de testers (50-100 personas)
2. Post masivo LinkedIn/Twitter
3. Compartir en comunidades LATAM
```

**Post LinkedIn (Día 0):**
```
🚀 Lanzamos Edaptia en Beta (Android)

Después de 5 días construyendo, hoy abrimos la beta.

edaptia.io

¿Qué hace?
→ Aprende SQL en 3 semanas (no 3 meses)
→ Plan adaptado a tu nivel exacto
→ 100 preguntas curadas
→ Mock exam para entrevistas

Beta gratis → edaptia.io

¿Quién se anima? 👇
```

**Comunidades (Día 0):**
- Reddit: r/learnprogramming, r/SQL, r/datascience
- Discord: Tech LATAM communities
- Slack: Data Analytics groups
- Twitter: Hashtags #SQL #LearnToCode

**Métricas Día 0:**
- ✅ 100+ visitas landing
- ✅ 50+ instalaciones
- ✅ 30+ calibraciones completas
- ✅ 3+ trial starts (6%)

---

## Canales de Tráfico

### 1. Orgánico (Gratis) - Prioridad Alta

**LinkedIn (Personal):**
- Frecuencia: 1 post Día -3, 1 post Día 0
- Audiencia: Tu red profesional
- CTA: "Comenta SQL para link"

**Twitter:**
- Frecuencia: 1 thread Día -3, 1 thread Día 0
- Hashtags: #SQL #LearnToCode #DataAnalytics
- CTA: Link directo a edaptia.io

**Reddit:**
- Subreddits: r/learnprogramming, r/SQL, r/datascience
- Formato: "I built..." post honesto
- CTA: "Feedback welcome"

**Discord/Slack (LATAM Tech):**
- Target: Data/Marketing communities
- Formato: Mensaje personalizado, no spam
- CTA: "Busco beta testers"

### 2. SEO (Mediano plazo)

**Keywords Target:**
- "aprender SQL gratis"
- "curso SQL español"
- "SQL para marketing"
- "SQL entrevistas técnicas"

**Estrategia:**
- Landing page optimizada (ya tiene meta tags)
- Content marketing (blog posts próximamente)
- Backlinks de comunidades

### 3. Paid (Opcional - Solo si orgánico < 50 installs)

**Google Ads:**
- Budget: $5-10/día
- Keywords: "aprender SQL", "curso SQL"
- Landing: edaptia.io
- Conversion: Email waitlist o Play Store install

**Reddit Ads:**
- Budget: $5/día
- Subreddits: r/learnprogramming
- CTA: "Free SQL learning app"

---

## Archivos Creados

### Nuevos Documentos
1. **`docs/NAMECHEAP_DEPLOYMENT.md`**
   - Setup Firebase Hosting + Namecheap DNS
   - Troubleshooting DNS propagation
   - SSL verification

2. **`docs/WEB_LAUNCH_STRATEGY.md`** (este archivo)
   - Timeline Día -3 → Día 0
   - Estrategia multi-canal
   - Templates de posts

3. **`landing/index-waitlist.html`**
   - Versión con formulario waitlist
   - GA4 tracking
   - Meta tags OG completos

### Documentos Actualizados
- **`docs/LAUNCH_PLAN.md`**
  - Timeline ajustado (Día -3 agregado)
  - Posts LinkedIn pre-launch y launch
  - Estrategia Play Store (no TestFlight)

---

## Decisiones de Producto

### Landing Page: 2 Versiones

**Versión A: `landing/index.html`** (original)
- CTA: Botón "Empieza gratis" (placeholder)
- Uso: Cuando Play Store esté listo

**Versión B: `landing/index-waitlist.html`** (nueva)
- CTA: Formulario email waitlist
- Uso: Día -3 y Día -2 (pre-launch)
- Switch a Versión A en Día -1

### Branding: Edaptia vs Aelion

**Decisión:** Usar **Edaptia** en landing
- Dominio: edaptia.io (ya comprado)
- App name: Podría seguir siendo "Aelion"
- Marca paraguas: Edaptia (empresa) → Aelion (producto)

### Waitlist Storage

**Opciones:**

1. **LocalStorage** (testing rápido)
   - Pros: Sin backend needed
   - Cons: Se pierde si user borra cache

2. **Google Sheets** (simple)
   - Pros: Sin backend, fácil exportar
   - Cons: Menos profesional
   - Setup: https://github.com/jamiewilson/form-to-google-sheets

3. **Cloud Function + Firestore** (recomendado)
   - Pros: Profesional, escalable
   - Cons: Requiere deploy function
   - Código en `index-waitlist.html` comentado (listo para descomentar)

**Decisión:** Comenzar con **LocalStorage** (testing), migrar a **Cloud Function** antes de Día -3

---

## Métricas de Éxito

### Landing Page (Día -3 → Día 0)

**Tráfico:**
- ✅ 500+ visitas totales
- ✅ 50+ visitas/día después de Día 0
- ✅ Bounce rate < 60%

**Conversión:**
- ✅ 50-100 emails waitlist (Día -3 y -2)
- ✅ 10% conversion rate (visitas → email)
- ✅ 50+ clicks a Play Store link (Día 0)

### Play Store (Día -1 → Día 7)

**Instalaciones:**
- ✅ 10+ instalaciones (Día -1)
- ✅ 50+ instalaciones (Día 0)
- ✅ 100+ instalaciones (Día 7)

**Engagement:**
- ✅ 30+ calibraciones completas
- ✅ 6% trial start rate
- ✅ 60% M1 completion rate

**Calidad:**
- ✅ 99% crash-free rate
- ✅ 4.0+ Play Store rating (si hay reviews)

---

## Próximos Pasos Inmediatos

### HOY (Día -3)

**1. Deploy Firebase Hosting**
```bash
cd /path/to/aelion
firebase init hosting
firebase deploy --only hosting
```

**2. Configurar DNS Namecheap**
- Login Namecheap → edaptia.io → Advanced DNS
- Agregar registros A (Firebase IPs)
- Ver: docs/NAMECHEAP_DEPLOYMENT.md

**3. Verificar Landing**
- Esperar 1-4h propagación
- Abrir https://edaptia.io
- Verificar SSL (candado verde)
- Test formulario waitlist

**4. Primera Publicación**
- Post LinkedIn (template en LAUNCH_PLAN.md)
- Share en tu red personal
- Capturar primeros 10 emails

---

## Preguntas Frecuentes

**P: ¿Usamos index.html o index-waitlist.html?**

R: **index-waitlist.html** para Día -3 y -2. Switch a index.html cuando Play Store esté listo.

**P: ¿Cómo cambio entre versiones?**

R:
```bash
# Usar versión waitlist
cp landing/index-waitlist.html landing/index.html
firebase deploy --only hosting

# Usar versión final (con Play Store link)
git restore landing/index.html  # restaura original
# Editar line 220 y 263 con link Play Store
firebase deploy --only hosting
```

**P: ¿Necesito Privacy Policy antes de lanzar?**

R: **Sí**, es requerido por Play Store. Opciones:
1. Generador simple: https://www.privacypolicygenerator.info/
2. Template: Ver `/landing/privacy.html` (crear página básica)
3. Deploy como `/privacy.html` en Firebase Hosting

**P: ¿Cuánto cuesta Firebase Hosting?**

R: **Gratis** hasta:
- 10GB storage
- 360MB/day transfer (≈ 10,000 pageviews/día)

Para MVP, no pagarás nada.

---

**Creado:** 2025-11-06
**Owner:** Equipo Edaptia
**Status:** Ready to Execute
