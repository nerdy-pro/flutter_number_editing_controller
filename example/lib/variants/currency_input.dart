import 'package:flutter/material.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

class CurrencyInput extends StatefulWidget {
  const CurrencyInput({super.key});

  @override
  State<StatefulWidget> createState() => _CurrencyInputState();
}

class _CurrencyInputState extends State<CurrencyInput> {
  final _controller = NumberEditingTextController.currency(
    currencyName: 'JPY',
    allowNegative: false,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'You have entered:',
          ),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, child) {
              return Text(
                '${_controller.number ?? 0}',
                style: Theme.of(context).textTheme.headlineMedium,
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}
