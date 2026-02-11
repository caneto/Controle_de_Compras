import 'package:isar_community/isar.dart';

part 'item.g.dart';

@collection
class Item {
  Id id = Isar.autoIncrement;

  late String name;

  bool isBought = false;
}
