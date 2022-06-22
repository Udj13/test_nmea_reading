import 'nmea.dart';

NMEAParser nmea = NMEAParser();

List<int> lastValue = [];

void startNMEAListen() {
  nmea.nmeaDataStream.listen((event) {
    print(
        'listener nmea stream: ${event.latitude}, ${event.longitude}, ${event.speed}, ${event.course}');
  });
}

void newDataReceived(List<int> newValue) {
  if (newValue.hashCode != lastValue.hashCode) {
    String rStr = '';
    newValue.forEach((element) {
      rStr += String.fromCharCode(element);
    });

    nmea.parse(nmeaData: rStr);

    lastValue = newValue;
  }
}
