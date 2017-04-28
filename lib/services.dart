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
import 'package:dart_sunshine/persistence.dart';

part "services/ForecastService.dart";
part "services/ForecastServiceOnline.dart";
part "services/ForecastServiceDB.dart";

/// Converts JSON to Forecast-List
Future<List<Forecast>> json2Forecast(final Map<String,dynamic> json) async {
    final List<Forecast> forecast = new List<Forecast>();

    if(json != null && json.containsKey("list")) {
        final List<Map<String,dynamic>> list = json["list"] as List<Map<String,dynamic>>;
        list.forEach((final Map<String,dynamic> item) {
            forecast.add(new Forecast.fromJson(item));
        });
    }

    return forecast;
}