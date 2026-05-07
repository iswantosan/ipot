import 'package:intl/intl.dart';

final _money = NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: 2);

String formatPrice(num value) => _money.format(value);

String formatModifier(num value) {
  if (value == 0) return 'Free';
  final sign = value > 0 ? '+' : '-';
  return '$sign${_money.format(value.abs())}';
}
