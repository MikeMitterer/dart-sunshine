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
     
library dart_sunshine.components;

import 'dart:async';
import 'dart:collection';
import 'dart:html' as dom;
import 'dart:math' as Math;

import 'package:mdl/mdl.dart';
import 'package:mdl/mdlutils.dart';

import 'package:validate/validate.dart';
import 'package:logging/logging.dart';
import 'package:di/di.dart' as di;

import 'package:dart_sunshine/components/interfaces/stores.dart';
import 'package:dart_sunshine/model.dart';

part 'components/ForecastComponent.dart';

void registerSunshineComponents() {
    registerForecastComponent();
}