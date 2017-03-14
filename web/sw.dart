library miniwebapp.serviceworker;

import 'dart:async';
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

import 'package:service_worker/worker.dart';

const String _cacheName = "offline-v1";

void main(List<String> args) {
    final Logger _logger = new Logger('miniwebapp.serviceworker.main');

    configLogging();
    onInstall.listen((final InstallEvent event) {
        _logger.info('Installing.');
        event.waitUntil(_initCache());
    });

    onActivate.listen((final ExtendableEvent event) {
        _logger.info('Activating.');
    });

    onFetch.listen((final FetchEvent event) {
        _logger.info('fetch request: ${event.request.url}');
        event.respondWith(_getCachedOrFetch(event.request));
    });

    onMessage.listen((final ExtendableMessageEvent event) {
        _logger.info('onMessage received ${event.data}');
        event.source.postMessage('reply from SW');
        _logger.info('replied');
    });

    onPush.listen((final PushEvent event) {
        _logger.info('onPush received: ${event.data}');
        registration.showNotification('Notification: ${event.data}');
    });
}

Future<Response> _getCachedOrFetch(final Request request) async {
    final Logger _logger = new Logger('miniwebapp.serviceworker._getCachedOrFetch');

    final Response cachedResponse = await caches.match(request);
    if (cachedResponse != null) {
        _logger.info('Found in cache: ${request.url}!');
        return cachedResponse;
    }

    _logger.info('No cached version. Fetching: ${request.url}');

    // IMPORTANT: Clone the request. A request is a stream and
    // can only be consumed once. Since we are consuming this
    // once by cache and once by the browser for fetch, we need
    // to clone the response.
    final Request fetchRequest = request.clone();

    final Response response = await fetch(fetchRequest);
    _logger.info('${request.url} returned Status: ${response.status}, Type: ${response.type}');

    // Check if we received a valid response
    // if(response == null || response.status != 200 || response.type != 'basic') {
    //    return response;
    // }

    // IMPORTANT: Clone the response. A response is a stream
    // and because we want the browser to consume the response
    // as well as the cache consuming the response, we need
    // to clone it so we have two streams.
    final Response responseToCache = response.clone();

    final Cache cache = await caches.open(_cacheName);
    await cache.put(request,responseToCache);
    _logger.info("Cached ${request.url} for next request!");

    return response;
}

Future _initCache() async {
    final Logger _logger = new Logger('miniwebapp.serviceworker._initCache');

    _logger.info('Init cache...');
    Cache cache = await caches.open(_cacheName);
    await cache.addAll([
        '/',
        '/main.dart',
        '/main.dart.js',
        '/styles.css',
        '/packages/browser/dart.js',
    ]);
    _logger.info('Cache ${_cacheName} initialized.');
}

void configLogging() {
    hierarchicalLoggingEnabled = false; // set this to true - its part of Logging SDK

    // now control the logging.
    // Turn off all logging first
    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen(new LogPrintHandler(
        messageFormat: "%n (%t) %m",
        timestampFormat: "HH:mm:ss.SSS"
    ));
}
