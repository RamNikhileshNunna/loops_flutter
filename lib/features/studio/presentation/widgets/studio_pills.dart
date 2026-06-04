import 'package:flutter/material.dart';

/// One selectable pill option.
class StudioPillItem<T> {
  const StudioPillItem({
    required this.value,
    required this.label,
    this.icon,
    this.activeIcon,
  });

  final T value;
  final String label;
  final IconData? icon;
  final IconData? activeIcon;
}

/// A horizontally-scrolling row of outlined pills with a single active item —
/// used for the Posts filter tabs and the Analytics metric tabs.
class StudioPillBar<T> extends StatelessWidget {
  const StudioPillBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final List<StudioPillItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Pill(
                label: item.label,
                icon: (selected == item.value ? item.activeIcon : item.icon) ??
                    item.icon,
                active: selected == item.value,
                onTap: () => onSelected(item.value),
                cs: cs,
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    required this.cs,
  });

  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final fg = active ? cs.onPrimary : cs.onSurfaceVariant;
    return Material(
      color: active ? cs.primary : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: active ? cs.primary : cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact segmented control (e.g. the 7d / 30d / 60d range selector).
class StudioSegmented<T> extends StatelessWidget {
  const StudioSegmented({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<StudioPillItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items)
            GestureDetector(
              onTap: () => onSelected(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: selected == item.value ? cs.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected == item.value
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected == item.value
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
