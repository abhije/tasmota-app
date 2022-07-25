import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../data/models/device.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

//------------------------------------------------------------------------------
//-- DEVICE NOTIFIER --
//------------------------------------------------------------------------------

class DeviceNotifier extends StateNotifier<AsyncValue<bool>> {
  DeviceNotifier(this.device) : super(const AsyncLoading()) {
    _init();
  }

  final Device device;

//-- Init Method ---------------------------------------------------------------

  void _init() async {
    try {
      String statUrl =
          'http://${device.ip}/cm?user=admin&password=${device.apiPasswd}&cmnd=POWER${device.deviceId}';
      var response = await http
          .get(Uri.parse(statUrl))
          .timeout(const Duration(seconds: 10));
      //await Future.delayed(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['POWER${device.deviceId.toString()}'] == "ON") {
          state = const AsyncValue.data(true);
        } else {
          state = const AsyncValue.data(false);
        }
      }
    } catch (e) {
      var logger = Logger();
      logger.e(e);
    }
  }

//-- Toggle Method -------------------------------------------------------------

  void toggle() async {
    try {
      state = const AsyncLoading();
      String addr =
          'http://${device.ip}/cm?user=admin&password=awdLIJ098&cmnd=POWER${device.deviceId} Toggle';
      var response =
          await http.get(Uri.parse(addr)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['POWER${device.deviceId.toString()}'] == "ON") {
          state = const AsyncValue.data(true);
        } else {
          state = const AsyncValue.data(false);
        }
      }
    } catch (e) {
      var logger = Logger();
      logger.e(e);
    }
  }
}
