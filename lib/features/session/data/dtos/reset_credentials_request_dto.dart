class ResetCredentialsRequestDto {
  const ResetCredentialsRequestDto({
    required this.token,
    required this.password,
  });

  final String token;
  final String password;

  Map<String, String> toJson() {
    return {'token': token, 'password': password};
  }
}
