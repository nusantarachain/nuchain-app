import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:jaguar/jaguar.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/service/jaguar_flutter_asset.dart';
import 'package:polkawallet_sdk/service/keyring.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class WebViewRunner {
  FlutterWebviewPlugin _web;
  Function _onLaunched;

  Map<String, Function> _msgHandlers = {};
  Map<String, Completer> _msgCompleters = {};
  int _evalJavascriptUID = 0;

  StreamSubscription _subscription;

  Future<void> launch(
    ServiceKeyring keyring,
    Keyring keyringStorage,
    Function onLaunched, {
    String jsCode,
  }) async {
    /// reset state before webView launch or reload
    _msgHandlers = {};
    _msgCompleters = {};
    _evalJavascriptUID = 0;
    _onLaunched = onLaunched;

    final needLaunch = _web == null;

    _web = FlutterWebviewPlugin();

    /// cancel another plugin's listener before launch
    if (_subscription != null) {
      _subscription.cancel();
    }
    _subscription = _web.onStateChanged.listen((viewState) async {
      if (viewState.type == WebViewState.finishLoad) {
        print('webview loaded');
        final js = jsCode ??
            await rootBundle
                .loadString('packages/polkawallet_sdk/js_api/dist/main.js');

        print('js file loaded');
        await _startJSCode(js, keyring, keyringStorage);
      }
    });

    if (!needLaunch) {
      _web.reload();
      return;
    }

    await _startLocalServer();

    _web.launch(
      'https://localhost:8080/',
      clearCookies: true,
      clearCache: true,
      javascriptChannels: [
        JavascriptChannel(
            name: 'PolkaWallet',
            onMessageReceived: (JavascriptMessage message) {
              print('received msg: ${message.message}');
              compute(jsonDecode, message.message).then((msg) {
                final String path = msg['path'];
                // print('path: $path');
                // print('_msgCompleters[path]: ${_msgCompleters[path]}');
                if (_msgCompleters[path] != null) {
                  Completer handler = _msgCompleters[path];
                  handler.complete(msg['data']);
                  if (path.contains('uid=')) {
                    _msgCompleters.remove(path);
                  }
                }
                // print('_msgHandlers[path]: ${_msgHandlers[path]}');
                if (_msgHandlers[path] != null) {
                  Function handler = _msgHandlers[path];
                  handler(msg['data']);
                }
              });
            }),
      ].toSet(),
      ignoreSSLErrors: true,
      // withLocalUrl: true,
      hidden: true,
    );
  }

  Future<void> _startLocalServer() async {
    final cert = await rootBundle
        .load("packages/polkawallet_sdk/lib/ssl/certificate.pem");
    final keys =
        await rootBundle.load("packages/polkawallet_sdk/lib/ssl/keys.pem");
    final security = new SecurityContext()
      ..useCertificateChainBytes(cert.buffer.asInt8List())
      ..usePrivateKeyBytes(keys.buffer.asInt8List());
    // Serves the API at localhost:8080 by default
    final server = Jaguar(securityContext: security);
    server.addRoute(serveFlutterAssets());
    await server.serve(logRequests: false);
  }

  Future<void> _startJSCode(
    String js,
    ServiceKeyring keyring,
    Keyring keyringStorage,
  ) async {
    // inject js file to webView
    await _web.evalJavascript(js);

    _onLaunched();
  }

  int getEvalJavascriptUID() {
    return _evalJavascriptUID++;
  }

  Future<dynamic> evalJavascript(
    String code, {
    bool wrapPromise = true,
    bool allowRepeat = true,
  }) async {
    // check if there's a same request loading
    if (!allowRepeat) {
      for (String i in _msgCompleters.keys) {
        String call = code.split('(')[0];
        if (i.contains(call)) {
          print('request $call loading');
          return _msgCompleters[i].future;
        }
      }
    }

    if (!wrapPromise) {
      String res = await _web.evalJavascript(code);
      return res;
    }

    Completer c = new Completer();

    String method = 'uid=${getEvalJavascriptUID()};${code.split('(')[0]}';
    _msgCompleters[method] = c;

    String script = '$code.then(function(res) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "$method", data: res }));'
        '}).catch(function(err) {'
        '  PolkaWallet.postMessage(JSON.stringify({ path: "log", data: err.message }));'
        '})';
    _web.evalJavascript(script);

    return c.future;
  }

  Future<NetworkParams> connectNode(List<NetworkParams> nodes) async {
    final String res = await evalJavascript(
        'settings.connect(${jsonEncode(nodes.map((e) => e.endpoint).toList())})');
    if (res != null) {
      final node = nodes.firstWhere((e) => e.endpoint == res);
      return node;
    }
    return null;
  }

  Future<void> subscribeMessage(
    String code,
    String channel,
    Function callback,
  ) async {
    addMsgHandler(channel, callback);
    evalJavascript(code);
  }

  void unsubscribeMessage(String channel) {
    print('unsubscribe $channel');
    final unsubCall = 'unsub$channel';
    _web.evalJavascript('window["$unsubCall"] && window["$unsubCall"]()');
  }

  void addMsgHandler(String channel, Function onMessage) {
    _msgHandlers[channel] = onMessage;
  }

  void removeMsgHandler(String channel) {
    _msgHandlers.remove(channel);
  }
}
