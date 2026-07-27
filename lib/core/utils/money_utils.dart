class MoneyUtils {
  static double fromMinor(int minorUnits) => minorUnits / 100.0;
  static int toMinor(double amount) => (amount * 100).round();
  static String formatPKR(int minorUnits) {
    final amount = minorUnits / 100.0;
    return 'PKR ${amount.toStringAsFixed(0)}';
  }
}
