@TestOn("content-shell")
library test.unit.persistance;

import 'dart:convert';
import 'dart:html';
import 'package:dart_sunshine/mock.dart';
import 'package:dart_sunshine/model.dart';
import 'package:dart_sunshine/services.dart';
import 'package:http_utils/http_utils.dart';
import 'package:test/test.dart';
import 'package:dart_sunshine/persistance.dart';

// import 'package:logging/logging.dart';

import '../config.dart';

main() async {
    // final Logger _logger = new Logger("test.Persistance");
    
    configLogging();
    //await saveDefaultCredentials();

    final Settings settings = new Settings("London",Units.METRIC,OPEN_WEATHER_MAP_API_KEY);
    final Uri localForecast = new URIBuilder.forFile("../_resources/sample_data.json").build();

    group('Persistance', () {
        setUp(() {

        });

        test('> Save "Last update"', () async {
            final DateTime now = new DateTime.now();

            final ForecastDAO dao = new ForecastDAO();
            dao.saveLastUpdate(now);

            final DateTime fromDB = await dao.last_update;
            expect(fromDB.toIso8601String(),now.toIso8601String());

        }); // end of 'Save "Last update"' test

        test('> Forecasts', () async {
            final String jsonString = await HttpRequest.getString(localForecast.toString());
            final Map<String,dynamic> json = JSON.decode(jsonString);

            final ForecastService service = new MockForecastService(settings,json);
            final List<Forecast> forecasts = await service.toForecast();

            final ForecastDAO dao = new ForecastDAO();
            await dao.saveForecast(forecasts);

            final List<Forecast> forecastsFromDB = await dao.forecasts;

            expect(14,forecasts.length);
            expect(forecastsFromDB.length,forecasts.length);

            expect(forecastsFromDB.first.date,forecasts.first.date);
            expect(forecastsFromDB.first.shortDescription,forecasts.first.shortDescription);
            expect(forecastsFromDB.first.conditionCode,forecasts.first.conditionCode);
            expect(forecastsFromDB.first.minTemp,forecasts.first.minTemp);
            expect(forecastsFromDB.first.maxTemp,forecasts.first.maxTemp);

            expect(forecastsFromDB.last.date,forecasts.last.date);
            expect(forecastsFromDB.last.shortDescription,forecasts.last.shortDescription);
            expect(forecastsFromDB.last.conditionCode,forecasts.last.conditionCode);
            expect(forecastsFromDB.last.minTemp,forecasts.last.minTemp);
            expect(forecastsFromDB.last.maxTemp,forecasts.last.maxTemp);

        }); // end of 'Forecasts' test


    });
    // End of 'Persistance' group
}

// - Helper --------------------------------------------------------------------------------------
