# Empaquetado de release

No contiene contraseñas, tokens ni la URL real del servidor.

## Requisitos

- Flutter 3.47.5
- Dart 3.13.4
- Android compileSdk 36, targetSdk 36 y minSdk 24, tomados de la extensión de Flutter. No están duplicados en el proyecto.
- Java 17, como fija `android/app/build.gradle.kts`.

## Versión

`pubspec.yaml` declara `0.1.0+1`. Es la versión inicial de la entrega académica.

Flutter la traduce así:

- `versionName` = `0.1.0`
- `versionCode` = `1`

Gradle usa `flutter.versionName` y `flutter.versionCode`. No hay otra versión escrita en el manifiesto.

## Identidad

- Nombre visible en el launcher: SafePlant Supervisor.
- `applicationId`: `com.macallys.safeplant_mobile`.
- Nombre del paquete Dart: `safeplant_mobile`.

El icono del launcher sigue siendo el de la plantilla de Flutter. No hay un icono oficial de SafePlant en el repositorio ni en los assets del capítulo. No se inventó uno.

El splash es el fondo de arranque nativo, color de lienzo `#F8F9FF`, sin ilustración ni animación. El tema nocturno de arranque usa el mismo fondo claro, porque la app no tiene modo oscuro.

## API

La URL no está en el código. Se inyecta al construir:

```text
flutter build apk --release --dart-define=API_BASE_URL=https://host-real
flutter build appbundle --release --dart-define=API_BASE_URL=https://host-real
```

Sustituir `https://host-real` por el host del entorno. Si el valor falta, el cliente no abre una conexión. En release, un valor `http://` también se rechaza. Un build sin `--dart-define` compila, pero la app no llama a un servidor.

## Ejecución y builds

Desarrollo:

```text
flutter run --dart-define=API_BASE_URL=https://host-real
```

APK de depuración:

```text
flutter build apk --debug
```

El resultado queda en `build/app/outputs/flutter-apk/app-debug.apk`.

APK de release, sin ofuscar:

```text
flutter build apk --release --dart-define=API_BASE_URL=https://host-real
```

El resultado queda en `build/app/outputs/flutter-apk/app-release.apk`.

AAB de release:

```text
flutter build appbundle --release --dart-define=API_BASE_URL=https://host-real
```

El resultado queda en `build/app/outputs/bundle/release/app-release.aab`.

No se genera `--split-per-abi`. Si hiciera falta un APK por arquitectura, el comando es `flutter build apk --release --split-per-abi` junto con el mismo `--dart-define`.

Ofuscación, opcional y no exigida para esta entrega:

```text
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols --dart-define=API_BASE_URL=https://host-real
```

`build/symbols` hay que conservarlo para simbolizar fallos. No se borra como parte del empaquetado. `minifyEnabled` y `shrinkResources` no están activos.

## Firma

La depuración usa el keystore de debug de Android.

El release busca `android/key.properties`. Ese archivo y los `*.jks` / `*.keystore` están en `.gitignore`. El archivo no se crea en el repositorio y no lleva contraseñas de ejemplo.

Cuando exista un keystore real, `android/key.properties` necesita `storePassword`, `keyPassword`, `keyAlias` y `storeFile`. `storeFile` es una ruta relativa a `android/app`. Si el archivo no está, el release se firma con la clave de depuración para poder instalar el APK. Esa firma no sirve para Play Store.

## Seguridad que el paquete conserva

No hay URL de producción escrita en el código. No hay reintento automático ni anulación optimista. El token sigue en almacenamiento seguro. El banner DEBUG no aparece en release: Flutter lo oculta sin un ajuste extra. No hay cuenta de prueba precargada ni menú de desarrollador.

## Lo que esta fase no hizo

No se instaló el APK en un dispositivo ni en un emulador. No se probó una actualización sobre una versión anterior. No se publicó en Play Store, Firebase ni GitHub.
