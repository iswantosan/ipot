import 'package:flutter_test/flutter_test.dart';
import 'package:ipot/utils/qr.dart';

void main() {
  group('parseTableQr', () {
    test('parses ipot scheme', () {
      expect(parseTableQr('ipot://table/T001'), 'T001');
      expect(parseTableQr('ipot://table/A99'), 'A99');
    });

    test('parses https url that ends with /table/{id}', () {
      expect(parseTableQr('https://order.ipot.com/table/T042'), 'T042');
    });

    test('returns null for malformed input', () {
      expect(parseTableQr(null), isNull);
      expect(parseTableQr(''), isNull);
      expect(parseTableQr('   '), isNull);
      expect(parseTableQr('not-a-uri'), isNull);
      expect(parseTableQr('ipot://other/T001'), isNull);
      expect(parseTableQr('https://example.com/notable/T001'), isNull);
    });

    test('trims surrounding whitespace', () {
      expect(parseTableQr('  ipot://table/T001  '), 'T001');
    });

    test('returns null when table id is empty', () {
      expect(parseTableQr('ipot://table/'), isNull);
    });
  });
}
