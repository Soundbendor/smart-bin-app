/// A WiFi scan result.
class WifiScanResult {
  /// The SSID of the network.
  final String ssid;

  /// The security type of the network.
  ///
  /// It can be one of the following:
  /// - "WPA"
  /// - "WPA2"
  /// - "WPA2 802.1X"
  /// - "--" (open network)
  /// - etc.
  final String security;

  /// The signal strength of the network.
  ///
  /// It is a value between 0 and 100.
  final int signalStrength;

  WifiScanResult(this.ssid, this.security, this.signalStrength);
}
