import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/shopping_list_bloc.dart';
import 'screens/home_screen.dart';
import 'services/isar_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Compras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: RepositoryProvider(
        create: (context) => IsarService(),
        child: BlocProvider(
          create: (context) =>
              ShoppingListBloc(context.read<IsarService>())
                ..add(LoadShoppingList()),
          child: const HomeScreen(),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
