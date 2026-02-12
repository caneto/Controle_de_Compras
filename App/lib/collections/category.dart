import 'package:isar_community/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  List<String>? imageUrls; // Para imagens representativas da categoria

  Category({required this.name, this.description, this.imageUrls});
}