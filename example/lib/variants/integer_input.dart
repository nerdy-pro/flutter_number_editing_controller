import 'package:flutter/material.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

class IntegerInput extends StatefulWidget {
  const IntegerInput({super.key});

  @override
  State<StatefulWidget> createState() => _IntegerInputState();
}

class _IntegerInputState extends State<IntegerInput> {
  final _controller = IntegerEditingController(locale: 'en');

  bool _allowNegative = true;

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
            SwitchListTile(
              title: const Text('Allow negative'),
              value: _allowNegative,
              onChanged: (value) {
                setState(() {
                  _allowNegative = value;
                  _controller.allowNegative = value;
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
              keyboardType: TextInputType.numberWithOptions(
                signed: _allowNegative,
              ),
              controller: _controller,
            ),
          ],
        ),
      ),
    );
  }
}
