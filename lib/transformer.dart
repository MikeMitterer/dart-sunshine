// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:barback/barback.dart';

import 'dart:async';

class TestTransformer extends AggregateTransformer {
    // A constructor named "asPlugin" is required. It can be empty, but
    // it must be present. It is how pub determines that you want this
    // class to be publicly available as a loadable transformer plugin.
    TestTransformer.asPlugin() {
        print("TestTransformer.asPlugin");
    }

    // Implement the classifyPrimary method to claim any assets that you want
    // to handle. Return a value for the assets you want to handle,
    // or null for those that you do not want to handle.
    classifyPrimary(final AssetId id) {
        print("[mini_web] ${id}");

        return ['.scss'].any((e) => e == id.extension) ? id.extension : null;
    }

    Future apply(final AggregateTransform transform) async {
        final List<Asset> assets = await transform.primaryInputs.toList();
        print("[mini_web (tf)]");

        return Future.wait(assets.map((final Asset asset) async {
            final AssetId id = asset.id;

            final String contents = await transform.readInputAsString(id);
            final String output = contents.replaceFirst("{blue}","#ff00ff");

            transform.addOutput(new Asset.fromString(id,output));
        }));
    }
}

class AddCSSTransformer extends Transformer {
    final String _style = '<link rel="stylesheet" href="packages/mini_webapp/assets/styles/mini.css">';
    final String _marker = '<!-- mdl-dart -->';

    /// {timerWatch} waits 500ms until all watched folders and files updated
    Timer timerWatch = null;

    // A constructor named "asPlugin" is required. It can be empty, but
    // it must be present. It is how pub determines that you want this
    // class to be publicly available as a loadable transformer plugin.
    AddCSSTransformer.asPlugin() {
        print("AddCSSTransformer.asPlugin");
        _watch(".sitegen");
    }

    // Any markdown file with one of the following extensions is
    // converted to HTML.
    //String get allowedExtensions => ".html";

    bool isPrimary(final AssetId id) => ['.html', '.htm'].contains(id.extension); // && !id.path.startsWith('lib');

    Future apply(final Transform transform) async {
        final Asset asset = transform.primaryInput;
        final AssetId id = asset.id;

        String content = await transform.primaryInput.readAsString();
        //final String output = content.replaceFirst(new RegExp(r".*</head>"),"\n$_style\n  </head>");

        if(content.contains(_marker)) {
            content = content.replaceFirst(_marker,_style);
        } else {
            content = content.replaceFirst(new RegExp(r"</title>"),"</title>\n    $_style\n");
        }

        print("[mini_web (csst)]");

        transform.addOutput(new Asset.fromString(id, content));
    }

    void _watch(final String folder) {

        final Directory srcDir = new Directory(folder);

        srcDir.watch(recursive: true).where((final file) => (!file.path.contains("packages"))).listen((final FileSystemEvent event) {
            print(event.toString());
            if(timerWatch != null) {
                timerWatch.cancel();
                timerWatch = null;
            }
            timerWatch = new Timer(new Duration(milliseconds: 1000), () {
                print("Generate");
                timerWatch = null;
            });

        });
    }
}