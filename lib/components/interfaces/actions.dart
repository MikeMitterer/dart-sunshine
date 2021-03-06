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
     
library dart_sunshine.components.actions;

import 'package:mdl/mdlflux.dart';
import 'package:dart_sunshine/model.dart';

/// [NetworkStateChange] informs the [SunshineStore] about the current network state
class NetworkStateChanged extends DataAction<NetworkState> {
    static const ActionName NAME = const ActionName("dart_sunshine.components.actions.NetworkStateChanged");
    NetworkStateChanged(final NetworkState state) : super(NAME,state);
}

/// Settings have changed
class SettingsChanged extends Action {
    static const ActionName NAME = const ActionName("dart_sunshine.components.actions.SettingsChanged");
    SettingsChanged() : super(ActionType.Signal,NAME);
}