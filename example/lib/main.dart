import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inline_webview_macos/flutter_inline_webview_macos.dart';
import 'package:flutter_inline_webview_macos/flutter_inline_webview_macos/flutter_inline_webview_macos_controller.dart';
import 'package:flutter_inline_webview_macos/flutter_inline_webview_macos/types.dart';
import 'package:path_provider/path_provider.dart';
import 'file.service.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterWebviewMacosPlugin = FlutterInlineWebviewMacos();
  bool _ready = true;
  String _event = "";
  MethodChannel platform = const MethodChannel('flutter_inline_webview_macos');

  InlineWebViewMacOsController? _controller;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    //loadFiles();
    platform.setMethodCallHandler((MethodCall call) async {
      log("init state setMethodCallHandler ${call.method}");
    });
  }

  Future<void> loadFiles() async {
    await FileService.loadFileToTemp(
        ['index.html', 'script.js', 'sample.jpeg']);
    setState(() {
      _ready = true;
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _flutterWebviewMacosPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: const Text('Plugin example app'),
    );

    void sendEvent(String eventName, {dynamic data}) {
      var script = "document.dispatchEvent(new CustomEvent('$eventName'))";
      _controller!.evaluateJavaScript(script);

      setState(() => _event = script);
    }

    return MaterialApp(
      home: Scaffold(
        appBar: appBar,
        body: Column(
          children: [
            if (_ready)
              Center(
                child: InlineWebViewMacOs(
                  key: widget.key,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height -
                      appBar.preferredSize.height -
                      200,
                  onWebViewCreated: (controller) async {
                    _controller = controller;
                    var url =
                        "/Users/udusharl/Project/angular-epub-reader/dist/angular-epub-reader";
                    url = "file://$url/index.html";
                    var uri = Uri.parse(url);
                    _controller!.loadUrl(
                      urlRequest: URLRequest(url: uri),
                      allowingReadAccessTo: Uri.parse("file://$url/index.html"),
                    );
                  },
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          alignment: Alignment.center,
          height: 75,
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          margin: const EdgeInsets.only(top: 0.1), // ***
          decoration: BoxDecoration(
            color: Theme.of(context).bottomAppBarColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 3,
                spreadRadius: 0.1,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.navigate_before),
                onPressed: () {
                  sendEvent('navigation.prev', data: 'prev');
                },
              ),
              IconButton(
                icon: const Icon(Icons.navigate_next),
                onPressed: () {
                  sendEvent('navigation.next', data: 'next');
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
