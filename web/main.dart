library mini_webapp.main;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:console_log_handler/console_log_handler.dart';

import 'package:service_worker/window.dart' as sw;

final Logger _logger = new Logger('mini_webapp.main');

Future main() async {
    configLogger();
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

void configLogger() {
    hierarchicalLoggingEnabled = false; // set this to true - its part of Logging SDK

    // now control the logging.
    // Turn off all logging first
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(new LogConsoleHandler());
}