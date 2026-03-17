# Test Cases

Unicode legend: `NBSP` = `\u00A0` (non-breaking space), `NNBSP` = `\u202F` (narrow no-break space).

## Currency Controller

### Programmatic (`number =`)

| Locale | Currency | Symbol | Decimal Sep | Group Sep | Allow Negative | Input | Expected Text | Expected Number |
|--------|----------|--------|-------------|-----------|----------------|-------|---------------|-----------------|
| en | EUR | | | | true | `null` | `` | `null` |
| en | EUR | | | | true | `10.5` | `€10.5` | `10.5` |
| en | EUR | | | | true | `42` then `null` | `` | `null` |
| en | USD | | | | true | `99.99` | `$99.99` | `99.99` |
| de | GBP | | | | true | `-5000.5` | `-5.000,5NBSp£` | `-5000.5` |
| es_ES | TRY | `₺` | | | false | `6612.54` | `6.612,54NBSP₺` | `6612.54` |
| en | USD | | `·` | | true | `10.5` | `$10·5` | `10.5` |
| en | USD | | | ` ` | true | `1000000` | `$1 000 000` | `1000000` |
| en | USD | | | | true | `0` | `$0` | `0` |
| en | USD | | | | true | `999999999` | `$999,999,999` | `999999999` |
| ja | JPY | | | | true | `1500` | `¥1,500` | `1500` |
| ko | KRW | | | | true | `50000` | `₩50,000` | `50000` |
| pt_BR | BRL | | | | true | `1234.56` | `R$NBSP1.234,56` | `1234.56` |
| tr | TRY | | | | true | `1234.56` | `TL1.234,56` | `1234.56` |
| da | DKK | | | | true | `1234.56` | `1.234,56NBSPkr` | `1234.56` |
| da | DKK | | | | true | `-500` | `-500NBSPkr` | `-500` |
| fr | EUR | | | | true | `1234.56` | `1NNBSP234,56NBSP€` | `1234.56` |
| ru | RUB | | | | true | `500` | `500NBSP₽` | `500` |
| en | USD | | `.` | `.` | true | `1234.56` | `$1.234.56` | `1234.56` |
| hi | INR | | | | true | `50000` | `₹50,000` | `50000` |

### User Input (`value =`)

| Locale | Currency | Options | Typed Text | Expected Text | Expected Number |
|--------|----------|---------|------------|---------------|-----------------|
| en | USD | | `1234` | `$1,234` | `1234` |
| en | USD | | `10.50` | `$10.50` | `10.5` |
| en | USD | | `$` (deleted digits) | `$` | `null` |
| ru | USD | | `NBSP$` (deleted digits) | `NBSP$` | `null` |
| en | USD | | `-100` | `$-100` | `-100` |
| en | USD | | `abc` | (with `$`) | `null` |
| en | USD | | `-25.75` | `$-25.75` | `-25.75` |
| ko | KRW | | `1000000` | `₩1,000,000` | `1000000` |
| pt_BR | BRL | | `5000` | `R$NBSP5.000` | `5000` |

### Allow Negative

| Locale | Currency | Allow Negative | Typed Text | Expected Text | Expected Number |
|--------|----------|----------------|------------|---------------|-----------------|
| ja | USD | false | `-` | `$` | - |
| ja | USD | false | `$-` | `$` | - |
| uk | UAH | false | `-` | `` | - |
| uk | UAH | false | `0` | `0NBSP₴` | - |

## Integer Controller

### Programmatic (`number =`)

| Locale | Group Sep | Allow Negative | Input | Expected Text | Expected Number |
|--------|-----------|----------------|-------|---------------|-----------------|
| en | | true | `null` | `` | `null` |
| en | | true | `42` | `42` | `42` |
| de | | true | `-100` | `-100` | `-100` |
| en | | true | `1234567` | `1,234,567` | `1234567` |
| en | | true | `0` | `0` | `0` |
| en | | true | `500` | `500` | `500` |
| en | `.` | true | `1000000` | `1.000.000` | `1000000` |
| de | | true | `1234567` | `1.234.567` | `1234567` |
| en | | true | `999` | `999` | `999` |
| en | | true | `1000` | `1,000` | `1000` |
| en | | true | `1000000000` | `1,000,000,000` | `1000000000` |
| en | `` | true | `1234567` | `1234567` | `1234567` |
| en | | true | `-0` | `0` | `0` |

