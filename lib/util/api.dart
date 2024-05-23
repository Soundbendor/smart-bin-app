// Flutter Imports:
import 'dart:convert';
import 'package:flutter/material.dart';

// Package Imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Project Imports:
import 'package:binsight_ai/database/models/detection.dart';
import 'package:binsight_ai/util/print.dart';
import 'package:binsight_ai/util/providers/detection_notifier.dart';
import 'package:binsight_ai/util/providers/image_provider.dart';
import 'package:binsight_ai/util/shared_preferences.dart';

const apiEndpoint = 'http://sb-binsight.dri.oregonstate.edu:30080/api';

/// Fetch image data from the api. Also updates the detection notifier and retrieves images.
///
/// - [deviceID] is the device id of the device to fetch data for
/// - [afterDate] is the date to fetch data after
/// - [context] is the context to use for the provider
Future<void> fetchImageData(
    String deviceID, Future<DateTime> afterDate, BuildContext context) async {
  DateTime timestamp = await afterDate;
  debug("LATEST TIME STAMP $timestamp");
  const size = 50;
  String formattedDate = DateFormat('yyyy-MM-dd').format(timestamp);
  String formattedTime = DateFormat('HH:mm:ss').format(timestamp);
  debug("FORMATTED DATE $formattedDate");
  debug("FORMATTED TIME $formattedTime");
  const String url = '$apiEndpoint/get_image_info';
  Map<String, String> queryParams = {
    'deviceID': deviceID,
    'after_date': formattedDate,
    'after_time': formattedTime,
    'page': '1',
    'size': size.toString(),
  };

  final Uri uri = Uri.parse(url).replace(queryParameters: queryParams);
  Map<String, String> headers = {
    'accept': 'application/json',
    'token': getApiKey(),
  };
  try {
    final http.Response response = await http.get(uri, headers: headers);
    List<String> imageList = [];
    debug(response);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // API RETURNS ITEMS SORTED BY DATE IN ASCENDING ORDER, REVERSE FOR NEWEST FIRST
      List<dynamic> itemList = data['items'].reversed.toList();
      debug(
          "IMAGES QUERIED FOR AND RECIEVED BEFORE: $itemList and length ${itemList.length}");
      if (itemList.isNotEmpty) {
        final currentLatest = await Detection.latest();
        final removeIndex = itemList.indexWhere((element) {
          return element['colorImage'] == currentLatest.postDetectImgLink;
        });
        if (removeIndex != -1) itemList.removeAt(removeIndex);
      }
      debug(
          "IMAGES QUERIED FOR AND RECIEVED: $itemList and length ${itemList.length}");
      for (var item in itemList) {
        Map<String, dynamic> adjustedMap = transformMap(item);
        imageList.add(adjustedMap["postDetectImgLink"]);
        Detection detection = Detection.fromMap(adjustedMap);
        await detection.save();
      }
      if (context.mounted) {
        Provider.of<DetectionNotifier>(context, listen: false).getAll();
        try {
          await retrieveImages(deviceID, imageList, context);
        } catch (e) {
          debug(e);
        }
      }
      if (itemList.length >= size && context.mounted) {
        await fetchImageData(deviceID, afterDate, context);
      }
    } else {
      debug('Failed with status code: ${response.statusCode}');
    }
  } catch (e) {
    debug('Error: $e');
  }
}

/// Retrieve images from the api
///
/// - [deviceID] is the device id of the device to fetch images for
/// - [imageList] is the list of images to fetch
/// - [context] is the context to use for the provider
Future<void> retrieveImages(
    String deviceID, List<String> imageList, BuildContext context) async {
  String url = '$apiEndpoint/get_images?deviceID=$deviceID';
  final requestBody = imageList;
  debug("Image List $imageList");
  Map<String, String> headers = {
    'accept': 'application/json',
    'token': getApiKey(),
    'Content-Type': 'application/json',
  };
  try {
    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      debug('POST request successful');
      debug(response.body);
      if (!context.mounted) return;
      Provider.of<ImageNotifier>(context, listen: false)
          .saveAndExtract(response.body);
    } else {
      debug('Failed to make POST request.');
    }
  } catch (e) {
    debug('Error: $e');
  }
}

/// Adjust new json map recieved from api to match existing schema
Map<String, dynamic> transformMap(Map<String, dynamic> map) {
  //colorImage_2024-05-11--20-36-25.jpg, substrings to get the date section and time section
  String dateString = map["colorImage"].substring(11, 21);
  String timeString = map["colorImage"].substring(23, 31);
  String combinedDateTimeString = "${dateString}T$timeString";
  String formattedDateTimeString = combinedDateTimeString.replaceAll('-', '');
  //Remove dashes and put a T between the date and time parts so it can be parsed as DateTime, and later, an Iso String
  return {
    'imageId': map['colorImage'],
    'timestamp': DateTime.parse(formattedDateTimeString).toIso8601String(),
    'deviceId': map['deviceID'].toString(),
    'postDetectImgLink': map['colorImage'],
    'weight': map['weight_delta']?.toDouble(),
    'humidity': map['humidity']?.toDouble(),
    'temperature': map['temperature']?.toDouble(),
    'co2': map['co2_eq']?.toDouble(),
    'iaq': map['iaq']?.toDouble(),
    'pressure': map['pressure']?.toDouble(),
    'tvoc': map['tvoc']?.toDouble(),
    'transcription': map['transcription'],
  };
}

/// Get last detection in local database
Future<DateTime> getLatestTimestamp() async {
  final latestDetection = await Detection.latest();
  final timeStamp = latestDetection.timestamp;
  return timeStamp;
}

/// Get API key from shared preferences
String getApiKey() {
  return sharedPreferences.getString(SharedPreferencesKeys.apiKey) ??
      dotenv.env['API_KEY'] ??
      "";
}

/// Upload annotation to the api
Future<void> uploadAnnotation(String detectionId, List annotation) async {
  final detection = await Detection.find(detectionId);
  if (detection == null) return;
  final deviceId = detection.deviceId;
  final String url =
      '$apiEndpoint/update_annotation?deviceID=$deviceId&img_name=$detectionId';
  final Uri uri = Uri.parse(url);
  Map<String, String> headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'token': getApiKey(),
  };
  try {
    debug(url);
    final http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(annotation),
    );
    debug(response.body);
    if (response.statusCode == 200) {
      debug('POST request successful');
    } else {
      debug('Failed to make POST request.');
    }
  } catch (e) {
    debug('Error uploading annotation: $e');
  }
}
