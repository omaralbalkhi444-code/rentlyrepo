
class QrScannerLogic {
  static bool validateQrCode(String? qrCode) {
    if (qrCode == null || qrCode.isEmpty) {
      return false;
    }
    return true;
  }

  static bool shouldProcessQr(String? qrCode) {
    return qrCode != null;
  }

  static String getSuccessMessage() {
    return "Pickup confirmed";
  }

  static String getErrorMessage() {
    return "Invalid QR code";
  }

  static String getNullErrorMessage() {
    return "No QR code detected";
  }
}
