/// A TextEditingController that formats numbers, decimals, and currencies
/// as you type with locale support.
library;

export 'src/parsed_number_format.dart' show CurrencySymbolPosition;
export 'src/text_controller.dart'
    show
        NumberEditingTextController,
        CurrencyEditingController,
        DecimalEditingController,
        IntegerEditingController;
