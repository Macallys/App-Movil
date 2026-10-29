# Arquitectura móvil — SafePlant Supervisor

Scaffolding inicial de SafePlant Supervisor Mobile App. Esta etapa fija la estructura y la responsabilidad de cada lugar. No contiene lógica, contratos inventados ni dependencias nuevas.

## Arquitectura elegida

El proyecto combina Feature-First con Clean Architecture. La organización principal es por capability de negocio. Dentro de cada capability, el código se separa en cuatro capas. El objetivo es poder implementar después un vertical slice sin reordenar el proyecto.

## Feature-First

Las capabilities de esta aplicación son:

- `session`: sign-in, sign-out, recuperación de credenciales y restablecimiento de contraseña.
- `plant_setup`: áreas, umbrales ambientales, ficha de setup, alta, asociación, listado y revocación de dispositivos.
- `safety`: dashboard operativo, lecturas recientes, alertas activas, historial corto de exposición, acciones automáticas y override de actuadores.

No hay carpetas globales `screens`, `models`, `services`, `repositories` ni `controllers`.

Queda fuera del móvil la administración de cuentas y de roles, las funciones exclusivas de PlantManager y el historial completo exclusivo de Web. El login móvil usa el canal Mobile. Solo Supervisor entra al shell operativo. PlantManager pertenece al cliente Web. Esas reglas se aplicarán al implementar; aquí solo tienen su lugar.

## Cuatro capas

Cada feature contiene:

- `domain`: entidades y contratos de repositorio.
- `application`: casos de uso.
- `data`: datasources remotos, DTOs, mappers e implementaciones de repositorio.
- `presentation`: pages, widgets, controllers y providers.

## Dependency Rule

Las dependencias permitidas van hacia adentro:

- Presentation depende de Application.
- Application depende de Domain.
- Data depende de Domain.

Domain es Dart puro. No depende de Flutter, Riverpod, Dio, HTTP, JSON, Data ni Presentation.

## Responsabilidad de core

`core` contiene solo infraestructura transversal:

- `auth`: abstracción de almacenamiento del access token, sin mecanismo de persistencia elegido.
- `config`: configuración y environment. El `baseUrl` se resolverá después con `--dart-define=API_BASE_URL` o el mecanismo equivalente.
- `error`: lugar de `failure` y `result`, sin jerarquía todavía.
- `network`: un único cliente HTTP compartido y su excepción, interceptor y constantes.
- `theme`: entrada Material 3. La paleta, la tipografía y el espaciado vendrán de los artefactos del Capítulo V y de Figma. No se inventan aquí.
- `shared/widgets`: widgets realmente compartidos. Hoy está vacío.

Entidades, DTOs, repositorios, casos de uso y controllers de una sola feature no se mueven a `core`.

## Responsabilidad de app

`app` compone el proceso. No contiene casos de uso, DTOs, data sources ni implementaciones de repositorio.

- `app.dart`: `MaterialApp.router` con Material 3. Al arrancar pide a `SessionController` que restaure la sesión.
- `bootstrap.dart`: `ProviderScope` y arranque.
- `router`: `go_router` es la única librería de rutas. El redirect es el auth guard y lee únicamente `SessionController`.
- `shell`: compone la navegación autenticada del supervisor. No decide permisos ni llama APIs.

`go_router` se usa porque el guard necesita redirects declarativos, rutas anidadas del shell y un lugar para deep links futuros. No hay otra librería de routing.

El guard reacciona al estado de sesión:

- `SessionRestoring` muestra `BootstrapPage`.
- Sin sesión, sesión expirada o rol no operativo (`SessionForbidden`, incluido PlantManager) permanece en autenticación: `/sign-in`, `/recovery`, `/reset`.
- `SessionAuthenticated` entra al shell: `/app/safety` y `/app/setup`.
- Un fallo inesperado de restauración deja `SessionFailed` en el bootstrap, con reintento y sin detalle técnico.

Las páginas de Safety y Plant Setup viven en su feature. El shell solo las compone. Cerrar sesión usa `SessionController.signOut`.

No hay wireflow ni assets de Capítulo V en este repositorio. La navegación principal móvil es `NavigationBar` de Material 3.

## DTO versus Entity

El flujo de datos futuro es: JSON HTTP, DTO, mapper, entidad de dominio.

El DTO es estructura de transporte y vive en `data/dtos`. La entidad es modelo de dominio y vive en `domain/entities`. Presentation no usa DTOs. Domain no tendrá `fromJson` ni `toJson`. Los mappers de esta etapa no tienen implementación. En `plant_setup` y `safety` los DTO y los mappers aún no están nombrados, porque el contrato fino no se copia a código en esta etapa.

## Repository Pattern

Cada feature declara su contrato en `domain/repositories` y su implementación en `data/repositories`. No hay repositorio base ni repositorio genérico.

`RegisterDevice` será un caso de uso de aplicación que coordina `IssueDevice` y `AssociateDeviceToArea`. No representa un endpoint `registerDevice`. Esas dos llamadas no están implementadas.

## Composición futura con Riverpod

Riverpod se usará después para composición de dependencias y estado, en este orden:

ApiClient, RemoteDataSource, Repository, UseCase, Controller, Page.

Esta etapa no importa Riverpod y no crea providers funcionales. Los archivos `*_providers.dart` solo reservan esa ubicación.

Presentation podrá expresar más adelante los estados `initial`, `loading`, `data`, `empty`, `unauthorized`, `edgeUnavailable` y `failure`. Esas clases no se crean ahora. Importan porque puede no haber telemetría, puede no haber Edge, el override puede no entregarse y una lista puede estar vacía de forma legítima.

## Política To discuss

Un elemento marcado To discuss no está cerrado. No se implementa, no se agrega como propiedad, endpoint, formulario, entidad ni DTO, y no genera comportamiento ficticio.

Permanecen abiertos, entre otros: `refreshToken`, `expiresIn`, SSE de alertas, `model`, `firmwareVersion`, dirección embebida, secret definitivo, campos finos del tipo de sensor, endpoints todavía no cerrados y aliases que el contrato no haya aceptado.

La sesión documentada para esta app usa `accessToken`, `role` y `expiresAt`. `refreshToken` no forma parte del modelo mientras siga abierto.

Si más adelante hiciera falta reservar un lugar sin decidir el contrato, el único contenido permitido es:

`// TODO: Pending API/domain contract decision.`

## Único ApiClient

Existe un solo `ApiClient` en `core/network`. Los remote data sources de `session`, `plant_setup` y `safety` lo usarán. No habrá clientes separados por recurso. HTTP no está implementado y ningún endpoint está declarado.

## Decisiones de dominio reservadas

`LatestReadings` no se tratará como una lectura ambiental plana. El contrato distingue `carbonDioxide`, `noise` y `presence`. Cada hecho conserva dispositivo, valor y momento de registro. Esos campos no están implementados.

Los actuadores del dominio son Extractor, Siren y Barrier. Los estados posteriores son Off, On, Deployed, Retracted y Failed. Los modos son Auto y Overridden. Un actuador no se diseñará como un único indicador booleano de encendido. Los enums no se crean en esta etapa.

## Regla de no inventar contratos

Lo que el contrato no cierra, el código no lo supone. Esta etapa no añade campos, endpoints, aliases ni persistencia definitiva.

## Fuentes de esta etapa

`LEEME.md`, `docs/mobile-app.md`, `docs/api-dtos.md` y `.cursor/mcp.json` no están en el repositorio: no hay commits locales y el remoto no publica refs. No se encontró una contradicción documentada que revisar. El scaffolding sigue esta especificación y no convierte supuestos en contrato.
