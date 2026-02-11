import 'package:isar_community/isar.dart';

part 'shopping_item.g.dart';

@collection
class ShoppingItem {
  Id id = Isar.autoIncrement;

  late String name;

  double price = 0.0;

  bool isBought = false;

  DateTime createdAt = DateTime.now();
}
