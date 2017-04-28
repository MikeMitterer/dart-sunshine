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

part of dart_sunshine.services;

class ForecastServiceOnline implements ForecastService {
    static const String _FORECAST_BASE_URL = "http://api.openweathermap.org/data/2.5/forecast/daily";
    static const String _QUERY_PARAM = "q";
    static const String _FORMAT_PARAM = "mode";
    static const String _UNITS_PARAM = "units";
    static const String _DAYS_PARAM = "cnt";
    static const String _APPID_PARAM = "APPID";

    final Settings _settings;
    final int _numberOfDays;

    ForecastServiceOnline(this._settings, { numberOfDays: 14 } ) : _numberOfDays = numberOfDays {
        Validate.notNull(_settings);
        Validate.isTrue(_numberOfDays > 0 && _numberOfDays <= 14, "Number of days must be between "
            "1 and 14 days but was ${_numberOfDays}");
    }

    Uri get uri {
        final URIBuilder uriBuilder = new URIBuilder.fromString(_FORECAST_BASE_URL);

        uriBuilder.setParameter(_QUERY_PARAM,_settings.location);
        uriBuilder.setParameter(_FORMAT_PARAM,"json");
        uriBuilder.setParameter(_UNITS_PARAM,_settings.units == Units.METRIC ? "metric" : "imperial");
        uriBuilder.setParameter(_DAYS_PARAM,_numberOfDays.toString());
        uriBuilder.setParameter(_APPID_PARAM,_settings.apiKey);

        return uriBuilder.build();
    }

    Future<Map<String,dynamic>> toJson() async {
        final String response = await dom.HttpRequest.getString(uri.toString());
        return JSON.decode(response);

    }

    Future<List<Forecast>> toForecast() async {
        final Map<String,dynamic> json = await toJson();
        return json2Forecast(json);
    }

    // - private -------------------------------------------------------------------------------------------------------
}