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
import 'dart:convert';
import 'dart:html' as dom;
import 'dart:math' as Math;

import 'package:mdl/mdl.dart';
import 'package:mdl/mdlutils.dart';

import 'package:validate/validate.dart';
import 'package:logging/logging.dart';
import 'package:di/di.dart' as di;

/// Helper to prettify JSON output
const JsonEncoder PRETTYJSON = const JsonEncoder.withIndent('   ');

/// Represents one forecast entry
///
/// Serialization and DeSerialization to and from Json is included
class Forecast {
    final DateTime date;
    final String shortDescription;

    /// Condition codes: https://openweathermap.org/weather-conditions
    final String conditionCode;
    final double maxTemp;
    final double minTemp;

    /// Constructor strips off milli- and microseconds because the timestamp
    /// that comes from OpenWeatherMap is seconds-based
    Forecast(final DateTime date, this.shortDescription, this.conditionCode, this.minTemp, this.maxTemp)
        : this.date = date.subtract(new Duration(milliseconds: date.millisecond,microseconds: date.microsecond));
    
    factory Forecast.fromJson(final data) {
        Validate.notNull(data);
        Validate.isTrue(data is String || data is Map<String,dynamic>,"JSON-Data must bei either a String or a Map!");

        Map<String,dynamic> item;
        if(data is String) {
            item = JSON.decode(data);
        } else {
            item = data;
        }
        
        Validate.isTrue(item.containsKey("dt")
            && item.containsKey("weather") && item.containsKey("temp"),"Not a valid Forecast-Item!");

        final DateTime day = new DateTime.fromMillisecondsSinceEpoch(item["dt"] * 1000);
        final String description = item["weather"].first["description"];
        final String code = item["weather"].first["main"];
        final double min = double.parse(item["temp"]["min"].toString());
        final double max = double.parse(item["temp"]["max"].toString());

        return new Forecast(day, description, code, min, max);
    }

    Map<String,dynamic> toJson() {
        final Map<String,dynamic> json = new Map<String,dynamic>();
        json["dt"] = date.millisecondsSinceEpoch ~/ 1000;

        json["weather"] = new List();

        // Strange - but OpenWeatherMap is using a List too
        (json["weather"] as List).add(
            <String,dynamic>{
                "description" : shortDescription,
                "main" : conditionCode

            }
        );
        json["temp"] = new Map<String,dynamic>();
        (json["temp"] as Map<String,dynamic>)["min"] = minTemp;
        (json["temp"] as Map<String,dynamic>)["max"] = maxTemp;

        return json;
    }

    @override
    String toString() {
        return JSON.encode(toJson());
    }

    String toPrettyString() {
        return PRETTYJSON.convert(toJson());
    }
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

