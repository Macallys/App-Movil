DateTime parseIsoDateTime(Object? value, String key) {
  if (value is! String || !_iso8601.hasMatch(value)) {
    throw FormatException('Unexpected $key');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Unexpected $key');
  }
  return parsed;
}

final RegExp _iso8601 = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$',
);
