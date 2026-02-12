part of 'shopping_list_bloc.dart';

abstract class ShoppingListState extends Equatable {
  const ShoppingListState();
  @override
  List<Object> get props => [];
}

class ShoppingListLoading extends ShoppingListState {}

class ShoppingListLoaded extends ShoppingListState {
  final List<ShoppingItem> items;
  final List<Category> categories;
  final double totalValue;
  final double totalBoughtValue;

  const ShoppingListLoaded({
    this.items = const [],
    this.categories = const [],
    this.totalValue = 0.0,
    this.totalBoughtValue = 0.0,
  });

  ShoppingListLoaded copyWith({
    List<ShoppingItem>? items,
    List<Category>? categories,
    double? totalValue,
    double? totalBoughtValue,
  }) {
    return ShoppingListLoaded(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      totalValue: totalValue ?? this.totalValue,
      totalBoughtValue: totalBoughtValue ?? this.totalBoughtValue,
    );
  }

  @override
  List<Object> get props => [items, categories, totalValue, totalBoughtValue];
}

class ShoppingListError extends ShoppingListState {
  final String message;
  const ShoppingListError(this.message);
}