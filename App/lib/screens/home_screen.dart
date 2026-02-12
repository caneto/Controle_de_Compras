import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/shopping_list/shopping_list_bloc.dart';
import '../collections/shopping_item.dart';
import '../collections/category.dart';
import 'scanner_screen.dart'; // Criaremos esta tela

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NumberFormat currencyFormatter = NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  void initState() {
    super.initState();
    // Dispara o evento inicial para carregar dados
    context.read<ShoppingListBloc>().add(LoadShoppingList());
    context.read<ShoppingListBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista de Compras'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => _showManageCategoriesDialog(context),
            tooltip: 'Gerenciar Categorias',
          ),
        ],
      ),
      body: BlocBuilder<ShoppingListBloc, ShoppingListState>(
        builder: (context, state) {
          if (state is ShoppingListLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ShoppingListError) {
            return Center(child: Text('Erro: ${state.message}'));
          }
          if (state is ShoppingListLoaded) {
            return Column(
              children: [
                // Totais do Carrinho
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTotalColumn('Total Geral', state.totalValue, Colors.green),
                          _buildTotalColumn('Total Comprado', state.totalBoughtValue, Colors.blue),
                        ],
                      ),
                    ),
                  ),
                ),
                // Categorias (Horizontal Scroll)
                if (state.categories.isNotEmpty)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: state.categories.length + 1, // +1 para "Todos"
                      itemBuilder: (ctx, i) {
                        if (i == 0) {
                          return _buildCategoryChip('Todos', null);
                        }
                        final category = state.categories[i - 1];
                        return _buildCategoryChip(category.name, category.id);
                      },
                    ),
                  ),
                const Divider(),
                // Lista de Itens
                Expanded(
                  child: state.items.isEmpty
                      ? const Center(child: Text('Nenhum item na lista.'))
                      : ListView.separated(
                          itemCount: state.items.length,
                          separatorBuilder: (ctx, i) => const Divider(indent: 16, endIndent: 16),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return ListTile(
                              leading: Checkbox(
                                value: item.isBought,
                                onChanged: (bool? value) {
                                  context.read<ShoppingListBloc>().add(ToggleItemStatus(item));
                                },
                              ),
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  decoration: item.isBought ? TextDecoration.lineThrough : null,
                                  color: item.isBought ? Colors.grey : Colors.black,
                                ),
                              ),
                              subtitle: Text(
                                '${item.quantity}x - ${currencyFormatter.format(item.price)} '
                                '${item.category.value != null ? '(${item.category.value!.name})' : ''}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  context.read<ShoppingListBloc>().add(DeleteShoppingItem(item.id!));
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalColumn(String title, double value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
        Text(
          currencyFormatter.format(value),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String name, int? categoryId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(name),
        selected: false, // Lógica de seleção futura se quiser filtrar
        onSelected: (selected) {
          // TODO: Implementar filtro por categoria no BLoC
          debugPrint('Filtrar por $name (ID: $categoryId)');
        },
      ),
    );
  }

  // --- Diálogos e Telas Auxiliares ---

  Future<void> _showAddItemDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtdController = TextEditingController(text: '1');
    final barcodeController = TextEditingController();
    Category? selectedCategory;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocBuilder<ShoppingListBloc, ShoppingListState>(
        builder: (context, state) {
          final categories = (state is ShoppingListLoaded) ? state.categories : <Category>[];
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Novo Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome do Produto'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Preço (R\$)'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: qtdController,
                        decoration: const InputDecoration(labelText: 'Quantidade'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Campo de Código de Barras com botão de scanner
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: barcodeController,
                        decoration: const InputDecoration(labelText: 'Código de Barras'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.barcode_reader),
                      onPressed: () async {
                        final scannedBarcode = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(builder: (c) => const ScannerScreen()),
                        );
                        if (scannedBarcode != null) {
                          barcodeController.text = scannedBarcode;
                          // Opcional: buscar produto em uma API/DB por este código
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Seletor de Categoria
                DropdownButtonFormField<Category>(
                  initialValue: selectedCategory,
                  hint: const Text('Selecionar Categoria'),
                  items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
                  onChanged: (cat) => selectedCategory = cat,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      context.read<ShoppingListBloc>().add(
                            AddShoppingItem(
                              name: nameController.text,
                              price: double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0,
                              quantity: int.tryParse(qtdController.text) ?? 1,
                              barcode: barcodeController.text.isNotEmpty ? barcodeController.text : null,
                              category: selectedCategory,
                            ),
                          );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('ADICIONAR'),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _showManageCategoriesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gerenciar Categorias'),
        content: BlocBuilder<ShoppingListBloc, ShoppingListState>(
          builder: (context, state) {
            if (state is! ShoppingListLoaded) return const CircularProgressIndicator();
            final categories = state.categories;
            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        context.read<ShoppingListBloc>().add(DeleteCategory(category.id));
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () => _showAddCategoryDialog(context),
            child: const Text('Adicionar Nova'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final categoryNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Categoria'),
        content: TextField(
          controller: categoryNameController,
          decoration: const InputDecoration(labelText: 'Nome da Categoria'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (categoryNameController.text.isNotEmpty) {
                context.read<ShoppingListBloc>().add(AddCategory(categoryNameController.text));
                Navigator.pop(ctx); // Fecha o dialog de adicionar categoria
                Navigator.pop(ctx); // Fecha o dialog de gerenciar categorias
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}