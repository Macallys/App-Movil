import '../../../../core/error/result.dart';
import '../../domain/entities/actuator_action.dart';
import '../../domain/repositories/safety_repository.dart';

class GetActuatorActions {
  const GetActuatorActions(this._repository);

  final SafetyRepository _repository;

  Future<Result<List<ActuatorAction>>> call({required String areaId}) {
    return _repository.getActuatorActions(areaId: areaId);
  }
}
