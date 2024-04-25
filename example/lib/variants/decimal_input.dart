import 'package:flutter/material.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

class DecimalInput extends StatefulWidget {
  const DecimalInput({super.key});

  @override
  State<StatefulWidget> createState() => _DecimalInputState();
}

class _DecimalInputState extends State<DecimalInput> {
  final _controller = NumberEditingTextController.decimal(allowNegative: false);

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
                signed: false,
              ),
              controller: _controller,
            ),
          ),
        ],
      ),
    );
  }
}
