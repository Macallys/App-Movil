final class EnvironmentalAlert {
  const EnvironmentalAlert({
    required this.id,
    required this.areaId,
    required this.raisedAt,
    this.withdrawnAt,
  });

  final String id;
  final String areaId;
  final DateTime raisedAt;
  final DateTime? withdrawnAt;

  bool get isOpen => withdrawnAt == null;
}
