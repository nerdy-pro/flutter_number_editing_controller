import 'package:flutter/material.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

class DecimalInput extends StatefulWidget {
  const DecimalInput({super.key});

  @override
  State<StatefulWidget> createState() => _DecimalInputState();
}

class _DecimalInputState extends State<DecimalInput> {
  final _controller = DecimalEditingController(
    locale: 'en',
    maximumFractionDigits: 4,
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
