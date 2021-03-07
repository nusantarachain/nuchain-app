import 'dart:convert';

import 'package:polkawallet_sdk/service/index.dart';

class ServiceStaking {
  ServiceStaking(this.serviceRoot);

  final SubstrateService serviceRoot;

  Future<Map> queryElectedInfo() async {
    Map data = await serviceRoot.webView
        .evalJavascript('staking.querySortedTargets(api)', allowRepeat: false);
    return data;
  }

  Future<Map> queryNominations() async {
    Map data = await serviceRoot.webView
        .evalJavascript('staking.queryNominations(api)', allowRepeat: false);
    return data;
  }

  Future<List> queryBonded(List<String> pubKeys) async {
    List res = await serviceRoot.webView.evalJavascript(
        'account.queryAccountsBonded(api, ${jsonEncode(pubKeys)})');
    return res;
  }

  Future<Map> queryOwnStashInfo(String accountId) async {
    Map data = await serviceRoot.webView
        .evalJavascript('staking.getOwnStashInfo(api, "$accountId")');
    return data;
  }

  Future<Map> loadValidatorRewardsData(String validatorId) async {
    Map data = await serviceRoot.webView.evalJavascript(
        'staking.loadValidatorRewardsData(api, "$validatorId")');
    return data;
  }

  Future<List> getAccountRewardsEraOptions() async {
    final List res = await serviceRoot.webView
        .evalJavascript('staking.getAccountRewardsEraOptions(api)');
    return res;
  }

  // this query takes extremely long time
  Future<Map> fetchAccountRewards(String address, int eras) async {
    final Map res = await serviceRoot.webView.evalJavascript(
        'staking.loadAccountRewardsData(api, "$address", $eras)');
    return res;
  }

  Future<int> getSlashingSpans(String stashId) async {
    final int spans = await serviceRoot.webView
        .evalJavascript('staking.getSlashingSpans(api, "$stashId")');
    return spans;
  }
}
