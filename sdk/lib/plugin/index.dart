import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/api/types/networkStateData.dart';
import 'package:polkawallet_sdk/plugin/store/balances.dart';
import 'package:polkawallet_sdk/plugin/store/tokenData.dart';
import 'package:polkawallet_sdk/polkawallet_sdk.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/service/webViewRunner.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';

const String sdk_cache_key = 'polka_wallet_sdk_cache';
const String net_state_cache_key = 'network_state';
const String net_const_cache_key = 'network_const';
const String balance_cache_key = 'balances';
const String token_cache_key = 'tokens';

abstract class PolkawalletPlugin implements PolkawalletPluginBase {
  /// A plugin has a [WalletSDK] instance for connecting to it's node.
  final WalletSDK sdk = WalletSDK();

  /// Plugin should retrieve [balances] from sdk
  /// for display in Assets page of Polkawallet App.
  final balances = BalancesStore();

  final recoveryEnabled = false;

  List<int> extraTokenIds;

  /// Plugin should retrieve [networkState] & [networkConst] while start
  NetworkStateData get networkState {
    try {
      return NetworkStateData.fromJson(Map<String, dynamic>.from(
          _cache.read(_getNetworkCacheKey(net_state_cache_key)) ?? {}));
    } catch (err) {
      print(err);
    }
    return NetworkStateData();
  }

  Map get networkConst =>
      _cache.read(_getNetworkCacheKey(net_const_cache_key)) ?? {};

  GetStorage get _cache => GetStorage(sdk_cache_key);
  String _getNetworkCacheKey(String key) => '${key}_${basic.name}';
  String _getBalanceCacheKey(String pubKey) =>
      '${balance_cache_key}_${basic.name}_$pubKey';
  String _getTokensCacheKey(String pubKey) =>
      '${token_cache_key}_${basic.name}_$pubKey';

  Future<void> updateNetworkState() async {
    final state = await Future.wait([
      sdk.api.service.setting.queryNetworkConst(),
      sdk.api.service.setting.queryNetworkProps(),
    ]);
    _cache.write(_getNetworkCacheKey(net_const_cache_key), state[0]);
    _cache.write(_getNetworkCacheKey(net_state_cache_key), state[1]);
  }

  void updateBalances(KeyPairData acc, BalanceData data) {
    balances.setBalance(data);

    _cache.write(_getBalanceCacheKey(acc.pubKey), data.toJson());
  }

  void loadBalances(KeyPairData acc) {
    updateBalances(
      acc,
      BalanceData.fromJson(Map<String, dynamic>.from(
          _cache.read(_getBalanceCacheKey(acc.pubKey)) ?? {})),
    );
  }

  void updateExtraTokens(KeyPairData acc, List<TokenBalanceData> data) {
    balances.setTokens(data);
    _cache.write(
        _getTokensCacheKey(acc.pubKey), data.map((a) => a.toJson()).toList());
  }

  void loadExtraTokens(KeyPairData acc) {
    List<dynamic> data = _cache.read(_getTokensCacheKey(acc.pubKey)) ?? [];
    updateExtraTokens(
      acc,
      data
          .map((d) => TokenBalanceData.fromJson(Map<String, dynamic>.from(d)))
          .toList(),
    );
  }

  /// This method will be called while App switched to a plugin.
  /// In this method, the plugin will init [WalletSDK] and start
  /// a webView for running `polkadot-js/api`.
  Future<void> beforeStart(Keyring keyring,
      {WebViewRunner webView, String jsCode, List<int> extraTokenIds}) async {
    await sdk.init(
      keyring,
      webView: webView,
      jsCode: jsCode ?? (await loadJSCode()),
    );
    this.extraTokenIds = extraTokenIds;
    await onWillStart(keyring);
  }

