import 'dart:convert';

import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/api/types/tokenMetadata.dart';
import 'package:polkawallet_sdk/plugin/store/tokenData.dart';
import 'package:polkawallet_sdk/service/account.dart';

class ApiAccount {
  ApiAccount(this.apiRoot, this.service);

  final PolkawalletApi apiRoot;
  final ServiceAccount service;

  /// encode addresses to publicKeys
  Future<Map> encodeAddress(List<String> pubKeys) async {
    final int ss58 = apiRoot.connectedNode.ss58;
    final Map res = await service.encodeAddress(pubKeys, [ss58]);
    if (res != null) {
      return res[ss58.toString()];
    }
    return null;
  }

  /// decode addresses to publicKeys
  Future<Map> decodeAddress(List<String> addresses) async {
    final Map res = await service.decodeAddress(addresses);
    return res;
  }

  /// query balance
  Future<BalanceData> queryBalance(String address) async {
    final res = await service.queryBalance(address);
    return res != null ? BalanceData.fromJson(res) : null;
  }

  /// get token metadata information.
  Future<List<TokenMetadata>> getTokenMetadata(List<int> tokenIds) async {
    final res = await service.getTokenMetadata(tokenIds);
    return res != null
        ? res.map((a) => TokenMetadata.fromJson(a)).toList()
        : null;
  }

  // /// query balance
  // Future<BalanceData> queryTokenBalance(String address, List<int> tokens) async {
  //   final res = await service.queryTokenBalance(address, tokens);
  //   return res != null ? BalanceData.fromJson(res) : null;
  // }

  /// subscribe balance
  /// @return [String] msgChannel, call unsubscribeMessage(msgChannel) to unsub.
  Future<String> subscribeBalance(
    String address,
    Function(BalanceData) onUpdate,
  ) async {
    final msgChannel = 'Balance';
    final code = 'account.getBalance(api, "$address", "$msgChannel")';
    await apiRoot.service.webView.subscribeMessage(
        code, msgChannel, (data) => onUpdate(BalanceData.fromJson(data)));
    return msgChannel;
  }

  /// unsubscribe balance
  void unsubscribeBalance() {
    final msgChannel = 'Balance';
    apiRoot.unsubscribeMessage(msgChannel);
  }

  /// subscribe token balance
  /// @return [String] msgChannel, call unsubscribeMessage(msgChannel) to unsub.
  Future<String> subscribeTokensBalance(
    String address,
    List<int> tokenIds,
    List<String> tokenNames,
    Function(List<TokenBalanceData>) onUpdate,
  ) async {
    final msgChannel = 'TokensBalance';
    final code =
        'account.getTokensBalance(api, "$address", ${jsonEncode(tokenIds)}, "$msgChannel")';
    print("getting token balance");
    // print(code);
    await apiRoot.service.webView.subscribeMessage(code, msgChannel, (data) {
      print("RESULT:");
      print(data);
      final List<TokenBalanceData> mappedData = data.map((d){
        Map<String, dynamic> md = {};
        md["name"] = tokenNames[d["tokenId"] - 1];
        md["symbol"] = tokenNames[d["tokenId"] - 1];
        md["amount"] = d["balance"];
        return TokenBalanceData.fromJson(md);
      }).where((d) => d.amount != "0").toList().cast<TokenBalanceData>();
      onUpdate(mappedData);
    });
    return msgChannel;
  }

  /// unsubscribe token balance
  void unsubscribeTokensBalance() {
    final msgChannel = 'TokensBalance';
    apiRoot.unsubscribeMessage(msgChannel);
  }

  /// Get on-chain account info of addresses
  Future<List> queryIndexInfo(List addresses) async {
    if (addresses == null || addresses.length == 0) {
      return [];
    }

    var res = await service.queryIndexInfo(addresses);
    return res;
  }

  /// query address with account index
  Future<String> queryAddressWithAccountIndex(String index) async {
    final res = await service.queryAddressWithAccountIndex(
        index, apiRoot.connectedNode.ss58);
    if (res != null) {
      return res[0];
    }
    return null;
  }

  /// Get icons of pubKeys
  /// return svg strings
  Future<List> getPubKeyIcons(List<String> keys) async {
    if (keys == null || keys.length == 0) {
      return [];
    }
    List res = await service.getPubKeyIcons(keys);
    return res;
  }

  /// Get icons of addresses
  /// return svg strings
  Future<List> getAddressIcons(List addresses) async {
    if (addresses == null || addresses.length == 0) {
      return [];
    }
    List res = await service.getAddressIcons(addresses);
    return res;
  }
}
