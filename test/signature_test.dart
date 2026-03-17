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

    group('mutable locale', () {
      test('changing locale reformats integer', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: 1234567,
        );
        expect(controller.text, '1,234,567');
        controller.locale = 'de';
        expect(controller.text, '1.234.567');
        expect(controller.number, 1234567);
      });

      test('changing locale reformats currency', () {
        final controller = NumberEditingTextController.currency(
          locale: 'en',
          currencyName: 'EUR',
          value: 1234.56,
        );
        expect(controller.text, '€1,234.56');
        controller.locale = 'de';
        expect(controller.text, '1.234,56\u00A0€');
        expect(controller.number, 1234.56);
      });

      test('changing locale reformats decimal', () {
        final controller = NumberEditingTextController.decimal(
          locale: 'en',
          value: 1234.5,
        );
        expect(controller.text, '1,234.5');
        controller.locale = 'de';
        expect(controller.text, '1.234,5');
        expect(controller.number, 1234.5);
      });

      test('setting same locale does not notify listeners', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: 100,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.locale = 'en';
        expect(callCount, 0);
      });

      test('changing locale with null value keeps null', () {
        final controller = NumberEditingTextController.integer(locale: 'en');
        expect(controller.number, isNull);
        controller.locale = 'de';
        expect(controller.number, isNull);
        expect(controller.text, '');
      });

      test('getter returns current locale', () {
        final controller = NumberEditingTextController.integer(locale: 'en');
        expect(controller.locale, 'en');
        controller.locale = 'fr';
        expect(controller.locale, 'fr');
      });
    });

    group('mutable groupSeparator', () {
      test('changing group separator reformats integer', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: 1234567,
        );
        expect(controller.text, '1,234,567');
        controller.groupSeparator = ' ';
        expect(controller.text, '1 234 567');
        expect(controller.number, 1234567);
      });

      test('changing group separator reformats currency', () {
        final controller = NumberEditingTextController.currency(
          locale: 'en',
          currencyName: 'USD',
          value: 5000,
        );
        expect(controller.text, '\$5,000');
        controller.groupSeparator = '.';
        expect(controller.text, '\$5.000');
        expect(controller.number, 5000);
      });

      test('changing group separator reformats decimal', () {
        final controller = NumberEditingTextController.decimal(
          locale: 'en',
          value: 12345.67,
        );
        expect(controller.text, '12,345.67');
        controller.groupSeparator = ' ';
        expect(controller.text, '12 345.67');
        expect(controller.number, 12345.67);
      });

      test('setting same separator does not notify listeners', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          groupSeparator: ',',
          value: 1000,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.groupSeparator = ',';
        expect(callCount, 0);
      });

      test('getter returns current separator', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          groupSeparator: ',',
        );
        expect(controller.groupSeparator, ',');
        controller.groupSeparator = '.';
        expect(controller.groupSeparator, '.');
      });

      test('changing separator with null value keeps null', () {
        final controller = NumberEditingTextController.integer(locale: 'en');
        controller.groupSeparator = '.';
        expect(controller.number, isNull);
        expect(controller.text, '');
      });
    });

    group('mutable allowNegative', () {
      test('disabling allowNegative drops sign from negative integer', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: -500,
        );
        expect(controller.text, '-500');
        expect(controller.number, -500);
        controller.allowNegative = false;
        expect(controller.text, '500');
        expect(controller.number, 500);
      });

      test('disabling allowNegative drops sign from negative decimal', () {
        final controller = NumberEditingTextController.decimal(
          locale: 'en',
          value: -3.14,
        );
        expect(controller.text, '-3.14');
        controller.allowNegative = false;
        expect(controller.text, '3.14');
        expect(controller.number, 3.14);
      });

      test('disabling allowNegative drops sign from negative currency', () {
        final controller = NumberEditingTextController.currency(
          locale: 'en',
          currencyName: 'USD',
          value: -42,
        );
        expect(controller.text, '\$-42');
        controller.allowNegative = false;
        expect(controller.text, '\$42');
        expect(controller.number, 42);
      });

      test('enabling allowNegative does not add sign to positive', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          allowNegative: false,
          value: 100,
        );
        expect(controller.text, '100');
        controller.allowNegative = true;
        expect(controller.text, '100');
        expect(controller.number, 100);
      });

      test('setting same value does not notify listeners', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: 10,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.allowNegative = true;
        expect(callCount, 0);
      });

      test('getter returns current value', () {
        final controller = NumberEditingTextController.integer();
        expect(controller.allowNegative, isTrue);
        controller.allowNegative = false;
        expect(controller.allowNegative, isFalse);
      });

      test('disabling with null value keeps null', () {
        final controller = NumberEditingTextController.integer(locale: 'en');
        controller.allowNegative = false;
        expect(controller.number, isNull);
        expect(controller.text, '');
      });
    });

    group('multiple mutations combined', () {
      test('changing locale then separator', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: 1000000,
        );
        expect(controller.text, '1,000,000');
        controller.locale = 'de';
        expect(controller.text, '1.000.000');
        controller.groupSeparator = ' ';
        expect(controller.text, '1 000 000');
        expect(controller.number, 1000000);
      });

      test('changing separator then disabling negative', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: -5000,
        );
        expect(controller.text, '-5,000');
        controller.groupSeparator = '.';
        expect(controller.text, '-5.000');
        controller.allowNegative = false;
        expect(controller.text, '5.000');
        expect(controller.number, 5000);
      });

      test('typing after mutation uses new format', () {
        final controller = NumberEditingTextController.integer(
          locale: 'en',
          value: 100,
        );
        expect(controller.text, '100');
        controller.groupSeparator = '.';
        controller.value = const TextEditingValue(
          text: '1000',
          selection: TextSelection.collapsed(offset: 4),
        );
        expect(controller.text, '1.000');
        expect(controller.number, 1000);
      });
    });

    group('mutable CurrencyEditingController options', () {
      test('changing currencyName reformats', () {
        final controller = CurrencyEditingController(
          locale: 'en',
          currencyName: 'USD',
          value: 100,
        );
        expect(controller.text, '\$100');
        controller.currencyName = 'EUR';
        expect(controller.text, '€100');
        expect(controller.number, 100);
      });

      test('changing currencySymbol reformats', () {
        final controller = CurrencyEditingController(
          locale: 'en',
          currencyName: 'USD',
          value: 50,
        );
        expect(controller.text, '\$50');
        controller.currencySymbol = '£';
        expect(controller.text, '£50');
        expect(controller.number, 50);
      });

      test('changing decimalSeparator reformats', () {
        final controller = CurrencyEditingController(
          locale: 'en',
          currencyName: 'USD',
          value: 10.5,
        );
        expect(controller.text, '\$10.5');
        controller.decimalSeparator = ',';
        expect(controller.text, '\$10,5');
        expect(controller.number, 10.5);
      });

      test('setting same currencyName does not notify', () {
        final controller = CurrencyEditingController(
          locale: 'en',
          currencyName: 'USD',
          value: 10,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.currencyName = 'USD';
        expect(callCount, 0);
      });

      test('setting same currencySymbol does not notify', () {
        final controller = CurrencyEditingController(
          locale: 'en',
          currencyName: 'USD',
          currencySymbol: '\$',
          value: 10,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.currencySymbol = '\$';
        expect(callCount, 0);
      });

      test('setting same decimalSeparator does not notify', () {
        final controller = CurrencyEditingController(
          locale: 'en',
          currencyName: 'USD',
          decimalSeparator: '.',
          value: 10,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.decimalSeparator = '.';
        expect(callCount, 0);
      });

      test('getters return current values', () {
        final controller = CurrencyEditingController(
          locale: 'en',
          currencyName: 'USD',
          currencySymbol: '\$',
          decimalSeparator: '.',
        );
        expect(controller.currencyName, 'USD');
        expect(controller.currencySymbol, '\$');
        expect(controller.decimalSeparator, '.');

        controller.currencyName = 'EUR';
        controller.currencySymbol = '€';
        controller.decimalSeparator = ',';
        expect(controller.currencyName, 'EUR');
        expect(controller.currencySymbol, '€');
        expect(controller.decimalSeparator, ',');
      });

      test('changing with null value keeps null', () {
        final controller = CurrencyEditingController(
          locale: 'en',
          currencyName: 'USD',
        );
        controller.currencyName = 'EUR';
        expect(controller.number, isNull);
        expect(controller.text, '');
      });
    });

    group('mutable DecimalEditingController options', () {
      test('changing minimalFractionDigits reformats', () {
        final controller = DecimalEditingController(
          locale: 'en',
          value: 3.5,
        );
        expect(controller.text, '3.5');
        controller.minimalFractionDigits = 3;
        expect(controller.text, '3.500');
        expect(controller.number, 3.5);
      });

      test('changing maximumFractionDigits reformats', () {
        final controller = DecimalEditingController(
          locale: 'en',
          maximumFractionDigits: 4,
          value: 3.1415,
        );
        expect(controller.text, '3.1415');
        controller.maximumFractionDigits = 2;
        expect(controller.text, '3.14');
        // number retains full precision — display is truncated
        expect(controller.number, 3.1415);
      });

      test('changing decimalSeparator reformats', () {
        final controller = DecimalEditingController(
          locale: 'en',
          value: 1.5,
        );
        expect(controller.text, '1.5');
        controller.decimalSeparator = ',';
        expect(controller.text, '1,5');
        expect(controller.number, 1.5);
      });

      test('setting same minimalFractionDigits does not notify', () {
        final controller = DecimalEditingController(
          locale: 'en',
          minimalFractionDigits: 2,
          value: 1.5,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.minimalFractionDigits = 2;
        expect(callCount, 0);
      });

      test('setting same maximumFractionDigits does not notify', () {
        final controller = DecimalEditingController(
          locale: 'en',
          maximumFractionDigits: 4,
          value: 1.5,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.maximumFractionDigits = 4;
        expect(callCount, 0);
      });

      test('setting same decimalSeparator does not notify', () {
        final controller = DecimalEditingController(
          locale: 'en',
          decimalSeparator: '.',
          value: 1.5,
        );
        var callCount = 0;
        controller.addListener(() => callCount++);
        controller.decimalSeparator = '.';
        expect(callCount, 0);
      });

      test('getters return current values', () {
        final controller = DecimalEditingController(
          locale: 'en',
          minimalFractionDigits: 1,
          maximumFractionDigits: 4,
          decimalSeparator: '.',
        );
        expect(controller.minimalFractionDigits, 1);
        expect(controller.maximumFractionDigits, 4);
        expect(controller.decimalSeparator, '.');

        controller.minimalFractionDigits = 2;
        controller.maximumFractionDigits = 6;
        controller.decimalSeparator = ',';
        expect(controller.minimalFractionDigits, 2);
        expect(controller.maximumFractionDigits, 6);
        expect(controller.decimalSeparator, ',');
      });

      test('changing with null value keeps null', () {
        final controller = DecimalEditingController(locale: 'en');
        controller.minimalFractionDigits = 2;
        expect(controller.number, isNull);
        expect(controller.text, '');
      });
    });

    group('subclass type checks', () {
      test('factory .currency returns CurrencyEditingController', () {
        final controller = NumberEditingTextController.currency();
        expect(controller, isA<CurrencyEditingController>());
      });

      test('factory .decimal returns DecimalEditingController', () {
        final controller = NumberEditingTextController.decimal();
        expect(controller, isA<DecimalEditingController>());
      });

      test('factory .integer returns IntegerEditingController', () {
        final controller = NumberEditingTextController.integer();
        expect(controller, isA<IntegerEditingController>());
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