### User Input (`value =`)

| Locale | Options | Typed Text | Expected Text | Expected Number |
|--------|---------|------------|---------------|-----------------|
| en | | `1000000` | `1,000,000` | `1000000` |
| en | | `123.45` | (truncated) | `123` |
| en | | `5` | `5` | `5` |
| en | | `12345` | `12,345` | `12345` |
| en | | `1,23,456` | `123,456` | `123456` |
| en | | `` | `` | `null` |
| en | | `0` | `0` | `0` |
| en | | `007` | (leading zeros) | `7` |
| en | | `12abc34` | (stops at `a`) | `12` |
| en | | `1@2` | (stops at `@`) | `1` |
| en | | `-50` | `-50` | `-50` |
| en | allowNegative: false | `-5` | `5` | `5` |
| en | | `-` | `-` | `0` |
| en | | `-100000` | `-100,000` | `-100000` |
| en | | `-1000000` | `-1,000,000` | `-1000000` |
| en | | `-1234567890` | `-1,234,567,890` | `-1234567890` |

## Decimal Controller

### Programmatic (`number =`)

| Locale | Min Frac | Max Frac | Decimal Sep | Group Sep | Input | Expected Text | Expected Number |
|--------|----------|----------|-------------|-----------|-------|---------------|-----------------|
| en | | | | | `null` | `` | `null` |
| de | | 6 | | | `-100.51241` | `-100,51241` | `-100.51241` |
| de | | 6 | | | `-1100` | `-1.100` | `-1100` |
| en | 2 | 4 | | | `10` | `10.00` | `10` |
| en | 1 | 4 | | | `5.10` | `5.1` | `5.1` |
| en | | 2 | | | `0` | `0` | `0` |
| en | | 2 | | | `1234567.89` | `1,234,567.89` | `1234567.89` |
| en | | 2 | | | `3.14` | `3.14` | `3.14` |
| en | | 2 | `,` | | `3.14` | `3,14` | `3.14` |
| en | | 2 | | ` ` | `1234567.89` | `1 234 567.89` | `1234567.89` |
| de | | 2 | | | `1234.56` | `1.234,56` | `1234.56` |
| en | 3 | 8 | | | `1.5` | `1.500` | `1.5` |
| en | 3 | 8 | | | `1.0` | `1.000` | `1.0` |
| en | 3 | 8 | | | `1.123456789` | `1.12345679` | `1.123456789` |
| en | | 10 | | | `0.0000001` | `0.0000001` | `0.0000001` |
| en | | 2 | | | `-0.0` | `0` | `-0.0` |
| en | | 2 | `,` | | `42.99` | `42,99` | `42.99` |
| en | | 2 | | ` ` | `1234567.89` | `1 234 567.89` | `1234567.89` |

### User Input (`value =`)

| Locale | Options | Typed Text | Expected Text | Expected Number |
|--------|---------|------------|---------------|-----------------|
| en | maxFrac: 3 | `42.123` | `42.123` | `42.123` |
| en | maxFrac: 2 | `1.23456` | `1.23` | `1.23` |
| en | maxFrac: 2 | `-5.14` | `-5.14` | `-5.14` |
| en | maxFrac: 4 | `-0.5` | `-0.5` | `-0.5` |
| en | maxFrac: 4 | `-100.99` | `-100.99` | `-100.99` |
| en | maxFrac: 4 | `-1.0001` | `-1.0001` | `-1.0001` |
| en | allowNeg: false, maxFrac: 2 | `-1.5` | `1.5` | `1.5` |
| en | minFrac: 0, maxFrac: 3 | `1.12345` | `1.123` | `1.123` |
| de | maxFrac: 2 | `1234,56` | `1.234,56` | `1234.56` |
| de | maxFrac: 2 | `-1234,56` | `-1.234,56` | `-1234.56` |
| de | | `1234567` | `1.234.567` | `1234567` |

## Caret Position

### Integer

| Typed Text | Caret In | Expected Text | Caret Out |
|------------|----------|---------------|-----------|
| `5` | 1 | `5` | 1 |
| `1234` | 4 | `1,234` | 5 |
| `1,2345` | 6 | `12,345` | 6 |
| `12,3456` | 7 | `123,456` | 7 |
| `1,345` (deleted `2`) | 1 | `1,345` | 2 |
| `12,34` (deleted last) | 5 | `1,234` | 5 |

