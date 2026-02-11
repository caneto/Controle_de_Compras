import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar moeda
import '../services/isar_service.dart';
import '../collections/shopping_item.dart';

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
        title: const Text('Minha Lista de Compras'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<ShoppingItem>>(
        stream: service.listenToItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('Nenhum item na lista.'));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Checkbox(
                  value: item.isBought,
                  onChanged: (bool? value) {
                    service.toggleStatus(item);
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
                  '${item.quantity}x - ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(item.price)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => service.deleteItem(item.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Pequeno modal para adicionar itens
  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtdController = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Para o teclado não cobrir
      builder: (context) => Padding(
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
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newItem = ShoppingItem()
                    ..name = nameController.text
                    ..price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0
                    ..quantity = int.tryParse(qtdController.text) ?? 1;
                  
                  service.saveItem(newItem);
                  Navigator.pop(context);
                }
              },
              child: const Text('ADICIONAR'),
            )
          ],
        ),
      ),
    );
  }
}