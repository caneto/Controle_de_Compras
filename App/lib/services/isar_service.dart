import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../collections/shopping_item.dart';
import '../collections/category.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [ShoppingItemSchema, CategorySchema],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // 1. Salvar ou Atualizar Item
  Future<void> saveItem(ShoppingItem item) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.shoppingItems.put(item);
      // Se o item tem categoria, salve a categoria também se for nova
      await item.category.save(); 
    });
  }

  // 2. Ler todos os itens (Stream permite atualização em tempo real)
  Stream<List<ShoppingItem>> listenToItems({int? categoryId}) async* {
    final isar = await db;
    // Filtra por categoria, se fornecido
    if (categoryId != null) {
      yield* isar.shoppingItems
          .filter()
          .category((q) => q.idEqualTo(categoryId))
          .sortByCreatedAtDesc()
          .watch(fireImmediately: true);
    } else {
      yield* isar.shoppingItems.where().sortByCreatedAtDesc().watch(fireImmediately: true);
    }
  }

  Future<ShoppingItem?> getItemByBarcode(String barcode) async {
    final isar = await db;
    return await isar.shoppingItems.filter().barcodeEqualTo(barcode).findFirst();
  }

  // 3. Marcar como comprado/não comprado
  Future<void> toggleStatus(ShoppingItem item) async {
    final isar = await db;
    item.isBought = !item.isBought;
    await isar.writeTxn(() async {
      await isar.shoppingItems.put(item);
    });
  }

  // 4. Deletar item
  Future<void> deleteItem(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.shoppingItems.delete(id);
    });
  }

  Future<void> saveCategory(Category category) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.categorys.put(category);
    });
  }

  Stream<List<Category>> listenToCategories() async* {
    final isar = await db;
    yield* isar.categorys.where().sortByName().watch(fireImmediately: true);
  }

  Future<void> deleteCategory(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // Opcional: Se quiser, adicione lógica para lidar com itens nesta categoria
      await isar.categorys.delete(id);
    });
  }
}