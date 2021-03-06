library dart_sunshine.main;

import 'dart:async';
import 'dart:convert';
import 'dart:html' as dom;

import 'dart:html';
import 'package:dart_sunshine/components/interfaces/actions.dart';
import 'package:dart_sunshine/model.dart';
import 'package:dart_sunshine/persistence.dart';
import 'package:http_utils/http_utils.dart';
import 'package:logging/logging.dart';
import 'package:console_log_handler/console_log_handler.dart';
import 'package:di/di.dart' as di;
import 'package:route_hierarchical/client.dart';
import 'package:validate/validate.dart';

import 'package:mdl/mdl.dart' deferred as mdl;
import 'package:mdl/mdlcore.dart';
import 'package:mdl/mdlflux.dart';
import 'package:mdl/mdlapplication.dart';

//import 'package:service_worker/window.dart' as sw;

import 'package:dart_sunshine/stores.dart';
import 'package:dart_sunshine/components.dart';

final Logger _logger = new Logger('mini_webapp.main');

@MdlComponentModel @di.Injectable()
class Application implements MaterialApplication {
    /// Here is the API-Key for OpenWeatherMap
    static const _SERVICE_CONFIG = "config/service-config.json";

    final Logger _logger = new Logger('main.Application');
    final Router _router = new Router(useFragment: true);

    /// Added by the MDL/Dart-Framework (mdlapplication.dart)
    final ActionBus _actionbus;

    Application(this._actionbus) {
    }

    @override
    void run() {
        _readConfig().then((_) {
            _bindSignals();

            // Fire initial event to Update the Forecast-List
            _actionbus.fire(new NetworkStateChanged(
                dom.window.navigator.onLine ? NetworkState.ONLINE : NetworkState.OFFLINE));
        });
    }

    void go(final String routePath, final Map params) {
        _router.go(routePath,params);
    }

    void fire(final Action action) => _actionbus.fire(action);

    //- private -----------------------------------------------------------------------------------

    void _bindSignals() {
        // Not necessary - just a demonstration how to listen to the "global" ActionBus
        // _actionbus.on(AddItemAction.NAME).listen((_) {
        //    _logger.info("User clicked on 'Add'!");
        //});

        dom.window.onOnline.listen((_) => _actionbus.fire(new NetworkStateChanged(NetworkState.ONLINE)));
        dom.window.onOffline.listen((_) => _actionbus.fire(new NetworkStateChanged(NetworkState.OFFLINE)));
    }

    /// Application-Config (API-Key, default-Location...)
    Future _readConfig() async {
        final Uri uriConfig = new URIBuilder.forFile(_SERVICE_CONFIG).build();
        final String jsonString = await HttpRequest.getString(uriConfig.toString());
        final Map<String,dynamic> json = JSON.decode(jsonString);

        Validate.isTrue(json.containsKey("apikey"),"Invalid config-file! Could not find 'apikey'.");

        final SettingsDAO dao = new SettingsDAO();
        final String apikey = json["apikey"];

        try {
            final Settings prevSettings = await dao.settings;

            /// Update API-Key
            return dao.save(new Settings(prevSettings.location, prevSettings.units, apikey));

        } on DBException {

            final String defaultLocation = json.containsKey("default_location")
                ? json["default_location"]
                : "London";

            final String defaultUnits = json.containsKey("default_units")
                ? json["default_units"]
                : Units.METRIC.toString();

            return dao.save(new Settings(
                defaultLocation,
                defaultUnits == Units.METRIC.toString() ? Units.METRIC : Units.IMPERIAL,
                apikey));
        }
    }

}