### Currency (USD, en)

| Typed Text | Caret In | Expected Text | Caret Out |
|------------|----------|---------------|-----------|
| `1` | 1 | `$1` | 2 |
| `$12` | 3 | `$12` | 3 |
| `$1234` | 5 | `$1,234` | 6 |
| `$1,2345` | 7 | `$12,345` | 7 |

### Decimal (en, maxFrac: 2)

| Typed Text | Caret In | Expected Text | Caret Out |
|------------|----------|---------------|-----------|
| `1.5` | 3 | `1.5` | 3 |
| `1.50` | 4 | `1.50` | 4 |
| `12345.67` | 8 | `12,345.67` | 9 |

## Bug Regressions

| Description | Type | Locale | Options | Input | Expected Text | Expected Number |
|-------------|------|--------|---------|-------|---------------|-----------------|
| Negative decimal parsed incorrectly | decimal | en | maxFrac: 2 | type `-5.14` | `-5.14` | `-5.14` |
| Group separator at start crashes | integer | en | | type `,5` | - | `null` or `0` |
| Group separator alone crashes | integer | en | | type `,` | - | `null` or `0` |
| NaN crashes | integer | en | | set `NaN` | (no crash) | - |
| Infinity crashes | integer | en | | set `Infinity` | (no crash) | - |
| Negative infinity crashes | decimal | en | maxFrac: 2 | set `-Infinity` | (no crash) | - |
| Negative 6+ digits wrong grouping | integer | en | | type `-100000` | `-100,000` | `-100000` |
| Minus before currency symbol duplicates symbol | currency | en | JPY | type `-¥123,456` | `¥123,456` | `123456` |
| Minus before currency symbol (allowNeg: false) | currency | en | JPY, allowNeg: false | type `-¥123,456` | `¥123,456` | `123456` |

## Mutable Options

### Locale Change

| Type | Initial Locale | Initial Value | New Locale | Expected Text | Expected Number |
|------|----------------|---------------|------------|---------------|-----------------|
| integer | en | `1234567` | de | `1.234.567` | `1234567` |
| currency (EUR) | en | `1234.56` | de | `1.234,56NBSP€` | `1234.56` |
| decimal | en | `1234.5` | de | `1.234,5` | `1234.5` |

### Group Separator Change

| Type | Locale | Initial Value | New Separator | Expected Text | Expected Number |
|------|--------|---------------|---------------|---------------|-----------------|
| integer | en | `1234567` | ` ` | `1 234 567` | `1234567` |
| currency (USD) | en | `5000` | `.` | `$5.000` | `5000` |
| decimal | en | `12345.67` | ` ` | `12 345.67` | `12345.67` |

### Allow Negative Change

| Type | Locale | Initial Value | New allowNegative | Expected Text | Expected Number |
|------|--------|---------------|-------------------|---------------|-----------------|
| integer | en | `-500` | false | `500` | `500` |
| decimal | en | `-3.14` | false | `3.14` | `3.14` |
| currency (USD) | en | `-42` | false | `$42` | `42` |
| integer | en | `100` (allowNeg: false) | true | `100` | `100` |

### Currency-Specific Options

| Option | Initial | New Value | Initial Value | Expected Text | Expected Number |
|--------|---------|-----------|---------------|---------------|-----------------|
| currencyName | USD | EUR | `100` | `€100` | `100` |
| currencySymbol | (USD default) | `£` | `50` | `£50` | `50` |
| decimalSeparator | `.` | `,` | `10.5` | `$10,5` | `10.5` |

### Decimal-Specific Options

| Option | Initial | New Value | Initial Value | Expected Text | Expected Number |
|--------|---------|-----------|---------------|---------------|-----------------|
| minimalFractionDigits | (default) | 3 | `3.5` | `3.500` | `3.5` |
| maximumFractionDigits | 4 | 2 | `3.1415` | `3.14` | `3.1415` |
| decimalSeparator | `.` | `,` | `1.5` | `1,5` | `1.5` |

### Combined Mutations

| Steps | Initial Value | Expected After Each Step |
|-------|---------------|--------------------------|
| locale: en -> de, separator: -> ` ` | `1000000` | `1.000.000` -> `1 000 000` |
| separator: -> `.`, allowNeg: -> false | `-5000` | `-5.000` -> `5.000` |
