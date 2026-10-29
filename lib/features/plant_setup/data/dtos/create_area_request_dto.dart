class CreateAreaRequestDto {
  const CreateAreaRequestDto({required this.name, required this.location});

  final String name;
  final String location;

  Map<String, String> toJson() {
    return {'name': name, 'location': location};
  }
}
