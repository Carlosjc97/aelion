# Plan de Lanzamiento - Aelion MVP

> **Objetivo:** 100 usuarios completando calibración en los primeros 7 días
> **Target Trial Start Rate:** ≥ 6%
> **Fecha de Lanzamiento:** 2025-11-08 (DÍA 5)

---

## 🎯 Objetivo del Lanzamiento

**Meta principal:**
- 100 usuarios completan calibración
- ≥ 6 trial starts (6% conversion rate)
- Crash-free rate ≥ 99%
- Recopilar feedback cualitativo para iteración

**NO es objetivo:**
- Viralidad masiva
- Revenue inmediato
- Perfección técnica

**Filosofía:** "Better shipped than perfect. Better with users than without."

---

## 📅 Timeline de Lanzamiento

### **Día -3 (HOY - 2025-11-06): Web Launch**
- [ ] Deploy landing a Firebase Hosting
- [ ] Configurar DNS edaptia.io (Namecheap → Firebase)
- [ ] Activar formulario waitlist (capturar emails)
- [ ] Comenzar a compartir en LinkedIn/Twitter
- [ ] Target: 50-100 emails pre-launch

### **Día -2 (2025-11-07): Preparación App**
- [ ] Build & Upload AAB a Play Store Internal Testing
- [ ] 20-30 slots de internal testing disponibles
- [ ] Actualizar landing: Waitlist → Play Store link
- [ ] Dashboard GA4 configurado
- [ ] Crashlytics validado funcionando
- [ ] Smoke tests completos (15/15 checks)

### **Día -1 (2025-11-08): Pre-launch**
- [ ] Internal testers invitados (5-10 personas)
- [ ] Feedback inicial recopilado
- [ ] Bugs críticos corregidos (P0/P1)
- [ ] Mensaje de lanzamiento preparado

### **Día 0 (2025-11-09): Lanzamiento Público**
- [ ] Invitaciones Play Store enviadas (50 personas)
- [ ] Email a waitlist: "Beta ya disponible"
- [ ] Post en redes sociales publicado
- [ ] Comunidades notificadas
- [ ] Dashboard GA4 monitoreado cada 2 horas

### **Día 1-3: Monitoreo Activo**
- [ ] Responder preguntas de usuarios < 2 horas
- [ ] Revisar Crashlytics 2x/día
- [ ] Analizar eventos GA4 diariamente
- [ ] Iterar basado en feedback

### **Día 7: Primera Retrospectiva**
- [ ] Analizar métricas vs targets
- [ ] Recopilar feedback cualitativo
- [ ] Decidir próximos pasos
- [ ] Publicar learnings internos

---

## 🗣️ Canales de Comunicación

### **1. Red Personal (Día 0)**

#### LinkedIn Post (Día -3: Pre-Launch)
```
🚀 Estoy construyendo Edaptia

Aprende SQL en 3 semanas (no 3 meses) con aprendizaje adaptativo.

Landing page: edaptia.io

✅ Plan personalizado a tu nivel
✅ 100 preguntas SQL curadas
✅ Enfoque en entrevistas técnicas

Beta Android próximamente. ¿Quién quiere ser early tester? 👇
```

#### LinkedIn Post (Día 0: Launch)
```
🚀 ¡Lanzamos Edaptia en Beta!

Después de 5 días intensos construyendo, hoy lanzamos Edaptia:
un compañero de aprendizaje que te enseña SQL en 3 semanas, no en 3 meses.

¿Qué hace diferente a Edaptia?
✅ Evaluación adaptativa que personaliza tu plan
✅ Algoritmo IRT que ajusta dificultad en tiempo real
✅ 100 preguntas SQL curadas para Marketing Analytics
✅ 7 días gratis para probarlo

🔥 Busco 100 early adopters que quieran:
- Aprender SQL para sus próximas entrevistas
- Feedback honesto (bugs incluidos)
- Ayudar a construir algo útil

Interesados: Comenta "SQL" y les envío el link de TestFlight

#SQL #EdTech #MVP #BuildInPublic

---

[Agregar screenshot del paywall o calibración]
```

**Engagement esperado:** 50-100 impresiones, 5-10 comentarios

