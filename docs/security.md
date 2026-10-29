# SAFEPLANT — seguridad de la aplicación móvil

Este documento describe las decisiones que el código aplica. No contiene tokens, contraseñas ni claves.

## Host de la API

`API_BASE_URL` llega solo por `--dart-define=API_BASE_URL`. No hay una URL de producción, de staging ni de localhost escrita en el código.

Si el valor está vacío, `ApiClient` no abre una conexión. La petición falla como error de red. En un build de release, un valor `http://` también se rechaza. Un build de depuración puede usar un host explícito, incluido uno local, porque quien ejecuta la app lo declaró.

Los tiempos de espera del cliente son técnicos: 15 segundos para conectar y 20 segundos para enviar y recibir. No hay reintentos automáticos.

## Sesión

El access token, el rol y `expiresAt` se guardan con `flutter_secure_storage`, detrás de `TokenStorage`. La presentación y el dominio no usan esa librería.

La contraseña y el token de recuperación no se guardan. Viven en el formulario hasta el envío.

No hay `refreshToken` ni `expiresIn`. Una sesión cuya fecha `expiresAt` ya pasó no se restaura. Un `401` en una llamada autenticada borra la sesión local y vuelve a Sign In. Login, recuperación y restablecimiento se envían con `authenticated: false` y no llevan `Authorization`.

Un rol distinto de supervisor no entra al shell. `role_not_allowed` se traduce a acceso denegado, no a un fallo de red.

## Red y Android

No hay `LogInterceptor`, `print` ni `debugPrint` en `lib/`. `ApiException` no incluye el cuerpo de la respuesta en su texto.

No hay `badCertificateCallback` ni tráfico cleartext declarado en el manifiesto. El permiso de Android es solo `INTERNET`. La actividad lanzadora es la única exportada, porque debe abrir la app.

`android:allowBackup` queda en el valor de plataforma. El token está en el almacén seguro, cuya clave no viaja con una copia de la app. No se aplicó `FLAG_SECURE`: la app no muestra datos financieros. No hay detección de root.

La firma de release usa `android/key.properties` cuando ese archivo existe. Si no existe, el APK de release queda firmado con la clave de depuración para poder instalarlo. Falta un keystore de publicación, y no se inventan contraseñas. El `.gitignore` excluye `*.jks`, `*.keystore`, `key.properties` y `.env`.

Un release ofuscado, cuando exista el keystore, puede construirse con:

`flutter build apk --release --obfuscate --split-debug-info=build/symbols`

## Control manual

El override exige confirmación, un actuador por comando y no aplica el estado nuevo hasta la respuesta. No hay reintento automático ni cola offline. Un `503` con código `edge_unreachable` no cambia el actuador. Las combinaciones inválidas se rechazan antes de la petición.
