library dart_sunshine.main;

import 'dart:async';
import 'dart:html' as dom;

import 'package:logging/logging.dart';
import 'package:console_log_handler/console_log_handler.dart';
import 'package:di/di.dart' as di;
import 'package:route_hierarchical/client.dart';
import 'package:validate/validate.dart';

import 'package:mdl/mdl.dart';

import 'package:service_worker/window.dart' as sw;

final Logger _logger = new Logger('mini_webapp.main');

@MdlComponentModel @di.Injectable()
class Application implements MaterialApplication {
    final Logger _logger = new Logger('main.Application');
    final Router _router = new Router(useFragment: true);

    /// Added by the MDL/Dart-Framework (mdlapplication.dart)
    final ActionBus _actionbus;

    Application(this._actionbus) {
    }

    @override
    void run() {
        _bindSignals();
    }

    void go(final String routePath, final Map params) {
        _router.go(routePath,params);
    }

    //- private -----------------------------------------------------------------------------------

    void _bindSignals() {
        // Not necessary - just a demonstration how to listen to the "global" ActionBus
        // _actionbus.on(AddItemAction.NAME).listen((_) {
        //    _logger.info("User clicked on 'Add'!");
        //});
    }
}

Future main() async {
    configLogger();

    registerMdl();

    final Application application = await componentFactory().rootContext(Application)
        .addModule(new SampleModule())
        .run();

    configRouter(application._router,(final RoutePreEnterEvent event) {
        // new Future<bool>(() => application.isUserLoggedIn)
        event.allowEnter(new Future(() => true));
    });

    application.run();
    
    if (sw.isSupported) {
        await sw.register('sw.dart.js');
        _logger.info('ServiceWorker - registered...');

        sw.ServiceWorkerRegistration registration = await sw.ready;
        _logger.info('ServiceWorker - ready!');

        sw.onMessage.listen((dom.MessageEvent event) {
            _logger.info('reply received: ${event.data}');
        });

        sw.ServiceWorker active = registration.active;
        active.postMessage('x');
        _logger.info('sent');

        //    sw.PushSubscription subs = await registration.pushManager
        //        .subscribe(new sw.PushSubscriptionOptions(userVisibleOnly: true));

        //    _logger.fine('endpoint: ${subs.endpoint}');
    }
}

/**
 * Application-Config via DI
 */
class SampleModule extends di.Module {
    SampleModule() {

    }
}

/// Default Controller!!!
class DefaultController extends MaterialController {
    static final Logger _logger = new Logger('dart_sunshine.main.DefaultController');

    /// Prefix for [bodyMarker]
    static const String _VIEW_PREFIX = "view-";

    @override
    void loaded(final Route route) {

        final Application app = componentFactory().application;

        _logger.info("DefaultController loaded!");
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
        _logger.info("ControllerHome loaded!");

        bodyMarker = "home";

    }

    @override
    void unload() {
        _logger.info("ControllerHome unloaded!");

    }
    // - private ------------------------------------------------------------------------------------------------------
}

class ControllerSettings extends DefaultController {
    static final Logger _logger = new Logger('dart_sunshine.main.ControllerSettings');

    @override
    void loaded(final Route route) {
        super.loaded(route);
        _logger.info("ControllerSettings loaded!");

        bodyMarker = "settings";
    }

    @override
    void unload() {
        _logger.info("ControllerSettings unloaded!");

    }
    // - private ------------------------------------------------------------------------------------------------------
}

class ControllerMap extends DefaultController {
    static final Logger _logger = new Logger('dart_sunshine.main.ControllerMap');

    @override
    void loaded(final Route route) {
        super.loaded(route);
        _logger.info("ControllerMap loaded!");

        bodyMarker = "map";
    }

    @override
    void unload() {
        _logger.info("ControllerMap unloaded!");

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