#### Twitter/X Thread
```
🧵 Lancé una app en 5 días para enseñar SQL adaptado a tu nivel

Día 1: 100 preguntas SQL + parámetros IRT
Día 2: Assessment engine E2E funcionando
Día 3: Paywall UI (M1 gratis, resto premium)
Día 4: GA4 events + smoke tests
Día 5: Lanzamiento 🚀

¿Por qué tan rápido? [1/5]

---

La mayoría de cursos SQL son genéricos. Si ya sabes SELECT, ¿por qué ver 2 horas de videos básicos?

Aelion evalúa tu nivel en 10 preguntas y genera un plan personalizado.

Fundamentos → Joins → Subqueries → Window Functions [2/5]

---

Tech stack:
- Flutter (mobile)
- Firebase (backend)
- Express + IRT (adaptive testing)
- Cloud Run (deployment)

Todo open source próximamente 👀 [3/5]

---

Modelo freemium:
- M1 (Fundamentos SELECT): GRATIS
- M2-M6: $XX/mes (después de 7 días trial)

Trial start rate objetivo: ≥6%

Spoiler: Ya tengo datos de día 0... [4/5]

---

Busco 100 early adopters para beta.

¿Quieres aprender SQL para tu próxima entrevista?
→ TestFlight link en bio

Feedback brutal bienvenido 🙏

#BuildInPublic #SQL #EdTech [5/5]
```

**Engagement esperado:** 200-500 impresiones, 10-20 clicks

### **2. Comunidades LATAM (Día 0-1)**

#### Discord/Slack Tech LATAM
```
👋 Hola comunidad!

Lancé Aelion, una app para aprender SQL adaptada a tu nivel.

¿Por qué comparto aquí?
- Busco feedback técnico honesto
- El contenido está enfocado en Marketing Analytics (útil para muchos roles)
- Es MVP (habrá bugs, lo sé 😅)

🎁 Ofrezco:
- 7 días gratis
- Early access a features nuevas
- Créditos permanentes cuando lancemos

¿Interesados en probar?
→ [Link TestFlight]

Comentarios/bugs bienvenidos en DM o aquí 👇
```

**Comunidades target:**
- Tech LATAM Discord
- Data Science LATAM Slack
- Flutter Devs LATAM
- Marketing Analytics groups

**Engagement esperado:** 20-40 usuarios

### **3. Reddit (Día 1-2)**

#### r/learnprogramming
```
Title: [Project] I built an adaptive SQL learning app in 5 days - Looking for beta testers

Hey r/learnprogramming!

Just shipped Aelion, an app that teaches SQL with a personalized plan based on your level.

**How it works:**
1. Take a 10-question placement quiz
2. Get a customized learning path (Beginner/Intermediate/Advanced)
3. Study with adaptive questions that adjust to your performance
4. Practice with a mock exam before interviews

**Tech:**
- Flutter (cross-platform)
- IRT algorithm for adaptive testing
- 100 SQL questions curated for Marketing Analytics

**Looking for:**
- 100 beta testers
- Honest feedback (bugs expected)
- Suggestions for improvement

**Beta access:**
- 7 days free trial
- Early access to new features
- No credit card required

Link in comments (TestFlight)

Open to questions! 👇
```

**Subreddits adicionales:**
- r/datascience
- r/analytics
- r/SQLServer
- r/startups (si el post es sobre el journey)

**Engagement esperado:** 30-60 usuarios

### **4. Product Hunt (Día 3-5)**

**Sólo si hay momentum:**
- Esperar a tener 50+ usuarios activos
- Preparar assets (screenshots, video demo)
- Programar para un martes/miércoles
- Conseguir 5-10 upvotes iniciales

**NO lanzar en Product Hunt si:**
- < 50 usuarios activos
- Crash rate > 5%
- Trial start rate < 4%

---

## 📱 Materiales de Marketing

### **Screenshots Necesarios**
1. Calibration quiz (10 preguntas)
2. Paywall modal ("Desbloquear plan completo")
3. Module outline (M1 gratis, M2-M6 locked)
4. Lesson detail (contenido SQL)
5. Trial CTA

### **Copy Points**
- "Aprende SQL en 3 semanas, no en 3 meses"
- "Plan personalizado basado en tu nivel"
- "100 preguntas adaptativas"
- "7 días gratis, sin tarjeta"
- "Mock exam para entrevistas"

### **Social Proof (si hay)**
- Testimonios de internal testers
- Screenshots de progreso
- Métricas de engagement

---

## 🎬 Secuencia de Invitaciones TestFlight

