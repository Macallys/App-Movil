/// Client-side decision for the API host.
///
/// An empty value must not fall through to a relative or invented host.
/// Cleartext is rejected only for release builds. A debug build may point
/// at an explicit local host supplied with --dart-define.
enum BaseUrlDecision { allowed, missing, cleartext }

BaseUrlDecision assessBaseUrl(String url, {required bool release}) {
  final value = url.trim().toLowerCase();
  if (value.isEmpty) {
    return BaseUrlDecision.missing;
  }
  if (release && value.startsWith('http://')) {
    return BaseUrlDecision.cleartext;
  }
  return BaseUrlDecision.allowed;
}
