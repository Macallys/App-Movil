# SAFEPLANT — design system (fundación)

Fuente visual: archivo Figma `SAFEPLANT-IoT` (`LQrxGncQXV76uBaTK4ZvQe`), página `MOCKUP MOVIL` (`9:2`), y la guía de estilo del Capítulo V. Solo existe la variante Light. No hay paleta oscura.

Los archivos sueltos pedidos como `style-guidelines/general.png`, `web-mobile-iot.png`, `navigation-systems.png`, `wireframes.png`, `wireflow.png`, `mockups.png`, `user-flow.png` y `prototype.png` no están en el repositorio de la app. El material real está en el informe, bajo `Report/assets/05-capitulo-v/`.

## Color

| Nombre en la guía | Hex | Uso en Material 3 |
| --- | --- | --- |
| Primario, azul marino | `#0F2744` | `colorScheme.primary` |
| Secundario, azul profundo | `#1B3B64` | `primaryContainer` |
| Secundario, azul | `#2563EB` | `colorScheme.secondary` |
| Secundario, cian | `#00E5FF` | `colorScheme.tertiary` |
| Terciario, azul claro | `#CBDBF5` | `secondaryContainer` |
| Terciario, azul hielo | `#EFF4FF` | `tertiaryContainer` |
| Terciario, fondo | `#F8F9FF` | `scaffoldBackgroundColor` |
| Blanco | `#FFFFFF` | `surface` y texto sobre primario |
| Verde | `#10B981` | estado normal, sin rol de `ColorScheme` |
| Ámbar | `#F59E0B` | advertencia; severidad Media |
| Rojo | `#EF4444` | `colorScheme.error` y severidad Alta |
| Gris | `#64748B` | `outline` y texto secundario |

El botón primario de la guía es marino con texto blanco. El enlace y el checkbox marcado usan el azul `#2563EB`.

## Tipografía

Familia indicada: Space Grotesk. No está en `pubspec.yaml` ni en `assets/`. El tema no declara `fontFamily` para no pedir una fuente ausente.

Interlineado documentado: 1.5. Base de la escala: 16 px. Texto de interfaz: 18 px Regular. Botón primario: 24 px Bold. Botón secundario: 24 px Regular. Botón pequeño: 20 px Regular. Heading 06, usado en títulos de pantalla actuales: 24 px SemiBold.

Los headings 01 a 03 (128, 60 y 43 px) pertenecen a la guía general y no se aplican a las pantallas móviles de 390 px.

## Espaciado y radio

Retícula de 8 px. Pasos nombrados: 8, 16, 24 y 32. Radio único de botones, campos y paneles: 10 px. La guía no publica elevación numérica; las tarjetas y los botones quedan en elevación 0.

## Navegación diseñada

El mockup móvil mide 390 px de ancho. La barra inferior tiene cinco destinos: Panel, Alertas, Umbrales, Historial y Equipos. La app actual conserva dos destinos, Safety y Plant Setup. Esta fase no cambia el enrutamiento.

## Componentes compartidos

No se crearon widgets nuevos. Los controles repetidos —botón relleno, botón con borde, botón de texto, campo, tarjeta, diálogo y barra de navegación— quedan en `ThemeData`.

## Huecos visuales

- Recuperación y restablecimiento de credenciales no tienen frame móvil.
- Alta de área, ficha de área, alta de dispositivo, inventario con revocación, detalle de área, lecturas recientes, historial corto de exposición, bitácora de actuadores, control manual y arranque no tienen frame propio.
- El frame «Registro» es el alta de cuenta, no el alta de un dispositivo.
- No hay empty states, error de red, sesión vencida ni `edge_unreachable`.
- No hay skeleton. El único indicador de carga no está especificado.
- Space Grotesk no está empaquetada.

## Código

`lib/core/theme/app_colors.dart`, `app_typography.dart`, `app_spacing.dart`, `app_radius.dart` y `app_theme.dart`. `SafePlantApp` usa `AppTheme.light()`.
