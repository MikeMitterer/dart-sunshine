library mini_webapp.main;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:console_log_handler/console_log_handler.dart';
import 'package:di/di.dart' as di;

import 'package:mdl/mdl.dart';

import 'package:service_worker/window.dart' as sw;

final Logger _logger = new Logger('mini_webapp.main');

@MdlComponentModel @di.Injectable()
class Application implements MaterialApplication {
    final Logger _logger = new Logger('main.Application');

    /// Added by the MDL/Dart-Framework (mdlapplication.dart)
    final ActionBus _actionbus;

    Application(this._actionbus) {
    }

    @override
    void run() {
        _bindSignals();
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

    final MaterialApplication application = await componentFactory().rootContext(Application)
        .addModule(new SampleModule())
        .run();

    application.run();
    
    querySelector('#output').text = "Your Dart app is running.";

    if (sw.isNotSupported) {
        _logger.warning('ServiceWorkers are not supported.');
        return;
    }

    await sw.register('sw.dart.js');
    _logger.info('registered');

    sw.ServiceWorkerRegistration registration = await sw.ready;
    _logger.info('ready');

    sw.onMessage.listen((MessageEvent event) {
        _logger.info('reply received: ${event.data}');
    });

    sw.ServiceWorker active = registration.active;
    active.postMessage('x');
    _logger.info('sent');

//    sw.PushSubscription subs = await registration.pushManager
//        .subscribe(new sw.PushSubscriptionOptions(userVisibleOnly: true));

//    _logger.fine('endpoint: ${subs.endpoint}');
}

/**
 * Application-Config via DI
 */
class SampleModule extends di.Module {
    SampleModule() {

    }
}
void configLogger() {
    hierarchicalLoggingEnabled = false; // set this to true - its part of Logging SDK

    // now control the logging.
    // Turn off all logging first
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(new LogConsoleHandler());
}