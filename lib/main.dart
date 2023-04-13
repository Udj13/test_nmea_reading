import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'screen_find_devices.dart';
import 'screen_bluetooth_off.dart';

void main() {
  runApp(const TestNMEAReadApp());
}

class TestNMEAReadApp extends StatelessWidget {
  const TestNMEAReadApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterBluePlus.instance.setLogLevel(LogLevel.emergency);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const FindDevicesScreen();
//              return DeviceDemoScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}
