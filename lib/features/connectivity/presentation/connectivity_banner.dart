import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/network/sync_connectivity_service.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/connectivity/domain/ConnectivityStatus.dart';
import 'package:flutter_application_proyecto_final_pokemon/features/connectivity/presentation/connectivity_indicator.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ConnectivityStatus>(
      valueListenable: SyncConnectivityService.instance.statusNotifier,
      builder: (context, status, child) {
        ServiceStatus serviceStatus;
        bool isSyncing = false;

        switch (status.status) {
          case SyncState.syncing:
            serviceStatus = ServiceStatus.online;
            isSyncing = true;
            break;
          case SyncState.online:
            serviceStatus = ServiceStatus.online;
            break;
          case SyncState.offline:
            serviceStatus = ServiceStatus.offline;
            break;
          case SyncState.serviceUnavailable:
            serviceStatus = ServiceStatus.unavailable;
            break;
        }

        return ConnectivityIndicator(
          status: serviceStatus,
          isSyncing: isSyncing,
          origin: status.status == SyncState.online ? DataOrigin.remote : DataOrigin.local,
          lastSync: status.lastSyncedAt,
        );
      },
    );
  }
}
