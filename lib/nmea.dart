import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:test_nmea_reading/model.dart';

class MinimumNavDATA {
  double? latitude;
  double? longitude;
  double? speed;
  double? course;
  bool warning = true;

  MinimumNavDATA(
    this.latitude,
    this.longitude,
    this.speed,
    this.course,
    this.warning,
  );
}

class NMEAParser {
  var _nmeaStreamController = StreamController<MinimumNavDATA>.broadcast();
  Stream<MinimumNavDATA> get nmeaDataStream => _nmeaStreamController.stream;

  String _nmeaBuffer = '';
  String _previousNMEAPacket = '';

  void parse({required String nmeaData}) {
    if (nmeaData != _previousNMEAPacket) {
      _previousNMEAPacket = nmeaData;
      _nmeaBuffer += nmeaData;
    }

    final int indexOfLastS = _nmeaBuffer.lastIndexOf(r'$');

    if (indexOfLastS > 0) {
      final String dataForParsing = _nmeaBuffer.substring(1, indexOfLastS);
      List<String> splittedNMEA = dataForParsing.split(r'$');
      while (splittedNMEA.isNotEmpty) {
        _parseSingleNMEAPacket(splittedNMEA.first);
        splittedNMEA.removeAt(0);
      }
    }

    _nmeaBuffer = _nmeaBuffer.substring(indexOfLastS); //end of line
  }

  void _parseSingleNMEAPacket(String nmea) {
    print('Start parsing: $nmea');

    var splitNMEAString = nmea.split(',');

    if (_checkNMEACRC(nmea)) {
      //RMC - Recommended minimum specific GPS/Transit data
      //GPRMC - GPS
      //GNRMC - GLONASS + GPS
      //GLRMC - GLONASS
      if (splitNMEAString[0].contains('RMC')) {
        try {
          final bool warning = (splitNMEAString[2] != 'A');

          final newNavData;

          if (!warning) {
            final double latitude = _nmeaToDecimalDegrees(
              splitNMEAString[3],
              splitNMEAString[4],
            );
            final longitude = _nmeaToDecimalDegrees(
              splitNMEAString[5],
              splitNMEAString[6],
            );
            final speed = double.tryParse(splitNMEAString[7]) ?? 0.0;
            final course = double.tryParse(splitNMEAString[8]) ?? 0.0;
            newNavData = MinimumNavDATA(
              latitude,
              longitude,
              speed * 1.852,
              course,
              warning,
            );
          } else {
            newNavData = MinimumNavDATA(0, 0, 0, 0, true);
          }

          _nmeaStreamController.add(newNavData);

          // if (kDebugMode)
          //   print('NMEA data: lat ${newNavData.latitude}, '
          //       'lon ${newNavData.longitude}, '
          //       'speed ${newNavData.speed} km/h, '
          //       'course ${newNavData.course}');
        } catch (e) {
          if (kDebugMode)
            print('error parsing nav data in _parseSingleNMEAPacket: $e');
        }
      }
    }
  }

  bool _checkNMEACRC(String nmea) {
    try {
      final String checkSumOriginal =
          nmea.split('*').last.toString().replaceAll("\r\n", "").toUpperCase();
      nmea = nmea.substring(0, nmea.indexOf('*'));

      int crc = 0;
      List<int> bytes = nmea.codeUnits;
      for (var b in bytes) {
        crc ^= b;
      }

      final String checkSumCalculated = crc.toRadixString(16).toUpperCase();
      final result = (checkSumOriginal == checkSumCalculated);
      return result;
    } catch (e) {
      if (kDebugMode) print('error in nmea.dart / checkNMEACRC func: $e');
    }
    return false;
  }

  double _nmeaToDecimalDegrees(String nmeaPos, String quadrant)

  ///    Convert NMEA absolute position to decimal degrees
  ///    "ddmm.mmmm" or "dddmm.mmmm" really is D+M/60,
  ///    then negated if quadrant is 'W' or 'S'
  {
    int digitCount = (nmeaPos[4] == '.' ? 2 : 3);
    int integerPart = int.tryParse(nmeaPos.substring(0, digitCount)) ?? 0;
    double nmeaDouble = double.tryParse(nmeaPos) ?? 00;
    nmeaDouble -= integerPart * 100;
    double result = integerPart + (nmeaDouble / 60);
    if (quadrant == 'W' || quadrant == 'S') result *= -1;
    return result;
  }
}
