import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/item.dart';
import '../models/shopping_item.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDb();
  }

  Future<Isar> openDb() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [ItemSchema, ShoppingItemSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // --- Item Methods (Legacy) ---
  Future<void> saveItem(Item newItem) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.items.putSync(newItem));
  }

  Stream<List<Item>> listenToItems() async* {
    final isar = await db;
    yield* isar.items.where().watch(fireImmediately: true);
  }

  Future<void> deleteItem(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.items.delete(id);
    });
  }

  Future<void> toggleStatus(Item item) async {
    final isar = await db;
    await isar.writeTxn(() async {
      item.isBought = !item.isBought;
      await isar.items.put(item);
    });
  }

  // --- ShoppingItem Methods ---

  Future<void> saveShoppingItem(ShoppingItem newItem) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.shoppingItems.putSync(newItem));
  }

  Stream<List<ShoppingItem>> listenToShoppingItems() async* {
    final isar = await db;
    yield* isar.shoppingItems.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  Future<void> deleteShoppingItem(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.shoppingItems.delete(id);
    });
  }

  Future<void> toggleShoppingItemStatus(ShoppingItem item) async {
    final isar = await db;
    await isar.writeTxn(() async {
      item.isBought = !item.isBought;
      await isar.shoppingItems.put(item);
    });
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}
