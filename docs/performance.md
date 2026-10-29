# Rendimiento

Decisiones aplicadas en la revisión de rendimiento. No hay mediciones de frames, memoria ni tiempo de arranque: Flutter DevTools y el modo profile no se ejecutaron.

## Arranque

`bootstrap` solo monta `ProviderScope` y `SafePlantApp`. La sesión se restaura después del primer frame. El panel, el inventario y las alertas no se cargan antes de autenticar.

`ThemeData` se crea una vez en el estado de `SafePlantApp`.

## Providers

La sesión no usa `autoDispose`. El token sigue en almacenamiento seguro; no hay caché en memoria.

`autoDispose` queda en lecturas recientes, alertas activas, historial de exposición, acciones de actuadores y anulación manual. Al salir de la página el provider se libera. Lecturas recientes comprueba `ref.mounted` antes de publicar el resultado, para no escribir estado si el usuario ya salió.

El panel operativo y el inventario no son `autoDispose`: conservan el último resultado mientras la sesión vive. Volver al panel no dispara otro GET si ya hay datos o la lista vacía. El gesto de actualizar y Reintentar siguen llamando a `load`.

## Red

Hay una sola instancia de Dio, creada en `ApiClient`. El interceptor de autenticación se agrega en el constructor, no por request.

No hay cancelación de requests: `ApiClient` no expone `CancelToken` y no se rediseñó.

Las alertas activas usan un solo `Timer` de 15 segundos. `startPolling` no crea otro si ya hay uno. Si una carga está en curso, el siguiente tick no lanza otra. Pull-to-refresh usa la misma carga y el mismo candado. El timer se cancela en `dispose` y cuando la app pasa a `inactive`, `paused`, `hidden` o `detached`. Vuelve a arrancar en `resumed`.

Un refresco en segundo plano no sustituye la lista por un indicador de carga a pantalla completa.

## Listas

Panel, inventario, alertas, exposición y acciones usan `ListView.builder`. Cada fila lleva `ValueKey` con `areaId`, `deviceId`, `alertId`, `exposureId` o `actionId`.

El orden más reciente primero de alertas, exposición y acciones se calcula en la página al reconstruir, no en cada frame. No se añadió igualdad profunda de los resultados del polling.

## Fuera de alcance

Sin reintentos automáticos, sin anulación optimista, sin cola offline y sin caché de telemetría como fuente de verdad. Las rutas de Safety cuyo contrato sigue abierto no llaman HTTP.
