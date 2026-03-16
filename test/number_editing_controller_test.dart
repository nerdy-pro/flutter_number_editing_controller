import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_editing_controller/number_editing_controller.dart';

/// Non-breaking space used by many locales as a group separator.
const _nbsp = '\u00A0';

void main() {
  group('NumberEditingTextController.currency', () {
    test('empty state', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'EUR',
      );
      expect(controller.value.text, '');
      expect(controller.number, null);
    });

    test('set number programmatically', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'EUR',
      );
      controller.number = 10.5;
      expect(controller.value.text, '€10.5');
      expect(controller.number, 10.5);
    });

    test('set number to null clears text', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'EUR',
      );
      controller.number = 42;
      expect(controller.number, 42);
      controller.number = null;
      expect(controller.value.text, '');
      expect(controller.number, null);
    });

    test('initial value via constructor', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
        value: 99.99,
      );
      expect(controller.value.text, '\$99.99');
      expect(controller.number, 99.99);
    });

    test('negative currency in DE locale', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'GBP',
        locale: 'de',
      );
      controller.number = -5000.5;
      // DE uses non-breaking space before currency symbol
      expect(controller.value.text, '-5.000,5${_nbsp}£');
      expect(controller.number, -5000.5);
    });

    test('overridden currency symbol', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'TRY',
        locale: 'es_ES',
        currencySymbol: '₺',
        allowNegative: false,
      );
      controller.number = 6612.54;
      expect(controller.value.text, '6.612,54${_nbsp}₺');
      expect(controller.number, 6612.54);
    });

    test('custom decimal separator', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
        decimalSeparator: '·',
      );
      controller.number = 10.5;
      expect(controller.value.text, '\$10·5');
    });

    test('custom group separator', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
        groupSeparator: ' ',
      );
      controller.number = 1000000;
      expect(controller.value.text, '\$1 000 000');
    });

    test('zero value', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.number = 0;
      expect(controller.value.text, '\$0');
      expect(controller.number, 0);
    });

    test('very large number', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.number = 999999999;
      expect(controller.value.text, '\$999,999,999');
      expect(controller.number, 999999999);
    });

    test('typing digits adds formatting', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.value = controller.value.copyWith(
        text: '1234',
        selection: const TextSelection.collapsed(offset: 4),
      );
      expect(controller.value.text, '\$1,234');
      expect(controller.number, 1234);
    });

    test('typing decimal amount', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.value = controller.value.copyWith(
        text: '10.50',
        selection: const TextSelection.collapsed(offset: 5),
      );
      expect(controller.value.text, '\$10.50');
      expect(controller.number, 10.5);
    });

    test('deleting all digits leaves currency symbol', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.number = 1;
      controller.value = controller.value.copyWith(
        text: '\$',
        selection: const TextSelection.collapsed(offset: 1),
      );
      expect(controller.value.text, '\$');
      expect(controller.number, null);
    });

    test('deleting all digits with trailing symbol', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'ru',
      );
      controller.number = 1;
      // Russian uses non-breaking space
      expect(controller.value.text, '1${_nbsp}\$');
      controller.value = controller.value.copyWith(
        text: '${_nbsp}\$',
        selection: const TextSelection.collapsed(offset: 0),
      );
      expect(controller.value.text, '${_nbsp}\$');
      expect(controller.number, null);
    });

    test('JPY currency has no decimals', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'JPY',
        locale: 'ja',
      );
      controller.number = 1500;
      expect(controller.value.text, '¥1,500');
      expect(controller.number, 1500);
    });

    test('default locale is used when none specified', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
      );
      controller.number = 100;
      expect(controller.number, 100);
      expect(controller.value.text.isNotEmpty, true);
    });
  });

  group('NumberEditingTextController.integer', () {
    test('empty state', () {
      final controller = NumberEditingTextController.integer();
      expect(controller.value.text, '');
      expect(controller.number, null);
    });

    test('set number programmatically', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 42;
      expect(controller.value.text, '42');
      expect(controller.number, 42);
    });

    test('negative integer', () {
      final controller = NumberEditingTextController.integer(locale: 'de');
      controller.number = -100;
      expect(controller.value.text, '-100');
      expect(controller.number, -100);
    });

    test('large integer with grouping', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 1234567;
      expect(controller.value.text, '1,234,567');
      expect(controller.number, 1234567);
    });

    test('typing digits formats with grouping', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '1000000',
        selection: const TextSelection.collapsed(offset: 7),
      );
      expect(controller.value.text, '1,000,000');
      expect(controller.number, 1000000);
    });

    test('decimal input stops at separator for integer', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '123.45',
        selection: const TextSelection.collapsed(offset: 6),
      );
      // integer controller ignores everything from decimal separator
      expect(controller.number, 123);
    });

    test('zero value', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 0;
      expect(controller.value.text, '0');
      expect(controller.number, 0);
    });

    test('initial value via constructor', () {
      final controller = NumberEditingTextController.integer(
        locale: 'en',
        value: 500,
      );
      expect(controller.value.text, '500');
      expect(controller.number, 500);
    });

    test('custom group separator', () {
      final controller = NumberEditingTextController.integer(
        locale: 'en',
        groupSeparator: '.',
      );
      controller.number = 1000000;
      expect(controller.value.text, '1.000.000');
    });

    test('German locale grouping', () {
      final controller = NumberEditingTextController.integer(locale: 'de');
      controller.number = 1234567;
      expect(controller.value.text, '1.234.567');
      expect(controller.number, 1234567);
    });

    test('single digit', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '5',
        selection: const TextSelection.collapsed(offset: 1),
      );
      expect(controller.value.text, '5');
      expect(controller.number, 5);
    });
  });

  group('NumberEditingTextController.decimal', () {
    test('empty state', () {
      final controller = NumberEditingTextController.decimal();
      expect(controller.value.text, '');
      expect(controller.number, null);
    });

    test('set decimal number programmatically', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'de',
        maximumFractionDigits: 6,
      );
      controller.number = -100.51241;
      expect(controller.value.text, '-100,51241');
      expect(controller.number, -100.51241);
    });

    test('integer provided to decimal controller', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'de',
        maximumFractionDigits: 6,
      );
      controller.number = -1100;
      expect(controller.value.text, '-1.100');
      expect(controller.number, -1100);
    });

    test('minimum fraction digits enforced', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        minimalFractionDigits: 2,
        maximumFractionDigits: 4,
      );
      controller.number = 10;
      expect(controller.value.text, '10.00');
      expect(controller.number, 10);
    });

    test('trailing zeros removed up to minimum', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        minimalFractionDigits: 1,
        maximumFractionDigits: 4,
      );
      controller.number = 5.10;
      expect(controller.value.text, '5.1');
    });

    test('zero decimal value', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        maximumFractionDigits: 2,
      );
      controller.number = 0;
      expect(controller.value.text, '0');
      expect(controller.number, 0);
    });

    test('large decimal with grouping', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        maximumFractionDigits: 2,
      );
      controller.number = 1234567.89;
      expect(controller.value.text, '1,234,567.89');
      expect(controller.number, 1234567.89);
    });

    test('initial value via constructor', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        maximumFractionDigits: 2,
        value: 3.14,
      );
      expect(controller.value.text, '3.14');
      expect(controller.number, 3.14);
    });

    test('custom decimal separator', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        decimalSeparator: ',',
        maximumFractionDigits: 2,
      );
      controller.number = 3.14;
      expect(controller.value.text, '3,14');
    });

    test('custom group separator', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        groupSeparator: ' ',
        maximumFractionDigits: 2,
      );
      controller.number = 1234567.89;
      expect(controller.value.text, '1 234 567.89');
    });

    test('typing decimal value', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        maximumFractionDigits: 3,
      );
      controller.value = controller.value.copyWith(
        text: '42.123',
        selection: const TextSelection.collapsed(offset: 6),
      );
      expect(controller.value.text, '42.123');
      expect(controller.number, 42.123);
    });

    test('excess decimal digits truncated on input', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        maximumFractionDigits: 2,
      );
      controller.value = controller.value.copyWith(
        text: '1.23456',
        selection: const TextSelection.collapsed(offset: 7),
      );
      expect(controller.value.text, '1.23');
      expect(controller.number, 1.23);
    });

    test('German locale decimal formatting', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'de',
        maximumFractionDigits: 2,
      );
      controller.number = 1234.56;
      expect(controller.value.text, '1.234,56');
      expect(controller.number, 1234.56);
    });
  });

  group('allowNegative', () {
    test('negative allowed by default for currency', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.value = controller.value.copyWith(
        text: '-100',
        selection: const TextSelection.collapsed(offset: 4),
      );
      expect(controller.number, -100);
    });

    test('negative allowed by default for integer', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '-50',
        selection: const TextSelection.collapsed(offset: 3),
      );
      expect(controller.number, -50);
    });

    test('disallow negative with leading currency symbol', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'ja',
        allowNegative: false,
      );
      controller.value = controller.value.copyWith(
        text: '-',
        selection: const TextSelection.collapsed(offset: 1),
      );
      expect(controller.value.text, '\$');

      controller.value = controller.value.copyWith(
        text: '\$-',
        selection: const TextSelection.collapsed(offset: 2),
      );
      expect(controller.value.text, '\$');
    });

    test('disallow negative with trailing currency symbol', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'UAH',
        locale: 'uk',
        allowNegative: false,
      );
      controller.value = controller.value.copyWith(
        text: '-',
        selection: const TextSelection.collapsed(offset: 1),
      );
      expect(controller.value.text, '');

      controller.value = controller.value.copyWith(
        text: '0',
        selection: const TextSelection.collapsed(offset: 1),
      );
      // Ukrainian locale uses non-breaking space
      expect(controller.value.text, '0${_nbsp}₴');
    });

    test('disallow negative for integer', () {
      final controller = NumberEditingTextController.integer(
        locale: 'en',
        allowNegative: false,
      );
      controller.value = controller.value.copyWith(
        text: '-5',
        selection: const TextSelection.collapsed(offset: 2),
      );
      expect(controller.number, 5);
    });

    test('disallow negative for decimal', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        allowNegative: false,
        maximumFractionDigits: 2,
      );
      controller.value = controller.value.copyWith(
        text: '-1.5',
        selection: const TextSelection.collapsed(offset: 4),
      );
      expect(controller.number, 1.5);
    });

    test('minus sign only yields zero', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '-',
        selection: const TextSelection.collapsed(offset: 1),
      );
      expect(controller.number, 0);
    });
  });

  group('non-numeric input filtering', () {
    test('alphabetic characters stop parsing for integer', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '12abc34',
        selection: const TextSelection.collapsed(offset: 7),
      );
      // parsing stops at 'a', so only '12' is parsed
      expect(controller.number, 12);
    });

    test('non-digit input with leading currency symbol', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.value = controller.value.copyWith(
        text: 'abc',
        selection: const TextSelection.collapsed(offset: 3),
      );
      // currency symbol is prepended, non-digits remain after the real part
      expect(controller.number, null);
    });

    test('only first contiguous digits are parsed', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '1@2',
        selection: const TextSelection.collapsed(offset: 3),
      );
      // stops parsing at '@'
      expect(controller.number, 1);
    });
  });

  group('locale handling', () {
    test('French locale formatting', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'EUR',
        locale: 'fr',
      );
      controller.number = 1234.56;
      expect(controller.number, 1234.56);
      expect(controller.value.text.contains('€'), true);
    });

    test('Japanese locale with JPY', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'JPY',
        locale: 'ja',
        allowNegative: false,
      );
      controller.number = 1500;
      expect(controller.value.text, '¥1,500');
      expect(controller.number, 1500);
    });

    test('Spanish locale with custom currency', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'TRY',
        locale: 'es_ES',
        currencySymbol: '₺',
      );
      controller.number = 1000;
      expect(controller.value.text.contains('₺'), true);
      expect(controller.number, 1000);
    });

    test('Russian locale trailing currency symbol', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'RUB',
        locale: 'ru',
      );
      controller.number = 500;
      final text = controller.value.text;
      expect(text.contains('500'), true);
      expect(controller.number, 500);
    });
  });

  group('number setter edge cases', () {
    test('set number updates text and number', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 100;
      expect(controller.value.text, '100');
      expect(controller.number, 100);
      controller.number = 200;
      expect(controller.value.text, '200');
      expect(controller.number, 200);
    });

    test('set number to zero', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 0;
      expect(controller.value.text, '0');
      expect(controller.number, 0);
    });

    test('set number then type replaces properly', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 100;
      controller.value = controller.value.copyWith(
        text: '200',
        selection: const TextSelection.collapsed(offset: 3),
      );
      expect(controller.value.text, '200');
      expect(controller.number, 200);
    });

    test('repeated set same number keeps same text', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.number = 1000;
      final formatted = controller.value.text;
      controller.number = 1000;
      expect(controller.value.text, formatted);
    });
  });

  group('grouping behavior', () {
    test('no grouping for small numbers', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 999;
      expect(controller.value.text, '999');
    });

    test('grouping starts at 4 digits', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 1000;
      expect(controller.value.text, '1,000');
    });

    test('multiple groups', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.number = 1000000000;
      expect(controller.value.text, '1,000,000,000');
    });

    test('typing preserves grouping separators', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '12345',
        selection: const TextSelection.collapsed(offset: 5),
      );
      expect(controller.value.text, '12,345');
      expect(controller.number, 12345);
    });

    test('existing group separators are re-formatted', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '1,23,456',
        selection: const TextSelection.collapsed(offset: 8),
      );
      expect(controller.value.text, '123,456');
      expect(controller.number, 123456);
    });
  });

  group('value setter (simulating user input)', () {
    test('empty input stays empty', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = const TextEditingValue(text: '');
      expect(controller.number, null);
    });

    test('typing single zero', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '0',
        selection: const TextSelection.collapsed(offset: 1),
      );
      expect(controller.value.text, '0');
      expect(controller.number, 0);
    });

    test('typing leading zeros', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '007',
        selection: const TextSelection.collapsed(offset: 3),
      );
      expect(controller.number, 7);
    });
  });

  group('bug fixes', () {
    test('negative decimal via typing produces correct number', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        maximumFractionDigits: 2,
      );
      controller.value = controller.value.copyWith(
        text: '-5.14',
        selection: const TextSelection.collapsed(offset: 5),
      );
      expect(controller.number, -5.14);
    });

    test('negative decimal via typing with various values', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        maximumFractionDigits: 4,
      );
      controller.value = controller.value.copyWith(
        text: '-0.5',
        selection: const TextSelection.collapsed(offset: 4),
      );
      expect(controller.number, -0.5);

      controller.value = controller.value.copyWith(
        text: '-100.99',
        selection: const TextSelection.collapsed(offset: 7),
      );
      expect(controller.number, -100.99);

      controller.value = controller.value.copyWith(
        text: '-1.0001',
        selection: const TextSelection.collapsed(offset: 7),
      );
      expect(controller.number, -1.0001);
    });

    test('negative currency via typing produces correct number', () {
      final controller = NumberEditingTextController.currency(
        currencyName: 'USD',
        locale: 'en',
      );
      controller.value = controller.value.copyWith(
        text: '-25.75',
        selection: const TextSelection.collapsed(offset: 6),
      );
      expect(controller.number, -25.75);
    });

    test('group separator at start of input does not crash', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      // Should not throw RangeError
      controller.value = controller.value.copyWith(
        text: ',5',
        selection: const TextSelection.collapsed(offset: 2),
      );
      expect(controller.number, isNotNull);
    });

    test('group separator alone does not crash', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: ',',
        selection: const TextSelection.collapsed(offset: 1),
      );
      // Should not crash; number may be null or 0
      expect(controller.number, anyOf(isNull, equals(0)));
    });

    test('NaN does not crash', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      expect(
        () => controller.number = double.nan,
        returnsNormally,
      );
    });

    test('infinity does not crash', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      expect(
        () => controller.number = double.infinity,
        returnsNormally,
      );
    });

    test('negative infinity does not crash', () {
      final controller = NumberEditingTextController.decimal(
        locale: 'en',
        maximumFractionDigits: 2,
      );
      expect(
        () => controller.number = double.negativeInfinity,
        returnsNormally,
      );
    });

    test('typing negative 6+ digit number has correct grouping', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '-100000',
        selection: const TextSelection.collapsed(offset: 7),
      );
      expect(controller.value.text, '-100,000');
      expect(controller.number, -100000);
    });

    test('typing negative 7+ digit number has correct grouping', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '-1000000',
        selection: const TextSelection.collapsed(offset: 8),
      );
      expect(controller.value.text, '-1,000,000');
      expect(controller.number, -1000000);
    });

    test('typing negative 10+ digit number has correct grouping', () {
      final controller = NumberEditingTextController.integer(locale: 'en');
      controller.value = controller.value.copyWith(
        text: '-1234567890',
        selection: const TextSelection.collapsed(offset: 11),
      );
      expect(controller.value.text, '-1,234,567,890');
      expect(controller.number, -1234567890);
    });
  });
}
