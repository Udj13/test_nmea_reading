import 'package:flutter/foundation.dart';

import 'nmea.dart';

NMEAParser nmea = NMEAParser();

List<int> lastValue = [];

void startNMEAListen() {
  nmea.nmeaDataStream.listen((event) {
    debugPrint(
        'listener nmea stream: ${event.latitude}, ${event.longitude}, ${event.speed}, ${event.course}');
  });
}

void newDataReceived(List<int> newValue) {
  if (newValue.hashCode != lastValue.hashCode) {
    String rStr = '';
    for (var element in newValue) {
      rStr += String.fromCharCode(element);
    }
    //print('newDataReceived, rStr=: $rStr');

    nmea.parse(nmeaData: rStr);

    lastValue = newValue;
  }
}
