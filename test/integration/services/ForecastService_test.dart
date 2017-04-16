@TestOn("dartium")
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

        test('> get uri', () async {
            final ForecastService service = new ForecastService(settings);

            final Map<String, dynamic> json = await service.toJson();
            //print(json);
            expect(json.containsKey("list"),isTrue);
            expect((json["list"] as List).length,14);

        }); // end of 'get uri' test


    });
    // End of 'ForecastService' group
}

// - Helper --------------------------------------------------------------------------------------
