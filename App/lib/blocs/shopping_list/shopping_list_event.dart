part of 'shopping_list_bloc.dart';

abstract class ShoppingListEvent extends Equatable {
  const ShoppingListEvent();
  @override
  List<Object> get props => [];
}

class LoadShoppingList extends ShoppingListEvent {
  final int? categoryId; // Para carregar por categoria
  const LoadShoppingList({this.categoryId});
}

class AddShoppingItem extends ShoppingListEvent {
  final String name;
  final double price;
  final int quantity;
  final String? barcode;
  final Category? category;
  const AddShoppingItem({
    required this.name,
    required this.price,
    required this.quantity,
    this.barcode,
    this.category,
  });
}

class ToggleItemStatus extends ShoppingListEvent {
  final ShoppingItem item;
  const ToggleItemStatus(this.item);
}

class DeleteShoppingItem extends ShoppingListEvent {
  final int itemId;
  const DeleteShoppingItem(this.itemId);
}


// Eventos de Categoria
class LoadCategories extends ShoppingListEvent {}
class AddCategory extends ShoppingListEvent {
  final String name;
  const AddCategory(this.name);
}
class DeleteCategory extends ShoppingListEvent {
  final int categoryId;
  const DeleteCategory(this.categoryId  );
}
