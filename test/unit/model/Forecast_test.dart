library test.unit.model;

import 'package:dart_sunshine/model.dart';
@TestOn("content-shell")
import 'package:test/test.dart';

// import 'package:logging/logging.dart';

import '../config.dart';

main() async {
    // final Logger _logger = new Logger("test.Forecast");
    
    configLogging();
    //await saveDefaultCredentials();


    group('Forecast', () {
        setUp(() { });

    });
    
    test('> Serialization', () {
        final DateTime now = new DateTime.now();

        final Forecast forecast = new Forecast(now, "TestDescription", "abc", 0.1, 99.9);
        final Map<String,dynamic> json = forecast.toJson();
        final Forecast fcFromJson = new Forecast.fromJson(json);

        expect(fcFromJson.date,forecast.date);
        expect(fcFromJson.shortDescription,forecast.shortDescription);
        expect(fcFromJson.conditionCode,forecast.conditionCode);
        expect(fcFromJson.minTemp,forecast.minTemp);
        expect(fcFromJson.maxTemp,forecast.maxTemp);
    }); // end of 'Serialization' test

    test('> String-Serialization', () {
        final DateTime now = new DateTime.now();

        final Forecast forecast = new Forecast(now, "TestDescription", "abc", 0.1, 99.9);
        final String json = forecast.toString();
        final Forecast fcFromJson = new Forecast.fromJson(json);

        expect(fcFromJson.date,forecast.date);
        expect(fcFromJson.shortDescription,forecast.shortDescription);
        expect(fcFromJson.conditionCode,forecast.conditionCode);
        expect(fcFromJson.minTemp,forecast.minTemp);
        expect(fcFromJson.maxTemp,forecast.maxTemp);
    }); // end of 'String-Serialization' test

    test('> Pretty-String-Serialization', () {
        final DateTime now = new DateTime.now();

        final Forecast forecast = new Forecast(now, "TestDescription", "abc", 0.1, 99.9);
        final String json = forecast.toPrettyString();
        final Forecast fcFromJson = new Forecast.fromJson(json);

        expect(fcFromJson.date,forecast.date);
        expect(fcFromJson.shortDescription,forecast.shortDescription);
        expect(fcFromJson.conditionCode,forecast.conditionCode);
        expect(fcFromJson.minTemp,forecast.minTemp);
        expect(fcFromJson.maxTemp,forecast.maxTemp);
    }); // end of 'Pretty-String-Serialization' test

    // End of 'Forecast' group
}

// - Helper --------------------------------------------------------------------------------------
