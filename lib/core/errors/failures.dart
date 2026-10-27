class Failure implements Exception {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class RemoteFailure extends Failure {
  const RemoteFailure(super.message);
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}
