import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../collections/shopping_item.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [ShoppingItemSchema], // Schema gerado automaticamente
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
    });
  }

  // 2. Ler todos os itens (Stream permite atualização em tempo real)
  Stream<List<ShoppingItem>> listenToItems() async* {
    final isar = await db;
    // Retorna os itens e fica "ouvindo" mudanças no banco
    yield* isar.shoppingItems.where().sortByCreatedAtDesc().watch(fireImmediately: true);
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
}