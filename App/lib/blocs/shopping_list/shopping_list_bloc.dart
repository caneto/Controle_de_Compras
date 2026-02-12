import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../collections/shopping_item.dart';
import '../../collections/category.dart';
import '../../services/isar_service.dart';

part 'shopping_list_event.dart';
part 'shopping_list_state.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  final IsarService _isarService;
  StreamSubscription? _itemsSubscription;
  StreamSubscription? _categoriesSubscription;

  ShoppingListBloc(this._isarService) : super(ShoppingListLoading()) {
    on<LoadShoppingList>(_onLoadShoppingList);
    on<AddShoppingItem>(_onAddShoppingItem);
    on<ToggleItemStatus>(_onToggleItemStatus);
    on<DeleteShoppingItem>(_onDeleteShoppingItem);
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<DeleteCategory>(_onDeleteCategory);

    // Começa a ouvir os streams do Isar assim que o BLoC é criado
    _itemsSubscription = _isarService.listenToItems().listen((items) {
      _updateStateWithItems(items);
    });
    _categoriesSubscription = _isarService.listenToCategories().listen((categories) {
      _updateStateWithCategories(categories);
    });
  }

  // Descalcula os totais
  void _updateStateWithItems(List<ShoppingItem> items) {
    final total = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    final totalBought = items.where((item) => item.isBought).fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    if (state is ShoppingListLoaded) {
      emit((state as ShoppingListLoaded).copyWith(
        items: items,
        totalValue: total,
        totalBoughtValue: totalBought,
      ));
    } else {
      emit(ShoppingListLoaded(
        items: items,
        totalValue: total,
        totalBoughtValue: totalBought,
        categories: (state is ShoppingListLoaded) ? (state as ShoppingListLoaded).categories : [],
      ));
    }
  }

  void _updateStateWithCategories(List<Category> categories) {
    if (state is ShoppingListLoaded) {
      emit((state as ShoppingListLoaded).copyWith(categories: categories));
    } else {
      emit(ShoppingListLoaded(categories: categories));
    }
  }

  Future<void> _onLoadShoppingList(LoadShoppingList event, Emitter<ShoppingListState> emit) async {
    // A lógica de carregamento inicial já está nos streams, aqui podemos apenas emitir o estado atual
    // Ou re-emitir um loading para "forçar" um refresh visual
    emit(ShoppingListLoading());
    // Os listeners já vão atualizar o estado para Loaded
  }

  Future<void> _onAddShoppingItem(AddShoppingItem event, Emitter<ShoppingListState> emit) async {
    try {
      final newItem = ShoppingItem()
        ..name = event.name
        ..price = event.price
        ..quantity = event.quantity
        ..barcode = event.barcode;
      
      // Ligar o item à categoria, se houver
      if (event.category != null) {
        newItem.category.value = event.category;
      }
      
      await _isarService.saveItem(newItem);
    } catch (e) {
      emit(ShoppingListError("Falha ao adicionar item: $e"));
    }
  }

  Future<void> _onToggleItemStatus(ToggleItemStatus event, Emitter<ShoppingListState> emit) async {
    try {
      await _isarService.toggleStatus(event.item);
    } catch (e) {
      emit(ShoppingListError("Falha ao atualizar status: $e"));
    }
  }

  Future<void> _onDeleteShoppingItem(DeleteShoppingItem event, Emitter<ShoppingListState> emit) async {
    try {
      await _isarService.deleteItem(event.itemId);
    } catch (e) {
      emit(ShoppingListError("Falha ao deletar item: $e"));
    }
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<ShoppingListState> emit) async {
    // Já está sendo ouvido via stream, mas pode ser usado para um refresh manual
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<ShoppingListState> emit) async {
    try {
      final newCategory = Category(name: event.name);
      await _isarService.saveCategory(newCategory);
    } catch (e) {
      emit(ShoppingListError("Falha ao adicionar categoria: $e"));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<ShoppingListState> emit) async {
    try {
      await _isarService.deleteCategory(event.categoryId);
    } catch (e) {
      emit(ShoppingListError("Falha ao deletar categoria: $e"));
    }
  }

  @override
  Future<void> close() {
    _itemsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    return super.close();
  }
}