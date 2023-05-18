import 'package:flutter/rendering.dart';
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
  test('some decimal', () {
    final controller = NumberEditingTextController.decimal(
      locale: 'de',
      maximumFractionDigits: 6,
    );
    controller.number = -100.51241;
    expect(controller.value, const TextEditingValue(text: '-100,51241'));
    expect(controller.number, -100.51241);
  });
  test('some decimal but provided integer', () {
    final controller = NumberEditingTextController.decimal(
      locale: 'de',
      maximumFractionDigits: 6,
    );
    controller.number = -1100;
    expect(controller.value, const TextEditingValue(text: '-1.100'));
    expect(controller.number, -1100);
  });
  test('some integer', () {
    final controller = NumberEditingTextController.integer(
      locale: 'de',
    );
    controller.number = -100;
    expect(controller.value, const TextEditingValue(text: '-100'));
    expect(controller.number, -100);
  });
  test('zero-based currency editing', () {
    final controller = NumberEditingTextController.currency(
      currencyName: 'USD',
      locale: 'en',
    );
    controller.number = 1;
    expect(
      controller.value,
      const TextEditingValue(
        text: '\$1',
      ),
    );

    controller.value = controller.value.copyWith(
      text: '\$',
      selection: const TextSelection.collapsed(offset: 1),
    );
    expect(
      controller.value,
      const TextEditingValue(
        text: '\$',
        selection: TextSelection.collapsed(
          offset: 1,
        ),
      ),
    );
    expect(controller.number, null);
  });
  test('zero-based currency editing with trailing symbol', () {
    final controller = NumberEditingTextController.currency(
      currencyName: 'USD',
      locale: 'ru',
    );
    controller.number = 1;
    expect(
      controller.value,
      const TextEditingValue(
        text: '1 \$',
      ),
    );

    controller.value = controller.value.copyWith(
      text: ' \$',
      selection: const TextSelection.collapsed(offset: 0),
    );
    expect(
      controller.value,
      const TextEditingValue(
        text: ' \$',
        selection: TextSelection.collapsed(
          offset: 0,
        ),
      ),
    );
    expect(controller.number, null);
  });
}
