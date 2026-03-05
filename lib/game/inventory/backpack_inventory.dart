import 'package:flutter/foundation.dart';

import 'backpack_item.dart';

class BackpackInventory {
  BackpackInventory({List<BackpackItem>? initialItems})
    : _itemsNotifier = ValueNotifier<List<BackpackItem>>(
        List.unmodifiable(initialItems ?? const <BackpackItem>[]),
      );

  final ValueNotifier<List<BackpackItem>> _itemsNotifier;

  ValueListenable<List<BackpackItem>> get itemsListenable => _itemsNotifier;

  List<BackpackItem> get items => List.unmodifiable(_itemsNotifier.value);

  void addItem(BackpackItem item) {
    final current = List<BackpackItem>.from(_itemsNotifier.value);
    final index = current.indexWhere((entry) => entry.id == item.id);

    if (index >= 0) {
      final existing = current[index];
      current[index] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
    } else {
      current.add(item);
    }

    _itemsNotifier.value = List.unmodifiable(current);
  }

  void removeOne(String itemId) {
    final current = List<BackpackItem>.from(_itemsNotifier.value);
    final index = current.indexWhere((entry) => entry.id == itemId);
    if (index < 0) return;

    final existing = current[index];
    if (existing.quantity <= 1) {
      current.removeAt(index);
    } else {
      current[index] = existing.copyWith(quantity: existing.quantity - 1);
    }

    _itemsNotifier.value = List.unmodifiable(current);
  }

  void clear() {
    _itemsNotifier.value = const <BackpackItem>[];
  }
}
