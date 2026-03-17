import 'package:flutter/material.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

class ExternalSymbolInput extends StatefulWidget {
  const ExternalSymbolInput({super.key});

  @override
  State<ExternalSymbolInput> createState() => _ExternalSymbolInputState();
}

class _ExternalSymbolInputState extends State<ExternalSymbolInput> {
  final _controller = CurrencyEditingController(
    locale: 'en',
    showCurrencySymbol: false,
  );

  String _selectedLocale = 'en';

  static const _locales = ['en', 'de', 'fr', 'ja', 'ru'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPrefix = _controller.currencySymbolPosition ==
        CurrencySymbolPosition.prefix;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedLocale,
              items: _locales
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedLocale = value;
                  _controller.locale = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Symbol: ${_controller.resolvedCurrencySymbol}'
              '  Position: ${_controller.currencySymbolPosition.name}',
              style: Theme.of(context).textTheme.bodySmall,
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
              decoration: InputDecoration(
                prefixText: isPrefix
                    ? _controller.resolvedCurrencySymbol
                    : null,
                suffixText: isPrefix
                    ? null
                    : _controller.resolvedCurrencySymbol,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
