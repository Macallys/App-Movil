class RequestCredentialRecoveryDto {
  const RequestCredentialRecoveryDto({required this.email});

  final String email;

  Map<String, String> toJson() {
    return {'email': email};
  }
}
