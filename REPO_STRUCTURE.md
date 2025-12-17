# Estructura del Repositorio Edaptia

Este documento explica qué hace cada archivo de configuración en el root del proyecto.

## 📱 Flutter / Dart

| Archivo | Propósito | ¿Se puede mover? |
|---------|-----------|------------------|
| `pubspec.yaml` | Dependencias y configuración de Flutter | ❌ NO - Flutter lo busca en root |
| `pubspec.lock` | Versiones exactas de dependencias (auto-generado) | ❌ NO - Flutter lo genera en root |
| `analysis_options.yaml` | Reglas del analizador de Dart | ❌ NO - Dart lo busca en root |
| `l10n.yaml` | Configuración de internacionalización | ❌ NO - Flutter l10n lo busca en root |
| `.metadata` | Metadata de Flutter (auto-generado) | ❌ NO - Flutter lo usa |

## 🔥 Firebase

| Archivo | Propósito | ¿Se puede mover? |
|---------|-----------|------------------|
| `firebase.json` | Configuración principal de Firebase | ❌ NO - Firebase CLI lo busca en root |
| `.firebaserc` | Aliases de proyectos Firebase | ❌ NO - Firebase CLI lo busca en root |
| `firestore.rules` | Reglas de seguridad de Firestore | ❌ NO - Firebase CLI lo busca en root |
| `firestore.indexes.json` | Índices de Firestore | ❌ NO - Firebase CLI lo busca en root |
| `apphosting.yaml` | Configuración de Firebase App Hosting | ❌ NO - Firebase App Hosting lo busca en root |
| `.flutterfireconfig.json` | Configuración de FlutterFire CLI (auto-generado) | ❌ NO - FlutterFire CLI lo usa |

## 📦 Node.js / npm

| Archivo | Propósito | ¿Se puede mover? |
|---------|-----------|------------------|
| `package.json` | Dependencias de Node.js (para Functions/landing) | ❌ NO - npm lo busca en root |
| `package-lock.json` | Versiones exactas de npm (auto-generado) | ❌ NO - npm lo genera en root |

## 🔐 Git / Seguridad

| Archivo | Propósito | ¿Se puede mover? |
|---------|-----------|------------------|
| `.gitignore` | Archivos que Git debe ignorar | ❌ NO - Git lo busca en root |
| `.gitattributes` | Atributos de archivos para Git | ❌ NO - Git lo busca en root |
| `.gitleaks.toml` | Configuración de Gitleaks (detección de secretos) | ✅ SÍ - Pero convención es root |

## 📝 Documentación

| Archivo | Propósito | ¿Se puede mover? |
|---------|-----------|------------------|
| `README.md` | Documentación principal del proyecto | ❌ NO - Convención universal |
| `CONTRIBUTING.md` | Guía para contribuidores | ❌ NO - Convención de GitHub |
| `LAUNCH_GUIDE.md` | Guía de lanzamiento a Play Store | ✅ SÍ - Podría ir en `docs/` |
| `REPO_STRUCTURE.md` | Este archivo | ✅ SÍ - Podría ir en `docs/` |

## 🔑 Secretos y Ambiente

| Archivo | Propósito | ¿Se puede mover? |
|---------|-----------|------------------|
| `.env.example` | Ejemplo de variables de ambiente | ❌ NO - Convención |
| `upload-keystore.jks` | ⚠️ Clave de firma de Android | ❌ Debe estar gitignored |

## ❌ Archivos Auto-generados (gitignored)

Estos archivos son generados automáticamente por herramientas y NO deben commitearse:

- `devtools_options.yaml` - Flutter DevTools
- `.flutter-plugins-dependencies` - Flutter
- `*.log` - Logs de desarrollo
- `*_tree.txt` - Árboles de archivos temporales

## 📊 Resumen

**Total de archivos de config en root**: ~15 archivos obligatorios

**¿Por qué tantos?**
- Flutter/Dart requiere 5 archivos en root
- Firebase requiere 6 archivos en root
- Git requiere 2 archivos en root
- npm requiere 2 archivos en root

**Esto es normal** en proyectos modernos multi-plataforma. No es desorden, es el estándar de la industria.

## ✅ Lo que SÍ hicimos para mejorar

1. ✅ Eliminamos archivos basura (`et --hard v0.9.1-rc1`, `nul`, etc.)
2. ✅ Gitignoreamos archivos auto-generados (`devtools_options.yaml`)
3. ✅ Eliminamos configs obsoletos (`codex.apphosting.json`)
4. ✅ Documentamos cada archivo en este documento

## 💡 Recomendación Final

**NO intentes** mover estos archivos a carpetas - romperías el tooling.
**SÍ mantén** el root limpio eliminando archivos basura y temporales.
**SÍ documenta** qué hace cada archivo (como este documento).

---

**Última actualización**: 15 de diciembre de 2025