  /// This method will be called while App switched to a plugin.
  /// In this method, the plugin will:
  /// 1. connect to nodes.
  /// 2. retrieve network const & state.
  /// 3. subscribe balances & set balancesStore.
  Future<NetworkParams> start(Keyring keyring,
      {List<NetworkParams> nodes}) async {
    final res = await sdk.api.connectNode(keyring, nodes ?? nodeList);
    if (res == null) return null;

    keyring.setSS58(res.ss58);
    await updateNetworkState();

    if (keyring.current.address != null) {
      loadBalances(keyring.current);
      sdk.api.account.subscribeBalance(keyring.current.address,
          (BalanceData data) {
        updateBalances(keyring.current, data);
      });

      subscribeTokenBalances(keyring.current);
    }

    onStarted(keyring);

    return res;
  }

  void subscribeTokenBalances(KeyPairData account) async {
    loadExtraTokens(account);
    final resp = await sdk.api.subScan.fetchExtraTokensAsync(this.basic.name);
    if (resp["token"] == null){
      return;
    }
    List<String> tokenNames = resp["token"].sublist(1).cast<String>();
    List<int> tokenIds = tokenNames
        .map((tokenName) => resp["detail"][tokenName]['asset_id'])
        .toList()
        .cast<int>();
    tokenIds.removeWhere((id) => id == 0);
    print("tokenNames: $tokenNames");
    print("tokenIds:");
    print(tokenIds);
    sdk.api.account
        .subscribeTokensBalance(account.address, tokenIds, tokenNames,
            (List<TokenBalanceData> data) {
      updateExtraTokens(account, data);
    });
  }

  /// This method will be called while App user changes account.
  void changeAccount(KeyPairData account) {
    sdk.api.account.unsubscribeBalance();
    sdk.api.account.unsubscribeTokensBalance();

    loadBalances(account);
    sdk.api.account.subscribeBalance(account.address, (BalanceData data) {
      updateBalances(account, data);
    });

    subscribeTokenBalances(account);

    onAccountChanged(account);
  }

  /// This method will be called before plugin start
  Future<void> onWillStart(Keyring keyring) async => null;

  /// This method will be called after plugin started
  Future<void> onStarted(Keyring keyring) async => null;

  /// This method will be called while App user changes account.
  /// In this method, the plugin should do:
  /// 1. update balance subscription to update balancesStore.
  /// 2. update other user state of plugin if needed.
  Future<void> onAccountChanged(KeyPairData account) async => null;

  /// we don't really need this method, calling webView.launch
  /// more than once will cause some exception.
  /// We just pass a [webViewParam] instance to the sdk.init function,
  /// so the sdk knows how to deal with the webView.
  Future<void> dispose() async {
    // do nothing
  }
}

abstract class PolkawalletPluginBase {
  /// A plugin's basic info, including: name, primaryColor and icons.
  final basic = PluginBasicData(name: 'kusama', primaryColor: Colors.black);

  /// Plugin should define a list of node to connect
  /// for users of Polkawallet App.
  List<NetworkParams> get nodeList => List.empty();

  /// Plugin should provide [tokenIcons]
  /// for display in Assets page of Polkawallet App.
  final Map<String, Widget> tokenIcons = {};

  /// The [getNavItems] method returns a list of [HomeNavItem] which defines
  /// the [Widget] to be used in home page of polkawallet App.
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) =>
      List.empty();

  /// App will add plugin's pages with custom [routes].
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) =>
      Map<String, WidgetBuilder>();

  /// App will inject plugin's [jsCode] into webview to connect.
  Future<String> loadJSCode() => null;
}

class PluginBasicData {
  PluginBasicData({
    this.name,
    this.ss58,
    this.primaryColor,
    this.icon,
    this.iconDisabled,
    this.jsCodeVersion,
    this.isTestNet = true,
  });
  final String name;
  final int ss58;
  final MaterialColor primaryColor;

  /// The icons will be displayed in network-select page
  /// in Polkawallet App.
  final Widget icon;
  final Widget iconDisabled;

  /// JavaScript code version of your plugin.
  ///
  /// Polkawallet App will perform hot-update for the js code
  /// of your plugin with it.
  final int jsCodeVersion;

  /// Your plugin is connected to a para-chain testNet by default.
  final bool isTestNet;
}
