@TestOn("content-shell")
library test.unit.persistence.settingsdao;

import 'package:dart_sunshine/model.dart';
import 'package:test/test.dart';
import 'package:dart_sunshine/persistence.dart';

// import 'package:logging/logging.dart';

import '../config.dart';

main() async {
    // final Logger _logger = new Logger("test.unit.persistence.settingsdao");
    
    configLogging();
    //await saveDefaultCredentials();
    final Settings defaultSettings = new Settings("London",Units.METRIC,OPEN_WEATHER_MAP_API_KEY);

    group('SettingsDAO', () {
        setUp(() async {
            final SettingsDAO dao = new SettingsDAO();
            await dao.save(defaultSettings);
        });

        test('> read', () async {
            final SettingsDAO dao = new SettingsDAO();
            final Settings settings = await dao.settings;

            expect(settings.location,defaultSettings.location);
            expect(settings.units,defaultSettings.units);
            expect(settings.apiKey,defaultSettings.apiKey);
        }); // end of 'read' test

    });
    // End of 'SettingsDAO' group
}

// - Helper --------------------------------------------------------------------------------------
