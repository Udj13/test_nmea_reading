import 'package:flutter/foundation.dart';

String _nmeaBuffer = '';

void easyNMEAParser({required String nmeaData}) {
  final double _latitude;
  final double _longitude;

  _nmeaBuffer += nmeaData;
  print('===================================================================');
//  if (kDebugMode) print('nmeaBuffer: $_nmeaBuffer');

  List<String> splittedNMEA = _nmeaBuffer.split(r'$');
//  print('splittedNMEA: $splittedNMEA');

  while (splittedNMEA.length > 1) {
    print('-----------------------------------------');

    _parseSingleNMEAPacket(splittedNMEA.first);
    _nmeaBuffer = _nmeaBuffer.substring(splittedNMEA[0].length - 1);
    splittedNMEA.removeAt(0);

    print('splittedNMEA length: ${splittedNMEA.length}');
    print('nmeaBuffer length: ${_nmeaBuffer.length}');
  }

//  print('splittedNMEA: ${splittedNMEA.length}');
//  print('nmeaBuffer: ${_nmeaBuffer}');

  _latitude = 0.0;
  _longitude = 0.0;
}

void _parseSingleNMEAPacket(String nmea) {
  const headerPosition = 0;
  const latituderPosition = 1;
  const longituderPosition = 3;
  const speedPosition = 7;
  const headingPosition = 8;

  print(nmea);

  var splitNMEAString = nmea.split(',');

  if (checkNMEACRC(splitNMEAString)) {
    if (splitNMEAString[headerPosition] == 'GPRMC') {
      final latitude = splitNMEAString[latituderPosition];
      final longitude = splitNMEAString[longituderPosition];
      final speed = splitNMEAString[speedPosition];
      final heading = splitNMEAString[headingPosition];
      print(
          'Navigation data: $latitude, $longitude, speed: $speed, heading: $heading');
    }
  }
}

bool checkNMEACRC(List<String> splitNMEAString) {
  final String checkSumOriginal = splitNMEAString.last.substring(1);
  splitNMEAString.removeLast();
  int crc = 0;
  for (var word in splitNMEAString) {
    List<int> bytes = word.codeUnits;
    for (var b in bytes) {
      crc ^= b;
    }
  }
  final String checkSumCalculated = crc.toRadixString(16);
  return (checkSumOriginal == checkSumCalculated);
}
