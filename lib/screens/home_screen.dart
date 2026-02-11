import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../blocs/shopping_list_bloc.dart';
import '../models/shopping_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Compras'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              var res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SimpleBarcodeScannerPage(),
                ),
              );
              if (res is String && res != '-1') {
                if (context.mounted) {
                  context.read<ShoppingListBloc>().add(ScanBarcodeEvent(res));
                }
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ShoppingListBloc, ShoppingListState>(
        builder: (context, state) {
          if (state.status == ShoppingListStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == ShoppingListStatus.failure) {
            return const Center(child: Text('Erro ao carregar lista'));
          }

          if (state.items.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum item na lista',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Group items by category (optional, but requested "logic separation" - simple grouping here for UI)
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isBought
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${item.category} - R\$ ${item.price.toStringAsFixed(2)}',
                      ),
                      leading: Checkbox(
                        value: item.isBought,
                        onChanged: (value) {
                          context.read<ShoppingListBloc>().add(
                            ToggleShoppingItem(item),
                          );
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          context.read<ShoppingListBloc>().add(
                            DeleteShoppingItem(item.id),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total do Carrinho:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'R\$ ${state.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddItemDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext rootContext) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'Outros';
    final categories = [
      'Hortifruti',
      'Biscoitos',
      'Bebidas',
      'Limpeza',
      'Outros',
    ];

    showDialog(
      context: rootContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Nome do item'),
                autofocus: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(hintText: 'Preço (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final price =
                      double.tryParse(
                        priceController.text.replaceAll(',', '.'),
                      ) ??
                      0.0;
                  rootContext.read<ShoppingListBloc>().add(
                    AddShoppingItem(
                      nameController.text,
                      price,
                      selectedCategory,
                    ),
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
