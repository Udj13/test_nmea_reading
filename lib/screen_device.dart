import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/cupertino.dart';
import 'model.dart';
import '../bluetooth.dart';
import 'nmea.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(device.name),
          actions: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) {
                VoidCallback? onPressed;
                String text;
                switch (snapshot.data) {
                  case BluetoothDeviceState.connecting:
                    text = 'waiting...';
                    break;
                  case BluetoothDeviceState.disconnecting:
                    text = 'disconnecting...';
                    break;
                  case BluetoothDeviceState.connected:
                    onPressed = () => device.disconnect();
                    text = 'Disconnect';
                    device.discoverServices();
                    break;
                  case BluetoothDeviceState.disconnected:
                    onPressed = () => device.connect();
                    text = 'Connect';
                    break;
                  default:
                    onPressed = null;
                    text = snapshot.data.toString().substring(21).toUpperCase();
                    break;
                }
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        startBluetoothListener(device);
                        startNMEAListen();
                      },
                      icon: const Icon(Icons.restart_alt),
                    ),
                    OutlinedButton(
                        onPressed: onPressed,
                        style: OutlinedButton.styleFrom(
                          primary: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          text,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .button
                              ?.copyWith(color: Colors.white),
                        )),
                    const SizedBox(width: 10),
                    BluetoothStatusIcon(device: device),
                    const SizedBox(width: 10),
                  ],
                );
              },
            )
          ],
        ),
        body: SingleChildScrollView(
            child: StreamBuilder<MinimumNavDATA>(
          stream: nmea.nmeaDataStream,
          builder: (c, snapshot) => Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('latitude', style: TextStyle(color: Colors.grey)),
                Text(snapshot.data?.latitude?.toStringAsFixed(6) ?? ''),
                const Text('longitude', style: TextStyle(color: Colors.grey)),
                Text(snapshot.data?.longitude?.toStringAsFixed(6) ?? ''),
                const Text('speed', style: TextStyle(color: Colors.grey)),
                Text(snapshot.data?.speed?.toStringAsFixed(1) ?? ''),
                const Text('course', style: TextStyle(color: Colors.grey)),
                Text(snapshot.data?.course?.toStringAsFixed(0) ?? ''),
                const Text('update time', style: TextStyle(color: Colors.grey)),
                Text(DateTime.now().toString().substring(0, 19) ?? ''),
              ],
            ),
          ),
        )),
        bottomNavigationBar: const BottomAppBar(
          color: Colors.white,
          child: null,
        ));
  }
}

class DiscoveringServicesIcon extends StatelessWidget {
  const DiscoveringServicesIcon({
    Key? key,
    required this.device,
  }) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: device.isDiscoveringServices,
      initialData: false,
      builder: (c, snapshot) => IndexedStack(
        index: snapshot.data! ? 1 : 0,
        children: const [
          Icon(Icons.account_tree),
          SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class BluetoothStatusIcon extends StatelessWidget {
  const BluetoothStatusIcon({
    Key? key,
    required this.device,
  }) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothDeviceState>(
      stream: device.state,
      initialData: BluetoothDeviceState.connecting,
      builder: (c, snapshot) =>
          (snapshot.data == BluetoothDeviceState.connected)
              ? Icon(CupertinoIcons.bluetooth,
                  color: Colors.lightGreenAccent.shade100)
              : const Icon(Icons.bluetooth_disabled, color: Colors.redAccent),
    );
  }
}
