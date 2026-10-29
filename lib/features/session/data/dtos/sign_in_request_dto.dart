class SignInRequestDto {
  const SignInRequestDto({required this.email, required this.password});

  static const channel = 'Mobile';

  final String email;
  final String password;

  Map<String, String> toJson() {
    return {'email': email, 'password': password, 'channel': channel};
  }
}
