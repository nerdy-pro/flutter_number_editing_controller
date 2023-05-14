import 'package:flutter_test/flutter_test.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

void main() {
  test('empty state', () {
    final controller = NumberEditingTextController.currency(
      currencyName: 'EUR',
    );
    expect(controller.value, const TextEditingValue(text: ''));
    expect(controller.number, null);
  });
  test('some amount', () {
    final controller = NumberEditingTextController.currency(
      currencyName: 'EUR',
    );
    controller.number = 10.5;
    expect(controller.value, const TextEditingValue(text: '€10.5'));
    expect(controller.number, 10.5);
  });
  test('some amount in DE locale', () {
    final controller = NumberEditingTextController.currency(
      currencyName: 'GBP',
      locale: 'de',
    );
    controller.number = -5000.5;
    expect(controller.value, const TextEditingValue(text: '-5.000,5 £'));
    expect(controller.number, -5000.5);
  });
}
