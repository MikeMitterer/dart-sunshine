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
     
part of dart_sunshine.components;

/* 
/// Basic DI configuration for [Forecast]
///
/// Usage:
///     class MainModule extends di.Module {
///         MainModule() {
///             install(new ForecastModule());
///         }     
///     }
class ForecastModule  extends di.Module {
    ForecastModule() {
        // bind(DeviceProxy);
        
        // -- services
        // bind(SignalService, toImplementation: SignalServiceImpl);
    }
} 
*/

/// Controller-View for <forecast></forecast>
///
@MdlComponentModel
class ForecastComponent extends MdlTemplateComponent {
    final Logger _logger = new Logger('dart_sunshine.components.ForecastComponent');

    //static const _ForecastConstant _constant = const _ForecastConstant();
    static const _ForecastCssClasses _cssClasses = const _ForecastCssClasses();
    
    /// Change this to a more specific version
    final SunshineStore _store;

    /// Avoid UI-Update race-conditions
    bool _updating = false;

    final ObservableList<Forecast> forecasts = new ObservableList<Forecast>();

    ForecastComponent.fromElement(final dom.HtmlElement element,final di.Injector injector)
        : _store = injector.get(SunshineStore), super(element,injector) {
        
        _init();
    }
    
    static ForecastComponent widget(final dom.HtmlElement element) => mdlComponent(element,ForecastComponent) as ForecastComponent;

    // Central Element - by default this is where forecast can be found (element)
    // html.Element get hub => inputElement;
    
    
    // - EventHandler -----------------------------------------------------------------------------

    void handleButtonClick() {
        _logger.info("Event: handleButtonClick");
    }    
    
    //- private -----------------------------------------------------------------------------------

    void _init() {
        _logger.info("Forecast - init");
        
        // Recommended - add SELECTOR as class if this component is a TAG!
        element.classes.add(_ForecastConstant.WIDGET_SELECTOR);

        render().then((_) {

            _bindStoreActions();
            _bindViewActions();

            element.classes.add(_cssClasses.IS_UPGRADED);
        });
    }
    
    /// After the template is rendered we bind all the necessary Actions for this component
    void _bindStoreActions() {
        // only after creation...
        if(_store == null) { return;}

        _store.onChange.listen((final DataStoreChangedEvent event) {

            // Handle specific Update-Actions
            // if(event.data.actionname == UpdateTimeView.NAME) {
            //
            // }

            if(!_updating) {
                _updating = true;
                _updateView();
                _updating = false;
            }

        });
    }

    /// Attach Actions coming from our view (HTML-Template)
    void _bindViewActions() {
        
        // final MaterialFormComponent form = MaterialFormComponent.widget(query(".mdl-form"));
        //
        // eventStreams.add(
        //     form.onChange.listen((_) {
        //         // Create new Person - we don't want to edit the "Store person"!
        //         // final Person person = _store.byId(id);
        //
        //         // _store.fire(new PersonChangedAction(person));
        //     }));
    }
    
    /// Something has changed in the attached store - visualize it
    ///
    /// Usually this function is called if we get an onChange-event from our store
    void _updateView() {
        if(_store.forecasts.length == forecasts.length && _store.forecasts.isNotEmpty) {
            for(int index = 0;index < forecasts.length;index++) {
                if(_store.forecasts.length > index) {
                    //_logger.info("$index: ${_store.forecasts.runtimeType}");
                    forecasts[index] = _store.forecasts[index];
                }
            }
        } else {
            forecasts.clear();
            forecasts.addAll(_store.forecasts);
        }
    }

    //- Template -----------------------------------------------------------------------------------

    @override
    final String template = """
        <div mdl-repeat="forecast in forecasts">
            {{! ----- Turn off default mustache interpretation (sitegen) ---- }} {{= | | =}}
            <template>
                <div>
                    <div>{{forecast.date}}</div>
                    <div>{{forecast.shortDescription}}</div>
                    <div>{{forecast.conditionCode}}</div>
                    <div>{{forecast.minTemp}}</div>
                    <div>{{forecast.maxTemp}}</div>
                </div>
            </template>
            |= {{ }} =| {{! ----- Turn on mustache ---- }}
        </div>
    """.trim().replaceAll(new RegExp(r"\s+")," ");

}

/// Registers the Forecast-Component
///
///     main() {
///         registerForecast();
///         ...
///     }
///
void registerForecastComponent() {
    final MdlConfig config = new MdlWidgetConfig<ForecastComponent>(
        _ForecastConstant.WIDGET_SELECTOR,
            (final dom.HtmlElement element,final di.Injector injector) => new ForecastComponent.fromElement(element,injector)
    );
    
    // If you want <forecast></forecast> set selectorType to SelectorType.TAG.
    // If you want <div forecast></div> set selectorType to SelectorType.ATTRIBUTE.
    // By default it's used as a class name. (<div class="forecast"></div>)
    config.selectorType = SelectorType.TAG;
    
    componentHandler().register(config);
}

//- private Classes ----------------------------------------------------------------------------------------------------

/// Store strings for class names defined by this component that are used in
/// Dart. This allows us to simply change it in one place should we
/// decide to modify at a later date.
class _ForecastCssClasses {

    final String IS_UPGRADED = 'is-upgraded';
    
    const _ForecastCssClasses(); }
    
/// Store constants in one place so they can be updated easily.
class _ForecastConstant {

    static const String WIDGET_SELECTOR = "forecast";

    const _ForecastConstant();
}  