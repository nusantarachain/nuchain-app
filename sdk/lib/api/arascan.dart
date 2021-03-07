import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

const int tx_list_skip_size = 10;

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

class AraScanRequestParams {
  AraScanRequestParams({
    this.sendPort,
    this.network,
    this.address,
    this.skip,
    this.limit,
    this.module,
    this.call,
  });

  /// exec in isolate with a message send port
  SendPort sendPort;

  String network;
  String address;
  int skip;
  int limit;
  String module;
  String call;
}

/// Querying txs from [scan.nuchain.network](https://scan.nuchain.network).
class AraScanApi {
  final String moduleBalances = 'Balances';
  final String moduleStaking = 'Staking';
  final String moduleDemocracy = 'Democracy';
  final String moduleRecovery = 'Recovery';

  static String getSnEndpoint(String network) {
    // if (network.contains('polkadot')) {
    //   network = 'polkadot';
    // }
    // if (network.contains('acala')) {
    //   network = 'acala-testnet';
    // }
    // // return 'https://$network.AraScan.io/api/scan';
    // return 'http://10.0.2.2:4399/api/scan';
    return 'https://scan.nuchain.network/api';
  }

  /// do the request in an isolate to avoid UI stall
  /// in IOS due to https issue: https://github.com/dart-lang/sdk/issues/41519
  Future<Map> fetchTransfersAsync(
    String address,
    int skip, {
    String network = 'nuchain',
  }) async {
    Completer completer = new Completer<Map>();

    ReceivePort receivePort = ReceivePort();
    Isolate isolateIns = await Isolate.spawn(
        AraScanApi.fetchTransfers,
        AraScanRequestParams(
          sendPort: receivePort.sendPort,
          network: network,
          address: address,
          skip: skip,
          limit: tx_list_skip_size,
        ));
    receivePort.listen((msg) {
      receivePort.close();
      isolateIns.kill(priority: Isolate.immediate);
      completer.complete(msg);
    });
    return completer.future;
  }

  Future<Map> fetchTxsAsync(
    String module, {
    String call,
    int skip = 0,
    int size = tx_list_skip_size,
    String sender,
    String network = 'nuchain',
  }) async {
    Completer completer = new Completer<Map>();

    ReceivePort receivePort = ReceivePort();
    Isolate isolateIns = await Isolate.spawn(
        AraScanApi.fetchTxs,
        AraScanRequestParams(
          sendPort: receivePort.sendPort,
          network: network,
          module: module,
          call: call,
          address: sender,
          skip: skip,
          limit: tx_list_skip_size,
        ));
    receivePort.listen((msg) {
      receivePort.close();
      isolateIns.kill(priority: Isolate.immediate);
      completer.complete(msg);
    });
    return completer.future;
  }

  Future<Map> fetchRewardTxsAsync({
    int skip = 0,
    int size = tx_list_skip_size,
    String sender,
    String network = 'nuchain',
  }) async {
    Completer completer = new Completer<Map>();

    ReceivePort receivePort = ReceivePort();
    Isolate isolateIns = await Isolate.spawn(
        AraScanApi.fetchRewardTxs,
        AraScanRequestParams(
          sendPort: receivePort.sendPort,
          network: network,
          address: sender,
          skip: skip,
          limit: tx_list_skip_size,
        ));
    receivePort.listen((msg) {
      receivePort.close();
      isolateIns.kill(priority: Isolate.immediate);
      completer.complete(msg);
    });
    return completer.future;
  }

  static Future<Map> fetchTransfers(AraScanRequestParams params) async {
    String url = '${getSnEndpoint(params.network)}/account/${params.address}/transfers?skip=${params.skip}&limit=${params.limit}';
    Map<String, String> headers = {
      "Content-type": "application/json",
      "Accept": "*/*"
    };
    print("fetching: $url");
    Response res = await get(url, headers: headers);
    if (res.body != null) {
      final obj = await compute(jsonDecode, res.body);
      if (params.sendPort != null) {
        params.sendPort.send(obj);
      }
      return obj;
    }
    if (params.sendPort != null) {
      params.sendPort.send({});
    }
    return {};
  }

  static Future<Map> fetchTxs(AraScanRequestParams para) async {
    String url = '${getSnEndpoint(para.network)}/extrinsics';
    Map<String, String> headers = {"Content-type": "application/json"};
    Map params = {
      "skip": para.skip,
      "limit": para.limit,
      "module": para.module,
    };
    if (para.address != null) {
      params['address'] = para.address;
    }
    if (para.call != null) {
      params['call'] = para.call;
    }
    String body = jsonEncode(params);
    Response res = await post(url, headers: headers, body: body);
    if (res.body != null) {
      final obj = await compute(jsonDecode, res.body);
      if (para.sendPort != null) {
        para.sendPort.send(obj['data']);
      }
      return obj['data'];
    }
    if (para.sendPort != null) {
      para.sendPort.send({});
    }
    return {};
  }

  static Future<Map> fetchRewardTxs(AraScanRequestParams para) async {
    String url = '${getSnEndpoint(para.network)}/account/reward_slash';
    Map<String, String> headers = {"Content-type": "application/json"};
    Map params = {
      "address": para.address,
      "skip": para.skip,
      "limit": para.limit,
    };
    String body = jsonEncode(params);
    Response res = await post(url, headers: headers, body: body);
    if (res.body != null) {
      final obj = await compute(jsonDecode, res.body);
      if (para.sendPort != null) {
        para.sendPort.send(obj['data']);
      }
      return obj['data'];
    }
    if (para.sendPort != null) {
      para.sendPort.send({});
    }
    return {};
  }

  Future<Map> fetchTokenPriceAsync(String network) async {
    Completer completer = new Completer<Map>();
    ReceivePort receivePort = ReceivePort();
    Isolate isolateIns = await Isolate.spawn(
        AraScanApi.fetchTokenPrice,
        AraScanRequestParams(
          sendPort: receivePort.sendPort,
          network: network,
        ));
    receivePort.listen((msg) {
      receivePort.close();
      isolateIns.kill(priority: Isolate.immediate);
      completer.complete(msg);
    });
    return completer.future;
  }

  static Future<Map> fetchTokenPrice(AraScanRequestParams para) async {
    String url = '${getSnEndpoint(para.network)}/token';
    Map<String, String> headers = {"Content-type": "application/json"};

    Response res = await get(url, headers: headers);
    if (res.body != null) {
      try {
        final obj = await compute(jsonDecode, res.body);
        if (para.sendPort != null) {
          para.sendPort.send(obj['data']);
        }
        return obj['data'];
      } catch (err) {
        // ignore error
      }
    }
    if (para.sendPort != null) {
      para.sendPort.send({});
    }
    return {};
  }
}
