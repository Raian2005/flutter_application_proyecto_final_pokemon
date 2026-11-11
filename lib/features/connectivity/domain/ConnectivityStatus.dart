enum SyncState {
  online,
  syncing,
  offline,
  serviceUnavailable,
}

class ConnectivityStatus {
  final SyncState status;
  final String message;
  final DateTime lastSyncedAt;

  const ConnectivityStatus({
    required this.status,
    required this.message,
    required this.lastSyncedAt,
  });
}
