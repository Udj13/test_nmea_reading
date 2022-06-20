import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'model.dart';

void startBluetoothListener(BluetoothDevice device) {
  try {
    print('Start listening --------------------------------------------------');
    device.services.listen((services) {
      print('services.listen: ${services}');
      BluetoothService? agloraService;
      services.forEach((service) {
        print('service: ${service.uuid.toString()}');
        if (service.uuid.toString().startsWith("0000ffa2") ||
            service.uuid.toString().startsWith("0000ffe0")) {
          agloraService = service;
        }
      });

      if (agloraService != null) {
        var characteristics = agloraService!.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString().startsWith("0000ffe1")) {
            print('========================= 0000ffe1 ======================');
            c.setNotifyValue(true);
            c.read();
            c.descriptors.forEach((descriptor) {
              print('Descriptor ${descriptor.uuid}: ${descriptor.value}');
              descriptor.value.listen((value) {
                print('New value: ${descriptor.uuid} = ${value}');
              });
            });

            c.onValueChangedStream.listen((value) {
              //print('NEW VALUE');
              newDataReceived(value);
            });
          }
        }
      }
    });
  } catch (e) {
    print(e);
  }
  ;
}
