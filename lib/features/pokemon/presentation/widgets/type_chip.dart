import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto_final_pokemon/core/theme/pokemon_colors.dart';

class TypeChip extends StatelessWidget {
  const TypeChip ({
    super.key,
    required this.type,
    this.dense = false,
    this.selected = false,
    this.onTap,
  });

  final String type;
  final bool dense;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dotColor = PokemonColors.getTypeBorderColor(type);
    final background = selected
        ? dotColor.withOpacity(0.22)
        : Colors.grey.withOpacity(0.08);

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding:  EdgeInsets.symmetric(
        horizontal: dense ? 8 : 12,
        vertical: dense ? 4 : 8,
      ),
      decoration:  BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? dotColor : Colors.black12,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dense ? 7 : 9,
            height: dense ? 7 : 9,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: dense ? 5 : 7),
          Text(
            type[0].toUpperCase() + type.substring(1),
            style: TextStyle(
              fontSize: dense ? 11 : 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: chip,
    );

  }
}