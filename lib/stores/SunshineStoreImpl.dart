/*
 * Copyright (c) 2017, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 * 
 * All Rights Reserved.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of dart_sunshine.stores;

/// [SunshineStoreImpl] implements the Sunshine-Data-Model
///
@MdlComponentModel @di.Injectable()
class SunshineStoreImpl extends Dispatcher implements SunshineStore {
    final Logger _logger = new Logger('dart_sunshine.stores.SunshineStoreImpl');

    final List<Forecast> _forecasts = new List<Forecast>();
    DateTime _midnight;

    SunshineStoreImpl(final ActionBus actionbus) : super(actionbus) {
        Validate.notNull(actionbus);

        final DateTime now = new DateTime.now();
        _midnight = now.subtract(new Duration(hours: now.hour));

        _bindActions();
    }

    /// Returns all forecasts from today and newer
    List<Forecast> get forecasts =>
        _forecasts.where( (final Forecast forecast) =>
                    forecast.date
                    .difference(_midnight)
                    .inHours > 0).toList();

    // - private -------------------------------------------------------------------------------------------------------

    void _bindActions() {

        on(NetworkStateChanged.NAME)
            .map((final Action action) => action as NetworkStateChanged)
            .listen((final NetworkStateChanged action) async {

            _logger.info("Received ${action.runtimeType} - NetworkState: ${action.data}");
            await _updateForecasts(action.data);
            
            emitChange();
        });

        on(SettingsChanged.NAME)
            .map((final Action action) => action as SettingsChanged)
            .listen((final SettingsChanged action) async {

            _logger.info("Received ${action.runtimeType}");
            await _updateForecasts(_networkstate);

            emitChange();
        });

    }

    Future _updateForecasts(final NetworkState state) async {
        final SettingsDAO daoSettings = new SettingsDAO();
        final ForecastDAO daoForecast = new ForecastDAO();
        final Settings settings = await daoSettings.settings;

        if(state == NetworkState.ONLINE) {
            final ForecastService onlineService = new ForecastServiceOnline(settings);

            /// Read Forecast from Online-Service and write it to the DB
            Future<List<Forecast>> _updateOnlineForecast() async {
                final List<Forecast> forecasts = await onlineService.toForecast();
                await daoForecast.saveForecast(forecasts);

                _logger.info("Forecast updated from Online-Service!");
                daoForecast.saveLastUpdate(new DateTime.now());
                return forecasts;
            }

            try {
                final DateTime last_update = await daoForecast.last_update;
                
                _logger.info("Last Forecast-DB-update: ${last_update}");
                if(last_update.difference(new DateTime.now()).inHours > 1) {
                    await _updateOnlineForecast();
                }

            } on DBException {
                // Last_update was not available which means no data in db
                await _updateOnlineForecast();
            }

        }
        final ForecastService offlineService = new ForecastServiceDB();

        _forecasts.clear();
        _forecasts.addAll(await offlineService.toForecast());
    }

    NetworkState get _networkstate => dom.window.navigator.onLine ? NetworkState.ONLINE : NetworkState.OFFLINE;
}