Future main() async {
    configLogger();

    await mdl.loadLibrary();
    mdl.registerMdl();

    registerSunshineComponents();
    
    final Application application = await mdl.componentFactory().rootContext(Application)
        .addModule(new SampleModule())
        .run();

    configRouter(application._router,(final RoutePreEnterEvent event) {
        // new Future<bool>(() => application.isUserLoggedIn)
        event.allowEnter(new Future(() => true));
    });

    application.run();
    
//    if (sw.isSupported && false) {
//        await sw.register('sw.dart.js');
//        _logger.info('ServiceWorker - registered...');
//
//        sw.ServiceWorkerRegistration registration = await sw.ready;
//        _logger.info('ServiceWorker - ready!');
//
//        sw.onMessage.listen((dom.MessageEvent event) {
//            _logger.info('reply received: ${event.data}');
//        });
//
//        sw.ServiceWorker active = registration.active;
//        active.postMessage('x');
//        _logger.info('sent');
//
//        //    sw.PushSubscription subs = await registration.pushManager
//        //        .subscribe(new sw.PushSubscriptionOptions(userVisibleOnly: true));
//
//        //    _logger.fine('endpoint: ${subs.endpoint}');
//    }
}

/**
 * Application-Config via DI
 */
class SampleModule extends di.Module {
    SampleModule() {
        install(new StoreModule());
    }
}

/// Default Controller!!!
class DefaultController extends MaterialController {
    static final Logger _logger = new Logger('dart_sunshine.main.DefaultController');

    /// Prefix for [bodyMarker]
    static const String _VIEW_PREFIX = "view-";

    @override
    void loaded(final Route route) {

        final Application app = mdl.componentFactory().application;

        _logger.fine("DefaultController loaded!");
    }
    // - private -------------------------------------------------------------------------------------------------------

    void set bodyMarker(final String marker) {
        Validate.notBlank(marker);

        final dom.HtmlElement body = dom.querySelector("body");
        body.classes.removeWhere((final String name) => name.startsWith(_VIEW_PREFIX));
        body.classes.add("${_VIEW_PREFIX}${marker}");
    }
}

class ControllerHome extends DefaultController {
    static final Logger _logger = new Logger('dart_sunshine.main.ControllerHome');

    @override
    void loaded(final Route route) {
        super.loaded(route);
        _logger.fine("ControllerHome loaded!");

        bodyMarker = "home";

    }

    @override
    void unload() {
        _logger.fine("ControllerHome unloaded!");

    }
    // - private ------------------------------------------------------------------------------------------------------
}

class ControllerSettings extends DefaultController {
    static final Logger _logger = new Logger('dart_sunshine.main.ControllerSettings');

    @override
    void loaded(final Route route) {
        super.loaded(route);
        _logger.fine("ControllerSettings loaded!");

        bodyMarker = "settings";
    }

    @override
    void unload() {
        (mdl.componentFactory().application as Application).fire(new SettingsChanged());
        _logger.fine("ControllerSettings unloaded!");

    }
    // - private ------------------------------------------------------------------------------------------------------
}

class ControllerMap extends DefaultController {
    static final Logger _logger = new Logger('dart_sunshine.main.ControllerMap');

    @override
    void loaded(final Route route) {
        super.loaded(route);
        _logger.fine("ControllerMap loaded!");

        bodyMarker = "map";
    }

    @override
    void unload() {
        _logger.fine("ControllerMap unloaded!");

    }
    // - private ------------------------------------------------------------------------------------------------------
}

void configRouter(final Router router,final RoutePreEnterEventHandler routeChecker) {
    final ViewFactory view = new ViewFactory();

    router.root

        ..addRoute(name: 'settings', path: '/settings',
            enter: view("views/settings.html", new ControllerSettings()),
            preEnter: routeChecker)

        ..addRoute(name: 'map', path: '/map',
            enter: view("views/map.html", new ControllerMap()),
            preEnter: routeChecker)

        /// Leave default-route as the last one
        ..addRoute(name: 'home', defaultRoute: true, path: '/',
            enter: view("views/home.html", new ControllerHome()))

    ;

    router.listen();
}

void configLogger() {
    hierarchicalLoggingEnabled = false; // set this to true - its part of Logging SDK

    // now control the logging.
    // Turn off all logging first
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(new LogConsoleHandler());
}