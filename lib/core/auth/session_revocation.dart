class SessionRevocation {
  void Function()? _onRevoked;

  void bind(void Function() onRevoked) {
    _onRevoked = onRevoked;
  }

  void unbind() {
    _onRevoked = null;
  }

  void revoke() {
    _onRevoked?.call();
  }
}
