import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'screen_device.dart';

class ConnectedDeviceTile extends StatelessWidget {
  const ConnectedDeviceTile({Key? key, required this.d}) : super(key: key);

  final BluetoothDevice d;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.gps_fixed,
      ),
      title: Text(d.platformName),
      subtitle: const Text('device connected'),
      trailing: StreamBuilder<BluetoothConnectionState>(
        stream: d.connectionState,
        initialData: BluetoothConnectionState.disconnected,
        builder: (c, snapshot) {
          if (snapshot.data == BluetoothConnectionState.connected) {
            return ElevatedButton(
              child: const Text('Open'),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                d.discoverServices();
                return DeviceScreen(device: d);
              })),
            );
          }
          return Text(snapshot.data.toString());
        },
      ),
    );
  }
}
