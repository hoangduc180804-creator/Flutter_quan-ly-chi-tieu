import 'package:intl/intl.dart';

class DinhDangTien {
  static String format(double soTien) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
    );
    return formatter.format(soTien);
  }
}
