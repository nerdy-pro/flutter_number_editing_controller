import 'package:flutter/material.dart';
import 'package:number_editing_controller_example/variants/currency_input.dart';
import 'package:number_editing_controller_example/variants/decimal_input.dart';
import 'package:number_editing_controller_example/variants/external_symbol_input.dart';
import 'package:number_editing_controller_example/variants/integer_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Editing Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Number Editing Controller'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Currency'),
              Tab(text: 'Integer'),
              Tab(text: 'Decimal'),
              Tab(text: 'Prefix/Suffix'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CurrencyInput(),
            IntegerInput(),
            DecimalInput(),
            ExternalSymbolInput(),
          ],
        ),
      ),
    );
  }
}
