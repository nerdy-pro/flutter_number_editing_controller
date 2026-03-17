import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

/// Tests that verify the public API surface of NumberEditingTextController.
/// These must continue to pass after internal refactoring to guarantee
/// that no existing consumer code breaks.
void main() {
  group('Public API signature', () {
    group('NumberEditingTextController extends TextEditingController', () {
      test('is a TextEditingController', () {
        final controller = NumberEditingTextController.integer();
        expect(controller, isA<TextEditingController>());
      });

      test('is a ChangeNotifier', () {
        final controller = NumberEditingTextController.integer();
        expect(controller, isA<ChangeNotifier>());
      });
    });

    group('.currency constructor', () {
      test('accepts all named parameters', () {
        final controller = NumberEditingTextController.currency(
          locale: 'en',
          currencyName: 'USD',
          currencySymbol: '\$',
          value: 1.5,
          decimalSeparator: '.',
          groupSeparator: ',',
          allowNegative: false,
        );
        expect(controller, isA<NumberEditingTextController>());
      });

      test('all parameters are optional', () {
        final controller = NumberEditingTextController.currency();
        expect(controller, isA<NumberEditingTextController>());
      });
    });

    group('.decimal constructor', () {
      test('accepts all named parameters', () {
        final controller = NumberEditingTextController.decimal(
          locale: 'en',
          minimalFractionDigits: 2,
          maximumFractionDigits: 4,
          value: 3.14,
          decimalSeparator: '.',
          groupSeparator: ',',
          allowNegative: false,
        );
        expect(controller, isA<NumberEditingTextController>());
      });

      test('all parameters are optional', () {
        final controller = NumberEditingTextController.decimal();
        expect(controller, isA<NumberEditingTextController>());
      });
    });

    group('.integer constructor', () {
      test('accepts all named parameters', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: 42,
          groupSeparator: ',',
          allowNegative: false,
        );
        expect(controller, isA<NumberEditingTextController>());
      });

      test('all parameters are optional', () {
        final controller = NumberEditingTextController.integer();
        expect(controller, isA<NumberEditingTextController>());
      });
    });

    group('number getter/setter', () {
      test('getter returns num?', () {
        final controller = NumberEditingTextController.integer();
        final num? n = controller.number;
        expect(n, isNull);
      });

      test('setter accepts num?', () {
        final controller = NumberEditingTextController.integer();
        controller.number = 42;
        expect(controller.number, 42);

        controller.number = 3.14;
        expect(controller.number, 3.14);

        controller.number = null;
        expect(controller.number, isNull);
      });
    });

    group('value getter/setter (inherited)', () {
      test('getter returns TextEditingValue', () {
        final controller = NumberEditingTextController.integer();
        expect(controller.value, isA<TextEditingValue>());
      });

      test('setter accepts TextEditingValue and triggers formatting', () {
        final controller = NumberEditingTextController.integer(locale: 'en');
        controller.value = const TextEditingValue(
          text: '1234',
          selection: TextSelection.collapsed(offset: 4),
        );
        expect(controller.value.text, '1,234');
        expect(controller.number, 1234);
      });
    });

    group('text property (inherited)', () {
      test('returns formatted string', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: 1000,
        );
        expect(controller.text, isA<String>());
        expect(controller.text, '1,000');
      });
    });

    group('addListener/removeListener (inherited)', () {
      test('notifies listeners on value change', () {
        final controller = NumberEditingTextController.integer(locale: 'en');
        var called = false;
        void listener() => called = true;
        controller.addListener(listener);
        controller.number = 5;
        expect(called, isTrue);
        controller.removeListener(listener);
      });
    });

    group('constructor parameter defaults', () {
      test('currency defaults to allowNegative=true', () {
        final controller = NumberEditingTextController.currency(
          currencyName: 'USD',
          locale: 'en',
        );
        controller.value = const TextEditingValue(
          text: '-5',
          selection: TextSelection.collapsed(offset: 2),
        );
        expect(controller.number, -5);
      });

      test('decimal defaults to allowNegative=true', () {
        final controller = NumberEditingTextController.decimal(locale: 'en');
        controller.value = const TextEditingValue(
          text: '-3.5',
          selection: TextSelection.collapsed(offset: 4),
        );
        expect(controller.number, -3.5);
      });

      test('integer defaults to allowNegative=true', () {
        final controller = NumberEditingTextController.integer(locale: 'en');
        controller.value = const TextEditingValue(
          text: '-7',
          selection: TextSelection.collapsed(offset: 2),
        );
        expect(controller.number, -7);
      });
    });
  });
}
