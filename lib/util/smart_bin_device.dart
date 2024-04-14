import 'dart:convert';

import 'package:binsight_ai/util/bluetooth_bin_data.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SmartBinDevice {
  static Future<Map<String, dynamic>> decodeCharacteristic(
      BuildContext context, List<int> characteristic) async {
    try {
      return jsonDecode(utf8.decode(
          await Provider.of<DeviceNotifier>(context, listen: false)
              .device!
              .readCharacteristic(
                  serviceId: mainServiceId,
                  characteristicId: wifiListCharacteristicId)));
    } catch (e) {
      debug("Error manually fetching characteristic: $e");
      rethrow;
    }
  }
}