### **Wave 1: Internal (Día -1)**
**Target:** 5-10 personas
**Perfil:** Colegas, amigos técnicos
**Objetivo:** Smoke testing, bugs críticos

**Script de invitación:**
```
Hola [Nombre],

Lancé una app para aprender SQL y necesito tu feedback brutal antes de abrir la beta.

¿Podrías probarla 10 minutos y decirme qué está roto?

Link TestFlight: [LINK]

Gracias! 🙏
```

### **Wave 2: Early Adopters (Día 0)**
**Target:** 20-30 personas
**Perfil:** Red personal LinkedIn/Twitter
**Objetivo:** Primeros usuarios reales, validación de valor

**Script:**
```
🚀 Hola!

Hoy lanzo Aelion en beta: una app para aprender SQL adaptada a tu nivel.

¿Te interesa SQL para tu próxima entrevista?
→ TestFlight link: [LINK]

7 días gratis, sin tarjeta.

Feedback bienvenido 👇
```

### **Wave 3: Comunidades (Día 1-2)**
**Target:** 50+ personas
**Perfil:** Reddit, Discord, Slack communities
**Objetivo:** Alcanzar 100 usuarios, diversidad de feedback

---

## 📊 Métricas a Monitorear (Diarias)

### **Día 0-7**
```
□ Total downloads (TestFlight)
□ Calibration starts
□ Calibration completions
□ Paywall views (post_calibration)
□ Trial starts
□ M1 starts
□ M1 completions
□ Crashes (count + stack traces)
□ Session duration (avg)
```

### **Dashboard diario (Google Sheets)**
```
| Día | Downloads | Calibrations | Trials | M1 Complete | Crashes |
|-----|-----------|--------------|--------|-------------|---------|
| 0   | 20        | 15           | 1      | 5           | 2       |
| 1   | 35        | 28           | 3      | 12          | 1       |
| ... |           |              |        |             |         |
```

---

## 🚨 Criterios de Éxito/Fallo

### **Señales de Éxito (Día 7)**
✅ ≥ 100 calibrations completadas
✅ ≥ 6% trial start rate
✅ ≥ 60% M1 completion rate
✅ ≥ 99% crash-free rate
✅ ≥ 5 mensajes de feedback positivo

**Acción:** Continuar con beta pública, iterar features

### **Señales de Alerta**
⚠️ < 50 calibrations completadas
⚠️ < 3% trial start rate
⚠️ < 40% M1 completion rate
⚠️ < 95% crash-free rate

**Acción:** Pausar invitaciones, analizar data, iterar

### **Señales de Fallo Crítico**
❌ Crash rate > 10%
❌ Trial start rate < 2%
❌ Feedback mayormente negativo

**Acción:** Rollback, refactor, relanzar en 2 semanas

---

## 💬 Templates de Respuesta

### **Cuando alguien reporta un bug:**
```
¡Gracias por reportar! 🙏

¿Podrías compartir:
1. Device (iPhone 14, Pixel 5, etc.)
2. Pasos para reproducir
3. Screenshot si es posible

Lo priorizo para el siguiente build.
```

### **Cuando alguien completa el trial:**
```
🎉 ¡Felicidades por completar el trial!

¿Qué tal la experiencia?
1. ¿Te sentiste más preparado para SQL?
2. ¿Algo que mejorarías?
3. ¿Considerarías pagar $XX/mes después del trial?

Tu feedback ayuda mucho 🙏
```

### **Cuando alguien cancela:**
```
Gracias por probar Aelion 👋

¿Puedo preguntar qué fue lo que no funcionó para ti?

Tu feedback me ayuda a mejorarlo para otros usuarios.
```

---

## 🎯 Próximos Pasos Post-Lanzamiento

### **Semana 2-4: Iterar**
- Analizar data GA4
- Priorizar bugs críticos
- Implementar top 3 feature requests
- A/B test paywall timing

### **Mes 2: Escalar**
- Agregar más tracks (Python, Excel, etc.)
- Implementar Stripe real (si trial start rate > 8%)
- Landing page optimizada
- App Store public beta

### **Mes 3+: Monetizar**
- Primera cohorte de pagos
- Calcular LTV/CAC
- Decide: Pivot, Persevere, or Kill

---

**Última actualización:** 2025-11-04
**Owner:** Founder
**Próxima revisión:** Día 7 post-launch
