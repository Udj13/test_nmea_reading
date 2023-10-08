import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screen_find_devices.dart';
import 'screen_bluetooth_off.dart';
import 'dart:async';
import 'dart:io';

void main() {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(const TestNMEAReadApp());
    });
  } else {
    runApp(const TestNMEAReadApp());
  }
}

class TestNMEAReadApp extends StatelessWidget {
  const TestNMEAReadApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterBluePlus.setLogLevel(LogLevel.error, color: true);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<BluetoothAdapterState>(
          stream: FlutterBluePlus.adapterState,
          initialData: BluetoothAdapterState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothAdapterState.on) {
              return const FindDevicesScreen();
//              return DeviceDemoScreen();
            }
            FlutterBluePlus.stopScan();
            if (Platform.isAndroid) {
              FlutterBluePlus.turnOn();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}
