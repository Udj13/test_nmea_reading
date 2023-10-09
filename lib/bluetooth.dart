import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'model.dart';
import 'dart:io';

List<int> oldValue = [];
StreamSubscription<List<int>>? subscription;
StreamSubscription<BluetoothConnectionState>? connectionStateSubscription;

Future<void> startBluetoothListener(BluetoothDevice device) async {
  try {
    print('Start listening --------------------------------------------------');

    List<BluetoothService> services = await device.discoverServices();

    if (Platform.isAndroid) {
      final newMtu = await device.requestMtu(256);
      print('Android. Try to request new MTU. The new MTU is $newMtu');
    }

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
          //c.read();
          // for (var descriptor in c.descriptors) {
          //   //print('Descriptor ${descriptor.uuid}: ${descriptor.value}');
          //   descriptor.onValueReceived.listen((value) {
          //     //print('New descriptor value: ${descriptor.uuid} = ${value}');
          //   });
          // }

          print("Set subscriptions to ${c.characteristicUuid}");
          //if (subscription != null) return;
          subscription = c.onValueReceived.listen((value) {
            //print('NEW VALUE $value');
            try {
              newDataReceived(value);
            } catch (e) {
              print('Error in newDataReceived function');
            }

            c.read().catchError((e) {
              //for Android
              print('Characteristic read error');
              return ([0]);
            }).then((value) => newDataReceived(value));
          });

          await c.setNotifyValue(true);
          await c.read();

          print("Set connection state listener");
          connectionStateSubscription ??=
              device.connectionState.listen((BluetoothConnectionState state) {
            if (state == BluetoothConnectionState.disconnected) {
              subscription?.cancel(); // must cancel!
              subscription == null;
              print("Stop subscription");
            }
          });
        }
      }
    }
  } catch (e) {
    if (kDebugMode) print(e);
  }
}
