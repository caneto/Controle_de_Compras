
// Esta linha é necessária para o gerador de código
import 'package:isar_community/isar.dart';
import 'category.dart';

part 'shopping_item.g.dart';

@collection
class ShoppingItem {
  Id id = Isar.autoIncrement; // O Isar gerencia o ID automaticamente

  late String name;
  
  late double price;
  
  int quantity = 1;
  
  bool isBought = false; // Checkbox de "comprado"

  DateTime createdAt = DateTime.now();
  String? barcode; // Novo campo para o código de barras
  
  // Relacionamento com Categoria (referência lazy)
  final category = IsarLink<Category>();
}