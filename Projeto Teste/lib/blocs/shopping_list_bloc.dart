import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/shopping_item.dart';
import '../services/isar_service.dart';

// Events
abstract class ShoppingListEvent extends Equatable {
  const ShoppingListEvent();

  @override
  List<Object> get props => [];
}

class LoadShoppingList extends ShoppingListEvent {}

class AddShoppingItem extends ShoppingListEvent {
  final String name;
  final double price;
  final String category;

  const AddShoppingItem(this.name, this.price, this.category);

  @override
  List<Object> get props => [name, price, category];
}

class DeleteShoppingItem extends ShoppingListEvent {
  final int id;

  const DeleteShoppingItem(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleShoppingItem extends ShoppingListEvent {
  final ShoppingItem item;

  const ToggleShoppingItem(this.item);

  @override
  List<Object> get props => [item];
}

class ScanBarcodeEvent extends ShoppingListEvent {
  final String barcode;

  const ScanBarcodeEvent(this.barcode);

  @override
  List<Object> get props => [barcode];
}

// States
enum ShoppingListStatus { initial, loading, success, failure }

class ShoppingListState extends Equatable {
  final ShoppingListStatus status;
  final List<ShoppingItem> items;
  final double totalPrice;

  const ShoppingListState({
    this.status = ShoppingListStatus.initial,
    this.items = const [],
    this.totalPrice = 0.0,
  });

  ShoppingListState copyWith({
    ShoppingListStatus? status,
    List<ShoppingItem>? items,
    double? totalPrice,
  }) {
    return ShoppingListState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  List<Object> get props => [status, items, totalPrice];
}

// Bloc
class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final IsarService _service;

  ShoppingListBloc(this._service) : super(const ShoppingListState()) {
    on<LoadShoppingList>(_onLoadShoppingList);
    on<AddShoppingItem>(_onAddShoppingItem);
    on<DeleteShoppingItem>(_onDeleteShoppingItem);
    on<ToggleShoppingItem>(_onToggleShoppingItem);
    on<ScanBarcodeEvent>(_onScanBarcode);
  }

  Future<void> _onLoadShoppingList(
    LoadShoppingList event,
    Emitter<ShoppingListState> emit,
  ) async {
    emit(state.copyWith(status: ShoppingListStatus.loading));
    await emit.forEach(
      _service.listenToShoppingItems(),
      onData: (items) => state.copyWith(
        status: ShoppingListStatus.success,
        items: items,
        totalPrice: _calculateTotal(items),
      ),
      onError: (_, __) => state.copyWith(status: ShoppingListStatus.failure),
    );
  }

  Future<void> _onAddShoppingItem(
    AddShoppingItem event,
    Emitter<ShoppingListState> emit,
  ) async {
    final newItem = ShoppingItem()
      ..name = event.name
      ..price = event.price
      ..category = event.category;
    await _service.saveShoppingItem(newItem);
  }

  Future<void> _onDeleteShoppingItem(
    DeleteShoppingItem event,
    Emitter<ShoppingListState> emit,
  ) async {
    await _service.deleteShoppingItem(event.id);
  }

  Future<void> _onToggleShoppingItem(
    ToggleShoppingItem event,
    Emitter<ShoppingListState> emit,
  ) async {
    await _service.toggleShoppingItemStatus(event.item);
  }

  Future<void> _onScanBarcode(
    ScanBarcodeEvent event,
    Emitter<ShoppingListState> emit,
  ) async {
    // In a real app, we would fetch product details from an API using the barcode.
    // For now, we'll just add a placeholder item.
    if (event.barcode != '-1' && event.barcode.isNotEmpty) {
      final newItem = ShoppingItem()
        ..name = 'Produto ${event.barcode}'
        ..price = 0.0
        ..category = 'Outros';
      await _service.saveShoppingItem(newItem);
    }
  }

  double _calculateTotal(List<ShoppingItem> items) {
    // Calculate total price of *checked* items (items in cart)
    return items
        .where((item) => item.isBought)
        .fold(0.0, (sum, item) => sum + item.price);
  }
}
