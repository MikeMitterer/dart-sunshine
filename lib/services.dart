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
     
library dart_sunshine.services;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as dom;

import 'package:http_utils/http_utils.dart';
import 'package:validate/validate.dart';
import 'package:dart_sunshine/model.dart';

class ForecastService {
    static const String _FORECAST_BASE_URL = "http://api.openweathermap.org/data/2.5/forecast/daily";
    static const String _QUERY_PARAM = "q";
    static const String _FORMAT_PARAM = "mode";
    static const String _UNITS_PARAM = "units";
    static const String _DAYS_PARAM = "cnt";
    static const String _APPID_PARAM = "APPID";

    final Settings _settings;
    final int _numberOfDays;

    ForecastService(this._settings, { numberOfDays: 14 } ) : _numberOfDays = numberOfDays {
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
        uriBuilder.setParameter(_APPID_PARAM,_settings.openWeatherMapApiKey);

        return uriBuilder.build();
    }

    Future<Map<String,dynamic>> toJson() async {
//        final dom.HttpRequest request = new dom.HttpRequest();

        final String response = await dom.HttpRequest.getString(uri.toString());
        return JSON.decode(response);

//        request.open("GET", uri.toString());
//        request.setRequestHeader('Accept', 'application/json');
//
//        final Completer<Map<String,dynamic>> completer = new Completer();
//        request.onLoadEnd.listen((final ProgressEvent event) {
//
//            if(request.readyState == HttpRequest.DONE) {
//                switch(request.status) {
//                    case 200:
//                        final String result = request.responseText;
//                        return completer.complete(JSON.decode(result));
//                    default:
//                        completer.completeError("Request failed! Status: ${request.status} / ${request.statusText}");
//                }
//            }
//        });
//        request.send();

//        return completer.future;
    }

    // - private -------------------------------------------------------------------------------------------------------


}