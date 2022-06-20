import 'nmea.dart';

List<int> lastValue = [];

void newDataReceived(List<int> newValue) {
  if (newValue.hashCode != lastValue.hashCode) {
    String rStr = '';
    newValue.forEach((element) {
      rStr += String.fromCharCode(element);
    });

    easyNMEAParser(nmeaData: rStr);

    lastValue = newValue;
  }
}

void callbackNmea({required double latitude, required double longitude}) {}
