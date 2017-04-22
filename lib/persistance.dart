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
     
library dart_sunshine.persistance;

import 'dart:async';

import 'package:dart_sunshine/model.dart';
import "package:lawndart/lawndart.dart";
import "package:validate/validate.dart";


part 'persitance/exeptions.dart';
part 'persitance/ForecastDAO.dart';

/// DBName und Tabellennamen für die DAO-Files
class _DBSetting {
    static const String DBNAME = "dart.sunshine";
}

/// Namen der Tabellen und der "default" DB werden festgelegt.
/// Damit ist folgender Zugriff möglich:
///     _Table.IDENTITY.name bzw. _Table.IDENTITY.db
///
class Table {
    static const String _db = _DBSetting.DBNAME;
    final String name;

    static const Table FORECAST = const Table("forecast");

    const Table(this.name);

    String toString() => name;
    String get db => _db;
}