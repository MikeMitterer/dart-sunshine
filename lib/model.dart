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
     
library dart_sunshine.model;

import 'dart:async';
import 'dart:collection';
import 'dart:html' as dom;
import 'dart:math' as Math;

import 'package:mdl/mdl.dart';
import 'package:mdl/mdlutils.dart';

import 'package:validate/validate.dart';
import 'package:logging/logging.dart';
import 'package:di/di.dart' as di;

/// Represents one forecast entry
class Forecast {
    final DateTime _date;
    final String _shortDescription;

    /// Condition codes: https://openweathermap.org/weather-conditions
    final String _conditionCode;
    final int _maxTemp;
    final int _minTemp;

    Forecast(this._date, this._shortDescription, this._conditionCode, this._maxTemp, this._minTemp);
}

/// Temperature is available in Fahrenheit, Celsius
///
/// For temperature in Celsius use units=metric
/// For temperature in Fahrenheit use units=imperial
enum Units {
    METRIC, IMPERIAL
}

class Settings {
    /// Location can be defined either by city name, city ID, geographic coordinates or by ZIP code
    /// More: https://openweathermap.org/forecast16#data
    final String _location;
    final Units _units;
    final String _openWeatherMapApiKey;

    Settings(this._location, this._units,this._openWeatherMapApiKey) {
        Validate.notBlank(_location);
        Validate.notNull(_units);
        Validate.notBlank(_openWeatherMapApiKey);
    }

    Units get units => _units;

    String get location => _location;

    String get openWeatherMapApiKey => _openWeatherMapApiKey;

}

