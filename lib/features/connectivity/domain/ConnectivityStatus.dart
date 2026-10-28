enum Connectivity_status {
  online,
  offline,
  apiUnreachable,
}

class ConnectivityStatus {
  final Connectivity_status status;
  final String message;
  final DateTime lastChecked;

  const ConnectivityStatus({
    required this.status,
    required this.message,
    required this.lastChecked
  });
}