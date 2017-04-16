@TestOn("content-shell")
import 'package:test/test.dart';

// import 'package:logging/logging.dart';

import 'package:dart_sunshine/services.dart';
import 'package:dart_sunshine/model.dart';

import '../config.dart';

main() async {
    // final Logger _logger = new Logger("test.ForecastService");
    
    configLogging();
    //await saveDefaultCredentials();

    final Settings settings = new Settings("London",Units.METRIC,OPEN_WEATHER_MAP_API_KEY);

    group('ForecastService', () {
        setUp(() { });

        test('> get uri', () {
            final ForecastService service = new ForecastService(settings);

            final String uriAsString = service.uri.toString();
            expect(uriAsString,"http://api.openweathermap.org/data/2.5/forecast/daily?"
                "APPID=dummy3a9b8385f7f7d542875a5ffed2d&cnt=14&mode=json&q=London&units=metric");

        }); // end of 'get uri' test


    });
    // End of 'ForecastService' group
}

// - Helper --------------------------------------------------------------------------------------
