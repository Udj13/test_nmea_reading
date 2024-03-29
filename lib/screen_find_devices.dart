import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bluetooth.dart';
import 'widget_scan_result_tile.dart';
import 'widget_connected_device_tile.dart';
import 'screen_device.dart';
import 'model.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find BLE device'),
//        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBluePlus.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(const Duration(seconds: 2))
                      .asyncMap((_) => FlutterBluePlus.connectedSystemDevices),
                  initialData: const [],
                  builder: (c, snapshot) => Column(
                        children: snapshot.data!
                            .map((d) => ConnectedDeviceTile(d: d))
                            .toList(),
                      )),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.scanResults,
                initialData: const [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            print("Connect in list pressed");
                            openDevice(r.device);
                            return DeviceScreen(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: () => FlutterBluePlus.stopScan(),
              backgroundColor: Colors.red.shade100,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBluePlus.startScan(
                    timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

Future<void> openDevice(BluetoothDevice device) async {
  print("open device func");
  print(device);
  try {
    await device.connect();
  } catch (error) {
    print(error);
  }
  print('openDevice - device.connect passed');
  print(device);
  startBluetoothListener(device);
  startNMEAListen();
}
