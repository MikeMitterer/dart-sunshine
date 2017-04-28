@TestOn("content-shell")
library test.unit.service.forecastservicedb;

import 'dart:convert';
import 'dart:html';
import 'package:dart_sunshine/mock.dart';
import 'package:dart_sunshine/model.dart';
import 'package:dart_sunshine/persistence.dart';
import 'package:dart_sunshine/services.dart';
import 'package:http_utils/http_utils.dart';
import 'package:test/test.dart';

// import 'package:logging/logging.dart';

import '../config.dart';

main() async {
    // final Logger _logger = new Logger("test.unit.service.forecastservicedb");
    
    configLogging();
    //await saveDefaultCredentials();

    final Uri localForecast = new URIBuilder.forFile("../_resources/sample_data.json").build();
    List<Forecast> forecastsFromResources;
    
    group('ForecastServiceDB', () {
        setUp(() async {
            final String jsonString = await HttpRequest.getString(localForecast.toString());
            final Map<String,dynamic> json = JSON.decode(jsonString);
            final ForecastService service = new MockForecastService(json);
            forecastsFromResources = await service.toForecast();

            final ForecastDAO dao = new ForecastDAO();
            await dao.saveForecast(forecastsFromResources);
        });

        test('> Get Forecast from DB', () async {
            final ForecastService service = new ForecastServiceDB();
            final List<Forecast> forecasts = await service.toForecast();
            
            expect(forecasts,isNotNull);
            expect(forecastsFromResources,isNotNull);

            expect(14,forecasts.length);
            expect(forecasts.length,forecastsFromResources.length);

            expect(forecasts.first.date,forecastsFromResources.first.date);
            expect(forecasts.first.shortDescription,forecastsFromResources.first.shortDescription);
            expect(forecasts.first.conditionCode,forecastsFromResources.first.conditionCode);
            expect(forecasts.first.minTemp,forecastsFromResources.first.minTemp);
            expect(forecasts.first.maxTemp,forecastsFromResources.first.maxTemp);

            expect(forecasts.last.date,forecastsFromResources.last.date);
            expect(forecasts.last.shortDescription,forecastsFromResources.last.shortDescription);
            expect(forecasts.last.conditionCode,forecastsFromResources.last.conditionCode);
            expect(forecasts.last.minTemp,forecastsFromResources.last.minTemp);
            expect(forecasts.last.maxTemp,forecastsFromResources.last.maxTemp);

        }); // end of 'Get Forecast from DB' test
                
    });
    // End of 'ForecastServiceDB' group
}

// - Helper --------------------------------------------------------------------------------------
