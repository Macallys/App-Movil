# safeplant_mobile

SafePlant Supervisor mobile application.

## Desarrollo

```text
flutter pub get
flutter run --dart-define=API_BASE_URL=https://host-real
```

## Debug

```text
flutter build apk --debug
```

## Release

La URL no va en el repositorio. La firma de publicación exige `android/key.properties`, que no se versiona. El detalle está en `docs/release.md`.

```text
flutter build apk --release --dart-define=API_BASE_URL=https://host-real
flutter build appbundle --release --dart-define=API_BASE_URL=https://host-real
```
