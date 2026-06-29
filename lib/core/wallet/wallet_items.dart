import '../../features/ids/domain/id_document.dart';
import '../../features/passport/domain/passport_profile.dart';

/// Stable id for any item shown in the wallet carousel or manage list.
String walletItemId(Object item) {
  return switch (item) {
    PassportProfile profile => profile.id,
    IdDocument document => document.id,
    _ => throw ArgumentError('Unknown wallet item type: ${item.runtimeType}'),
  };
}

/// All ids currently stored in passport and ID lists.
List<String> activeWalletItemIds({
  required List<PassportProfile> passports,
  required List<IdDocument> idDocs,
}) {
  return [
    ...passports.map((p) => p.id),
    ...idDocs.map((d) => d.id),
  ];
}

/// Merges passports and ID documents, then sorts by persisted wallet order.
List<Object> sortWalletItems({
  required List<PassportProfile> passports,
  required List<IdDocument> idDocs,
  required List<String> order,
}) {
  final items = <Object>[...passports, ...idDocs];
  items.sort((a, b) {
    final int idxA = order.indexOf(walletItemId(a));
    final int idxB = order.indexOf(walletItemId(b));
    return (idxA == -1 ? 9999 : idxA).compareTo(idxB == -1 ? 9999 : idxB);
  });
  return items;
}

/// Keeps stored order in sync when items are added or removed.
List<String> reconcileWalletOrder({
  required List<String> order,
  required List<String> activeIds,
}) {
  final reconciled = [...order];
  reconciled.removeWhere((id) => !activeIds.contains(id));
  final missing = activeIds.where((id) => !reconciled.contains(id)).toList();
  if (missing.isNotEmpty) {
    reconciled.addAll(missing);
  }
  return reconciled;
}