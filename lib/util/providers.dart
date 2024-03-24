// Flutter imports:
import 'package:binsight_ai/widgets/free_draw.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:introduction_screen/introduction_screen.dart';

// Project imports:
import 'package:binsight_ai/util/bluetooth.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/wifi_scan.dart';

/// Notifies listeners of changes to the device.
///
/// This also includes the device's connection status.
class DeviceNotifier with ChangeNotifier {
  BleDevice? device;

  /// An error that occurred during the connection process.
  Exception? error;

  /// Whether an error occurred during the connection process.
  bool hasError() {
    return error != null;
  }

  /// Sets the device to the new device and notifies listeners.
  void setDevice(BleDevice newDevice) {
    device = newDevice;
    notifyListeners();
  }

  /// Resets and disconnects the device.
  void resetDevice() async {
    device?.removeListener(
        BleDeviceClientEvents.connected, _onConnectionChange);
    device?.removeListener(
        BleDeviceClientEvents.disconnected, _onConnectionChange);
    device?.disconnect();
    device = null;
    notifyListeners();
  }

  /// Notifies listeners of a change in the connection status.
  void _onConnectionChange(_) {
    notifyListeners();
  }

  /// Listens for connection events on the device.
  void listenForConnectionEvents() {
    device?.onConnected(_onConnectionChange);
    device?.onDisconnected(_onConnectionChange);
  }

  /// Pairs with the device and notifies when the pairing is complete.
  ///
  /// This method can be awaited to wait for the pairing to complete.
  Future<void> pair() async {
    try {
      error = null;
      await device?.waitForPair();
    } on Exception catch (e) {
      debug("DeviceNotifier[pair]: Failed: $e");
      error = e;
    }
    notifyListeners();
  }

  /// Connects to the device and notifies when the connection is complete.
  Future<void> connect() async {
    try {
      error = null;
      await device?.connect();
    } on Exception catch (e) {
      error = e;
    }
    notifyListeners();
  }
}

class WifiResultNotifier with ChangeNotifier {
  WifiScanResult? wifiResult;

  /// An error that occurred during the connection process.
  Exception? error;

  /// Whether an error occurred during the connection process.
  bool hasError() {
    return error != null;
  }

  /// Sets the device to the new device and notifies listeners.
  void setWifiResult(WifiScanResult newWifiResult) {
    wifiResult = newWifiResult;
    notifyListeners();
  }
}

class SetupKeyNotifier {
  final setupKey = GlobalKey<IntroductionScreenState>();
}

/// Notifies listeners of changes to the annotation state
class AnnotationNotifier extends ChangeNotifier {
  /// Current label
  String? label;

  /// List of all annotations for a single image
  List<List<dynamic>> allAnnotations = [];

  /// List of segments for the current annotation
  List<DrawingSegment> currentAnnotation = [];

  /// List of segments for all annotations
  List<DrawingSegment> oldAnnotations = [];

  /// History of segments for the current annotation
  List<DrawingSegment> currentAnnotationHistory = [];

  /// Single segment containing all Offsets in the current annotation
  DrawingSegment? combinedCurrentAnnotation;

  /// Id of the detection currently being annotated
  String? currentDetection;

  /// Reset annotation state
  void reset() {
    label = null;
    allAnnotations = [];
    oldAnnotations = [];
    currentAnnotation = [];
    currentAnnotationHistory = [];
    combinedCurrentAnnotation = null;
    currentDetection = null;
  }

  /// Set current detection id
  void setDetection(String id) {
    currentDetection = id;
  }

  /// Set the label for the current annotation
  void setLabel(String newLabel) {
    label = newLabel;
    notifyListeners();
  }

  /// Add first segment of the current annotation
  void startCurrentAnnotation(DrawingSegment segment) {
    currentAnnotation.add(segment);
    notifyListeners();
  }

  /// Update list of all annotations
  void addToAllAnnotations() {
    combinedCurrentAnnotation = combineCurrentSegments();
    if (combinedCurrentAnnotation != null && label != null) {
      allAnnotations.add([label, combinedCurrentAnnotation!.toFloatList()]);
    }
    notifyListeners();
  }

  /// Update the most recent segment in the currentAnnotation list
  void updateCurrentAnnotation(DrawingSegment segment) {
    currentAnnotation.last = segment;
    notifyListeners();
  }

  /// Update the current annotations history
  void updateCurrentAnnotationHistory() {
    currentAnnotationHistory = List.of(currentAnnotation);
    notifyListeners();
  }

  /// Checks whether the current annotation can be undone
  bool canUndo() {
    return currentAnnotation.isNotEmpty && currentAnnotationHistory.isNotEmpty;
  }

  /// Remove the last segment in the current annotation
  void undo() {
    if (canUndo()) {
      currentAnnotation.removeLast();
    }
    notifyListeners();
  }

  /// Checks whether the current annotation can be redone
  bool canRedo() {
    return currentAnnotation.length < currentAnnotationHistory.length;
  }

  /// Pull from the history to add the most recently removed segment to the current annotation
  void redo() {
    if (canRedo()) {
      final index = currentAnnotation.length;
      currentAnnotation.add(currentAnnotationHistory[index]);
    }
    notifyListeners();
  }

  /// From the start index on in the currentAnnotation list, combine all segments into one
  DrawingSegment? combineCurrentSegments() {
    DrawingSegment combinedSegments =
        DrawingSegment(id: currentAnnotation[0].id, offsets: []);

    for (int i = 0; i < currentAnnotation.length; i++) {
      oldAnnotations.add(currentAnnotation[i]);
      combinedSegments.offsets.addAll(currentAnnotation[i].offsets);
    }
    return combinedSegments;
  }

  /// Clear the current annotation
  void clearCurrentAnnotation() {
    currentAnnotation = [];
    updateCurrentAnnotationHistory();
    notifyListeners();
  }

  /// Check if the current annotation has both a drawing and a label
  bool isCompleteAnnotation() {
    return label != null && currentAnnotation.isNotEmpty;
  }
}
