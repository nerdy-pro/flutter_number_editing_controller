import 'package:flutter/material.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

class CurrencyInput extends StatefulWidget {
  const CurrencyInput({super.key});

  @override
  State<StatefulWidget> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  final _controller = CurrencyEditingController(
    currencyName: 'USD',
    locale: 'en',
  );

  String _selectedCurrency = 'USD';

  static const _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'TRY'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedCurrency,
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCurrency = value;
                  _controller.currencyName = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('You have entered:'),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, child) {
                return Text(
                  '${_controller.number ?? 0}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              controller: _controller,
            ),
          ],
        ),
      ),
    );
  }
}
