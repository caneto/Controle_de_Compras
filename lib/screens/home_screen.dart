import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/isar_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IsarService service = IsarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Compras'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<ShoppingItem>>(
        stream: service.listenToShoppingItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.hasData) {
            final items = snapshot.data!;
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'Nenhum item na lista',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(
                      decoration: item.isBought
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text('R\$ ${item.price.toStringAsFixed(2)}'),
                  leading: Checkbox(
                    value: item.isBought,
                    onChanged: (value) {
                      service.toggleShoppingItemStatus(item);
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      service.deleteShoppingItem(item.id);
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
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

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
              onSubmitted: (_) =>
                  _submit(context, nameController, priceController),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _submit(context, nameController, priceController),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _submit(
    BuildContext context,
    TextEditingController nameController,
    TextEditingController priceController,
  ) {
    if (nameController.text.isNotEmpty) {
      final price =
          double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;
      final newItem = ShoppingItem()
        ..name = nameController.text
        ..price = price;
      service.saveShoppingItem(newItem);
      Navigator.pop(context);
    }
  }
}
