import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

String formatCurrency(num value) => _currency.format(value);

String formatEventDate(DateTime date) =>
    DateFormat('dd MMM yyyy', 'en_US').format(date);

String formatLongEventDate(DateTime date) =>
    DateFormat('dd MMMM yyyy', 'en_US').format(date);
