import '../../domain/entities/industrial_area.dart';
import '../dtos/industrial_area_dto.dart';

class IndustrialAreaMapper {
  const IndustrialAreaMapper();

  IndustrialArea toEntity(IndustrialAreaDto dto) {
    return IndustrialArea(id: dto.id, name: dto.name, location: dto.location);
  }
}
