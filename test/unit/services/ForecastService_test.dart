@TestOn("content-shell")
library test.unit.services;

import 'dart:convert';
import 'dart:html';
import 'package:dart_sunshine/mock.dart';
import 'package:test/test.dart';
import 'package:http_utils/http_utils.dart';

// import 'package:logging/logging.dart';

import 'package:dart_sunshine/services.dart';
import 'package:dart_sunshine/model.dart';

import '../config.dart';

main() async {
    // final Logger _logger = new Logger("test.ForecastService");
    
    configLogging();
    //await saveDefaultCredentials();

    final Settings settings = new Settings("London",Units.METRIC,OPEN_WEATHER_MAP_API_KEY);
    final Uri localForecast = new URIBuilder.forFile("../_resources/sample_data.json").build();

    group('ForecastService', () {
        setUp(() { });

        test('> get uri', () {
            final ForecastService service = new ForecastService(settings);

            final String uriAsString = service.uri.toString();
            expect(uriAsString,"http://api.openweathermap.org/data/2.5/forecast/daily?"
                "APPID=dummy3a9b8385f7f7d542875a5ffed2d&cnt=14&mode=json&q=London&units=metric");

        }); // end of 'get uri' test

        test('> loadLocalResource', () async {
            final String jsonString = await HttpRequest.getString(localForecast.toString());
            final Map<String,dynamic> json = JSON.decode(jsonString);
            
            expect((json["list"] as List).length,14);

        }); // end of 'loadLocalResource' test

        test('> toForecast', () async {
            final String jsonString = await HttpRequest.getString(localForecast.toString());
            final Map<String,dynamic> json = JSON.decode(jsonString);

            final ForecastService service = new MockForecastService(settings,json);
            final List<Forecast> forecast = await service.toForecast();

            expect(forecast.length,14);

            forecast.forEach((final Forecast f) {
                print("${f.date}, ${f.shortDescription}, ${f.conditionCode}, ${f.minTemp}, ${f.maxTemp}");
            });


        }); // end of 'toForecast' test


    });
    // End of 'ForecastService' group
}

// - Helper --------------------------------------------------------------------------------------
