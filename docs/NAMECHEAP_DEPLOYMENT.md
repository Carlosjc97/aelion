# Deployment Landing Page - edaptia.io (Namecheap + Firebase Hosting)

> **Objetivo:** Conectar dominio edaptia.io (Namecheap) con Firebase Hosting para servir landing page

---

## Estrategia Recomendada

### OpciÃ³n A: Firebase Hosting (Recomendado) âœ…
**Pros:**
- Free tier generoso (10GB storage, 360MB/day transfer)
- SSL automÃ¡tico (HTTPS gratis)
- CDN global (ultra rÃ¡pido)
- Deploy con un comando: `firebase deploy`
- IntegraciÃ³n nativa con GA4/Analytics

**Cons:**
- Requiere configurar DNS en Namecheap

### OpciÃ³n B: Namecheap Hosting Directo
**Pros:**
- Todo en un lugar (dominio + hosting)
- Panel cPanel familiar

**Cons:**
- Hosting shared lento
- SSL manual (Let's Encrypt)
- Sin CDN (mÃ¡s lento globalmente)

**RecomendaciÃ³n:** **Firebase Hosting** (mÃ¡s rÃ¡pido, gratis, mejor experiencia)

---

## Setup: Firebase Hosting + Namecheap DNS

### 1. Instalar Firebase CLI

```bash
# Si no tienes Firebase CLI instalado
npm install -g firebase-tools

# Login
firebase login

# Inicializar proyecto (desde root del repo)
firebase init hosting
```

**Responder prompts:**
```
? What do you want to use as your public directory? landing
? Configure as a single-page app (rewrite all urls to /index.html)? No
? Set up automatic builds and deploys with GitHub? No
? File landing/index.html already exists. Overwrite? No
```

### 2. Configurar firebase.json

Editar `firebase.json` (deberÃ­a verse asÃ­):

```json
{
  "hosting": {
    "public": "landing",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "headers": [
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=7200"
          }
        ]
      },
      {
        "source": "**/*.@(css|js)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=3600"
          }
        ]
      }
    ]
  }
}
```

### 3. Deploy a Firebase Hosting (primera vez)

```bash
# Test local preview
firebase serve --only hosting
# Abrir http://localhost:5000

# Deploy a producciÃ³n
firebase deploy --only hosting
```

**Output:**
```
âœ”  Deploy complete!

Project Console: https://console.firebase.google.com/project/YOUR_PROJECT_ID/overview
Hosting URL: https://YOUR_PROJECT_ID.web.app
```

Copia la URL de Hosting (ej: `Edaptia-mvp.web.app`)

---

### 4. Agregar Custom Domain en Firebase Console

1. Ir a Firebase Console â†’ Hosting â†’ "Add custom domain"
2. Ingresar: `edaptia.io`
3. Firebase mostrarÃ¡ 2 registros DNS a configurar:

**Ejemplo (tus valores serÃ¡n diferentes):**
```
Type: A
Name: @
Value: 151.101.1.195

Type: A
Name: @
Value: 151.101.65.195
```

**Para www.edaptia.io (opcional pero recomendado):**
```
Type: CNAME
Name: www
Value: edaptia.io.
```

---

### 5. Configurar DNS en Namecheap

1. **Login a Namecheap**
   - Ir a https://namecheap.com
   - Dashboard â†’ Domain List â†’ edaptia.io â†’ "Manage"

2. **Ir a Advanced DNS**
   - Click tab "Advanced DNS"

3. **Agregar registros A (Firebase Hosting)**

   Click "Add New Record":

   | Type | Host | Value | TTL |
   |------|------|-------|-----|
   | A Record | @ | 151.101.1.195 | Automatic |
   | A Record | @ | 151.101.65.195 | Automatic |
   | CNAME Record | www | edaptia.io. | Automatic |

   **Nota:** Los IPs especÃ­ficos los obtienes de Firebase Console (paso 4)

4. **Eliminar registros conflictivos (si hay)**
   - Eliminar cualquier registro A existente para `@`
   - Eliminar Namecheap Parking Page redirect

5. **Guardar cambios**
   - Click "Save All Changes"

---

### 6. Verificar DNS (esperar propagaciÃ³n)

**Tiempo de propagaciÃ³n:** 10 minutos - 48 horas (usualmente < 1 hora)

```bash
# Verificar registros A
nslookup edaptia.io

# Verificar CNAME
nslookup www.edaptia.io

# O usar herramienta online
# https://dnschecker.org/
```

**Resultado esperado:**
```
edaptia.io        A    151.101.1.195
edaptia.io        A    151.101.65.195
www.edaptia.io    CNAME edaptia.io
```

---

### 7. Verificar dominio en Firebase Console

1. Regresar a Firebase Console â†’ Hosting â†’ "Add custom domain"
2. Firebase verificarÃ¡ automÃ¡ticamente los registros DNS
3. Cuando DNS estÃ© propagado, verÃ¡s:
   ```
   âœ“ DNS records verified
   âœ“ SSL certificate provisioned
   ```
4. **Status:** Connected âœ…
5. **URL final:** https://edaptia.io (con SSL automÃ¡tico)

---

## Mejoras al Landing Page

### Cambio 1: BotÃ³n CTA â†’ Link a Play Store Internal Testing

Actualizar `landing/index.html` line 220 y 263:

```html
<!-- Antes -->
<a href="#" class="cta-button">Empieza gratis</a>

<!-- DespuÃ©s (cuando tengas enlace Play Store) -->
<a href="https://play.google.com/apps/internaltest/YOUR_ID" class="cta-button">
    Unirme a la Beta (Android)
</a>
```

### Cambio 2: Agregar Formulario Waitlist (Pre-Launch)

Si quieres capturar emails **antes** de tener Play Store listo:

```html
<!-- Reemplazar botÃ³n CTA con formulario -->
<form id="waitlist-form" style="max-width: 500px; margin: 0 auto;">
    <input
        type="email"
        id="email"
        placeholder="tu@email.com"
        required
        style="
            width: 100%;
            padding: 18px 24px;
            font-size: 1.1rem;
            border: none;
            border-radius: 50px 50px 0 0;
            margin-bottom: -1px;
        "
    />
    <button
        type="submit"
        class="cta-button"
        style="
            width: 100%;
            border-radius: 0 0 50px 50px;
            cursor: pointer;
            border: none;
        "
    >
        Unirme a la Waitlist
    </button>
    <p class="trial-note">Te avisaremos cuando la app estÃ© lista</p>
</form>

<script>
// Guardar emails en Firestore
document.getElementById('waitlist-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('email').value;

    try {
        // Llamar Cloud Function para guardar email
        await fetch('https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/addToWaitlist', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, timestamp: Date.now() })
        });

        alert('Â¡Gracias! Te avisaremos cuando lancemos ðŸš€');
        document.getElementById('email').value = '';
    } catch (error) {
        console.error(error);
        alert('Error. Por favor intenta de nuevo.');
    }
});
</script>
```

### Cambio 3: Agregar GA4 Tracking

Agregar en `<head>`:

```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXXXXX'); // Tu Measurement ID de Firebase
</script>
```

Obtener Measurement ID:
- Firebase Console â†’ Analytics â†’ Dashboard â†’ Settings icon â†’ Data Streams â†’ Web

---

## Estrategia de Launch con Landing

### Timeline Recomendado

**DÃA -3 (HOY):**
```
1. Deploy landing a Firebase Hosting
2. Configurar DNS en Namecheap
3. Esperar propagaciÃ³n (1-4h)
4. Verificar https://edaptia.io funciona
```

**DÃA -2:**
```
1. Agregar formulario waitlist (capturar emails)
2. Comenzar a compartir en redes:
   - LinkedIn: "Estoy construyendo Edaptia..."
   - Twitter: "Landing page live â†’ edaptia.io"
   - Comunidades LATAM
3. Target: 50-100 emails antes de Play Store
```

**DÃA -1:**
```
1. Subir AAB a Play Store Internal Testing
2. Actualizar landing: Waitlist â†’ Link Play Store
3. Enviar email a waitlist: "Ya puedes probar la beta"
```

**DÃA 0 (LANZAMIENTO):**
```
1. Post masivo en LinkedIn/Twitter
2. Link directo: edaptia.io â†’ Play Store
3. Monitorear trÃ¡fico (GA4)
```

---

## Canales de TrÃ¡fico

### 1. SEO BÃ¡sico (DÃ­a 0)

Ya tienes en `<head>`:
```html
<meta name="description" content="Aprende SQL en 3 semanas...">
<title>Edaptia - Aprende SQL en 3 semanas, no en 3 meses</title>
```

**Agregar:**
```html
<meta property="og:title" content="Edaptia - Aprende SQL en 3 semanas">
<meta property="og:description" content="Plan personalizado adaptado a tu nivel...">
<meta property="og:image" content="https://edaptia.io/og-image.png">
<meta property="og:url" content="https://edaptia.io">
<meta name="twitter:card" content="summary_large_image">
```

### 2. Paid Ads (Opcional - DÃ­a 3-7)

Si quieres acelerar:
- **Google Ads:** Palabras clave "aprender SQL", "curso SQL gratis"
- **Reddit Ads:** r/learnprogramming, r/datascience
- **Budget:** $5-10/dÃ­a (test)
- **Landing page lista** â†’ Mayor conversion rate

### 3. Comunidades OrgÃ¡nicas

**LinkedIn (Personal):**
```
ðŸš€ Acabo de lanzar Edaptia

DespuÃ©s de 6 meses construyendo, hoy lanzo Edaptia: una app que te enseÃ±a
SQL en 3 semanas (no 3 meses).

âœ… Plan personalizado a tu nivel
âœ… 100 preguntas adaptativas
âœ… Enfoque en entrevistas tÃ©cnicas

Beta gratis en Android â†’ edaptia.io

Â¿QuiÃ©n se anima a probar? ðŸ™‹â€â™‚ï¸
```

**Twitter:**
```
Acabo de lanzar edaptia.io ðŸš€

Aprende SQL en 3 semanas con aprendizaje adaptativo.

Beta gratis para Android â†’ https://edaptia.io

RT si conoces a alguien que quiera aprender SQL ðŸ‘‡
```

**Reddit (r/learnprogramming):**
```
Title: I built an adaptive SQL learning app (3-week program)

Body:
Hey r/learnprogramming,

I just launched Edaptia (edaptia.io) - an app that teaches SQL in 3 weeks
using adaptive learning (IRT algorithm).

Key features:
- Initial assessment adapts content to your exact level
- 100 curated SQL questions for marketing analytics
- Mock exam for interview prep
- Free 7-day trial

Currently Android beta (Play Store Internal Testing). Looking for feedback!

Link: https://edaptia.io

Happy to answer questions ðŸ‘‡
```

---

## Comandos Ãštiles

### Deploy landing (cada vez que cambies algo)
```bash
firebase deploy --only hosting
```

### Ver logs
```bash
firebase hosting:logs
```

### Rollback a versiÃ³n anterior
```bash
firebase hosting:rollback
```

---

## Troubleshooting

### DNS no propaga despuÃ©s de 4 horas
- Verificar en https://dnschecker.org/
- Verificar que eliminaste registros conflictivos en Namecheap
- Flush DNS local: `ipconfig /flushdns` (Windows) o `sudo dscacheutil -flushcache` (Mac)

### Firebase dice "DNS verification failed"
- Esperar 10-30 min mÃ¡s
- Verificar que los IPs A records coinciden exactamente
- Verificar que CNAME tiene el punto final: `edaptia.io.` (no `edaptia.io`)

### Landing muestra 404
- Verificar `firebase.json` tiene `"public": "landing"`
- Verificar que `landing/index.html` existe
- Re-deploy: `firebase deploy --only hosting`

### SSL no funciona (insecure warning)
- Esperar 24h (Firebase auto-provisiona SSL)
- Verificar que dominio estÃ¡ "Connected" en Firebase Console

---

## Checklist Pre-Launch

**Antes de compartir edaptia.io:**
- [ ] DNS propagado (https://edaptia.io carga)
- [ ] SSL activo (candado verde en navegador)
- [ ] GA4 tracking funcionando
- [ ] Formulario waitlist guardando emails (o link Play Store)
- [ ] Responsive en mobile (test en celular)
- [ ] Meta tags OG para compartir en redes
- [ ] Footer links actualizados (Privacy Policy, Terms)

---

## MÃ©tricas de Ã‰xito (Landing Page)

**Primeras 48 horas:**
```
âœ… 500+ visitas
âœ… 50+ emails waitlist (o 20+ clicks Play Store)
âœ… Conversion rate â‰¥ 10%
âœ… Bounce rate < 60%
```

**Primera semana:**
```
âœ… 2000+ visitas
âœ… 200+ emails (o 100+ instalaciones Play Store)
âœ… Compartido en 3+ comunidades LATAM
```

---

**PrÃ³ximo paso:** Â¿Quieres que actualice el landing con formulario waitlist o esperamos a tener Play Store listo?

