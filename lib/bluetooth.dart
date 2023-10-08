import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'model.dart';

List<int> oldValue = [];

Future<void> startBluetoothListener(BluetoothDevice device) async {
  try {
    print('Start listening --------------------------------------------------');

    List<BluetoothService> services = await device.discoverServices();

    BluetoothService? agloraService;
    //print('services.listen: ${services}');
    for (var service in services) {
      print('service: ${service.uuid.toString()}');
      if (service.uuid.toString().startsWith("0000ffa2") ||
          service.uuid.toString().startsWith("0000ffe0")) {
        agloraService = service;
      }
    }

    if (agloraService != null) {
      var characteristics = agloraService.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString().startsWith("0000ffe1")) {
          //print('========================= 0000ffe1 ======================');
          c.setNotifyValue(true);
          c.read();
          for (var descriptor in c.descriptors) {
            //print('Descriptor ${descriptor.uuid}: ${descriptor.value}');
            descriptor.onValueReceived.listen((value) {
              //print('New descriptor value: ${descriptor.uuid} = ${value}');
            });
          }

          final subscription = c.onValueReceived.listen((value) {
            print('NEW VALUE $value');
            try {
              newDataReceived(value);
            } catch (e) {
              print('Error in newDataReceived function');
            }
          });

          device.connectionState.listen((BluetoothConnectionState state) {
            if (state == BluetoothConnectionState.disconnected) {
              subscription.cancel(); // must cancel!
            }
          });
        }
      }
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
}
