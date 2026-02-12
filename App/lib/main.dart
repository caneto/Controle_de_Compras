import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/home_screen.dart';
import 'services/isar_service.dart';
import 'blocs/shopping_list/shopping_list_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja inicializado antes de usar o Isar
  
  final isarService = IsarService(); // Cria uma única instância do serviço
  runApp(
    BlocProvider(
      create: (context) => ShoppingListBloc(isarService), // Injeta o BLoC
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Compras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}