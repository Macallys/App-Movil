import '../../../../core/error/result.dart';
import '../../domain/entities/area_operational_status.dart';
import '../../domain/repositories/safety_repository.dart';

class GetOperationalStatus {
  const GetOperationalStatus(this._repository);

  final SafetyRepository _repository;

  Future<Result<List<AreaOperationalStatus>>> call() {
    return _repository.getOperationalStatus();
  }
}
