import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/haptics/haptic_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/wallet/wallet_items.dart';

import '../../../ids/domain/id_document.dart';
import '../../../ids/domain/id_document_catalog.dart';
import '../../../passport/domain/passport_profile.dart';
import '../../application/wallet_order_provider.dart';

class _ManageItemMeta {
  const _ManageItemMeta({
    required this.title,
    required this.subtitle,
    required this.typeLabel,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String typeLabel;
  final IconData icon;
  final Color iconColor;
}

_ManageItemMeta _metaForItem(Object item) {
  if (item is PassportProfile) {
    final String firstName =
        item.name.isEmpty ? '' : item.name.split(' ').first;
    return _ManageItemMeta(
      title: firstName.isEmpty ? 'Passport' : "$firstName's Passport",
      subtitle: item.passportNumber.isEmpty ? 'No number added' : item.passportNumber,
      typeLabel: 'Passport',
      icon: CupertinoIcons.book_fill,
      iconColor: const Color(0xFF007AFF),
    );
  }

  final IdDocument d = item as IdDocument;
  final String firstName =
      d.holderName.isEmpty ? '' : d.holderName.split(' ').first;
  final descriptor = IdDocumentCatalog.descriptorFor(d.type);

  return _ManageItemMeta(
    title: firstName.isEmpty ? descriptor.title : "$firstName's ID",
    subtitle: d.documentNumber.isEmpty ? 'No number added' : d.documentNumber,
    typeLabel: descriptor.shortLabel,
    icon: CupertinoIcons.creditcard_fill,
    iconColor: descriptor.accentColor,
  );
}

class ManageCardsView extends ConsumerWidget {
  const ManageCardsView({
    super.key,
    required this.items,
  });

  final List<Object> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color ink = theme.colorScheme.onSurface;
    final Color muted = ink.withValues(alpha: isDark ? 0.45 : 0.55);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.creditcard,
                  size: 36,
                  color: muted,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No cards in wallet',
                style: theme.textTheme.titleMedium?.copyWith(color: ink),
              ),
              const SizedBox(height: 8),
              Text(
                'Cards you add on Home will appear here so you can reorder them.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final Color surface = theme.colorScheme.surface;
    final Color borderColor = ink.withValues(alpha: isDark ? 0.08 : 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet order',
                style: theme.textTheme.titleSmall?.copyWith(color: ink),
              ),
              const SizedBox(height: 4),
              Text(
                'Drag to reorder how cards appear on Home.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                          spreadRadius: -4,
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface,
                    border: Border.all(color: borderColor, width: 0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  ),
                  child: Theme(
                    data: theme.copyWith(
                      canvasColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: ReorderableListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      onReorder: (oldIndex, newIndex) {
                        HapticService.reorder();
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        final List<String> currentIds =
                            items.map(walletItemId).toList();

                        final String movedId = currentIds.removeAt(oldIndex);
                        currentIds.insert(newIndex, movedId);
                        ref.read(walletOrderProvider.notifier).saveOrder(currentIds);
                      },
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final String id = walletItemId(item);

                        return ManageCardTile(
                          key: ValueKey(id),
                          item: item,
                          index: index,
                          isLast: index == items.length - 1,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ManageCardTile extends StatelessWidget {
  const ManageCardTile({
    super.key,
    required this.item,
    required this.index,
    required this.isLast,
  });

  final Object item;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color ink = theme.colorScheme.onSurface;
    final Color muted = ink.withValues(alpha: isDark ? 0.45 : 0.55);
    final _ManageItemMeta meta = _metaForItem(item);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: meta.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(meta.icon, color: meta.iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              meta.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TypeChip(label: meta.typeLabel, color: meta.iconColor),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        meta.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.drag_handle_rounded,
                      color: muted,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const _ManageRowDivider(),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _ManageRowDivider extends StatelessWidget {
  const _ManageRowDivider();

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = Theme.of(context)
        .colorScheme
        .onSurface
        .withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.08 : 0.06);

    return Padding(
      padding: const EdgeInsets.only(left: 64),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: dividerColor,
      ),
    );
  }
}