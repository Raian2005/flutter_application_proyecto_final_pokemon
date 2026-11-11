import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/theme/app_dimens.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/theme/app_theme.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/utils/formatters.dart';

enum ServiceStatus { checking, online, offline, unavailable }

enum DataOrigin { remote, local }

class ConnectivityIndicator extends StatelessWidget {
  const ConnectivityIndicator({
    super.key,
    required this.status,
    this.isSyncing = false,
    this.origin = DataOrigin.local,
    this.lastSync,
    this.retryInSeconds,
    this.onTap,
  });

  final ServiceStatus status;
  final bool isSyncing;
  final DataOrigin origin;
  final DateTime? lastSync;
  final int? retryInSeconds;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = _IndicatorSpec.resolve(context, this);
    final theme = Theme.of(context);
    final pokedex = PokedexTheme.of(context);

    return Semantics(
      container: true,
      liveRegion: true,
      button: onTap != null,
      label: 'Estado de conexión: ${spec.title}. ${spec.detail}',
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              spec.color.withValues(alpha: 0.08),
              theme.colorScheme.surface,
            ),
            borderRadius: BorderRadius.circular(Radii.field),
            border: Border.all(color: spec.color.withValues(alpha: 0.24)),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(Radii.field),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinTapTarget),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Gap.m,
                    vertical: Gap.s,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                      key: ValueKey(spec.title),
                      children: [
                        _StatusBadge(
                          icon: spec.icon,
                          color: spec.color,
                          spinning: spec.spinning,
                        ),
                        const SizedBox(width: Gap.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                spec.title,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: spec.color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                spec.detail,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: pokedex.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (onTap != null)
                          Icon(
                            Icons.chevron_right_rounded,
                            color: pokedex.inkMuted,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicatorSpec {
  const _IndicatorSpec({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    this.spinning = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final bool spinning;

  static _IndicatorSpec resolve(BuildContext context, ConnectivityIndicator w) {
    final t = PokedexTheme.of(context);
    final originLabel =
        w.origin == DataOrigin.remote ? 'Datos remotos' : 'Datos locales';
    final freshness = w.lastSync == null
        ? 'sin sincronizar aún'
        : w.origin == DataOrigin.remote
            ? 'actualizado ${Fmt.syncTime(w.lastSync!)}'
            : 'última sync ${Fmt.syncTime(w.lastSync!)}';

    if (w.isSyncing && w.status == ServiceStatus.online) {
      return _IndicatorSpec(
        icon: Icons.sync_rounded,
        color: t.syncing,
        title: 'Sincronizando…',
        detail: 'En línea · puedes seguir navegando',
        spinning: true,
      );
    }

    return switch (w.status) {
      ServiceStatus.online => _IndicatorSpec(
          icon: Icons.cloud_done_rounded,
          color: t.online,
          title: 'En línea',
          detail: '$originLabel · $freshness',
        ),
      ServiceStatus.offline => _IndicatorSpec(
          icon: Icons.cloud_off_rounded,
          color: t.offline,
          title: 'Sin conexión',
          detail: '$originLabel · $freshness',
        ),
      ServiceStatus.unavailable => _IndicatorSpec(
          icon: Icons.warning_amber_rounded,
          color: t.unavailable,
          title: 'Servicio no disponible',
          detail: w.retryInSeconds != null
              ? 'Red activa, API sin respuesta · $originLabel · reintento en ${w.retryInSeconds} s'
              : 'Red activa, API sin respuesta · $originLabel',
        ),
      ServiceStatus.checking => _IndicatorSpec(
          icon: Icons.wifi_find_rounded,
          color: t.offline,
          title: 'Verificando servicio…',
          detail: '$originLabel · $freshness',
        ),
    };
  }
}

class _StatusBadge extends StatefulWidget {
  const _StatusBadge({
    required this.icon,
    required this.color,
    required this.spinning,
  });

  final IconData icon;
  final Color color;
  final bool spinning;

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.spinning && !reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: RotationTransition(
        turns: _controller,
        child: Icon(widget.icon, size: 17, color: widget.color),
      ),
    );
  }
}
