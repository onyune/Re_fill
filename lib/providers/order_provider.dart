import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  List<Map<String, dynamic>> items = [];

  void setItems(List<Map<String, dynamic>> newItems) {
    items = newItems;
    notifyListeners();
  }

  void updateItemCount(String name, int count) {
    final index = items.indexWhere((item) => item['name'] == name);
    if (index != -1) {
      items[index]['count'] = count;
      notifyListeners();
    }
  }

  void increaseItemCount(String name, int delta) {
    final index = items.indexWhere((item) => item['name'] == name);
    if (index != -1) {
      items[index]['count'] += delta;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getItems() => items;
}
