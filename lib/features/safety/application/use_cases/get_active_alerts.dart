import '../../../../core/error/result.dart';
import '../../domain/entities/environmental_alert.dart';
import '../../domain/repositories/safety_repository.dart';

class GetActiveAlerts {
  const GetActiveAlerts(this._repository);

  final SafetyRepository _repository;

  Future<Result<List<EnvironmentalAlert>>> call() {
    return _repository.getActiveAlerts();
  }
}
