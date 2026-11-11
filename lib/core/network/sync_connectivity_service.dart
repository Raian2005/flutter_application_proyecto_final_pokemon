import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_proyecto_final_pokemon/features/connectivity/domain/ConnectivityStatus.dart';

class SyncConnectivityService {
  static final SyncConnectivityService instance = SyncConnectivityService._init();
  SyncConnectivityService._init();

  final ValueNotifier<ConnectivityStatus> statusNotifier = ValueNotifier(
    ConnectivityStatus(
      status: SyncState.online,
      message: "Comprobando servicio...",
      lastSyncedAt: DateTime.now(),
    ),
  );

  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void startMonitoring() {
    // 1. Escuchar eventos del hardware de red en TIEMPO REAL
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.contains(ConnectivityResult.none)) {
        // En milisegundos cambia a modo Offline cuando cortas el internet
        statusNotifier.value = ConnectivityStatus(
          status: SyncState.offline,
          message: "Sin conexión a internet",
          lastSyncedAt: statusNotifier.value.lastSyncedAt,
        );
      } else {
        // En cuanto regresa el Wi-Fi pingea a PokéAPI
        checkHealth();
      }
    });

    // 2. Comprobación inicial e intervalo periódico cada hora
    checkHealth();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 60), (_) => checkHealth());
  }

  void stopMonitoring() {
    _timer?.cancel();
    _connectivitySubscription?.cancel();
  }

  void notifySyncing() {
    statusNotifier.value = ConnectivityStatus(
      status: SyncState.syncing,
      message: "Sincronizando datos remotos...",
      lastSyncedAt: statusNotifier.value.lastSyncedAt,
    );
  }

  void notifySyncSuccess() {
    statusNotifier.value = ConnectivityStatus(
      status: SyncState.online,
      message: "Datos remotos sincronizados",
      lastSyncedAt: DateTime.now(),
    );
  }

  void notifySyncError(String errorMsg) {
    statusNotifier.value = ConnectivityStatus(
        status: SyncState.serviceUnavailable,
        message: errorMsg,
        lastSyncedAt: statusNotifier.value.lastSyncedAt,
    );
  }

  Future<void> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('https://graphql.pokeapi.co/v1beta2'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode >= 200 && response.statusCode < 500) {
        if (statusNotifier.value.status != SyncState.syncing) {
          notifySyncSuccess();
        }
      } else {
        statusNotifier.value = ConnectivityStatus(
          status: SyncState.serviceUnavailable,
          message: "Servicio GraphQL no disponible (${response.statusCode})",
          lastSyncedAt: statusNotifier.value.lastSyncedAt,
        );
      }
    } catch (e) {
      final isOffline = e.toString().contains("SocketException") || e.toString().contains("Failed host lookup");

      statusNotifier.value = ConnectivityStatus(
        status: isOffline ? SyncState.offline : SyncState.serviceUnavailable,
        message: isOffline ? "Sin conexión a internet" : "PokéAPI no responde",
        lastSyncedAt: statusNotifier.value.lastSyncedAt,
      );
    }
  }
}
