library polkawallet_plugin_nuchain;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_storage/get_storage.dart';
import 'package:polkawallet_plugin_nuchain/common/constants.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/council/candidateDetailPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/council/candidateListPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/council/councilPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/council/councilVotePage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/council/motionDetailPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/democracy/democracyPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/democracy/proposalDetailPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/democracy/referendumVotePage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/treasury/spendProposalPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/treasury/submitProposalPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/treasury/submitTipPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/treasury/tipDetailPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/governance/treasury/treasuryPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/bondExtraPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/controllerSelectPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/payoutPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/rebondPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/redeemPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/rewardDetailPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/setControllerPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/setPayeePage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/stakePage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/stakingDetailPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/actions/unbondPage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/validators/nominatePage.dart';
import 'package:polkawallet_plugin_nuchain/pages/staking/validators/validatorDetailPage.dart';
import 'package:polkawallet_plugin_nuchain/service/index.dart';
import 'package:polkawallet_plugin_nuchain/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_nuchain/store/index.dart';
import 'package:polkawallet_plugin_nuchain/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/types/networkParams.dart';
import 'package:polkawallet_sdk/plugin/homeNavItem.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/pages/dAppWrapperPage.dart';
import 'package:polkawallet_ui/pages/txConfirmPage.dart';
import 'package:polkawallet_ui/pages/walletExtensionSignPage.dart';

class PluginNuchain extends PolkawalletPlugin {
  /// the nuchain plugin support two networks: nuchain & polkadot,
  /// so we need to identify the active network to connect & display UI.
  PluginNuchain({name = 'nuchain'})
      : basic = PluginBasicData(
          name: name,
          ss58: 42,
          primaryColor: Colors.green,
          icon: Image.asset(
              'packages/polkawallet_plugin_nuchain/assets/images/public/$name.png'),
          iconDisabled: Image.asset(
              'packages/polkawallet_plugin_nuchain/assets/images/public/${name}_gray.png'),
          jsCodeVersion: 11301,
          isTestNet: false,
        ),
        recoveryEnabled = name == network_name_nuchain,
        // _cache = name == network_name_nuchain
        //     ? StoreCacheNuchain()
        //     : StoreCachePolkadot();
        _cache = StoreCachePolkadot();

  @override
  final PluginBasicData basic;

  @override
  final bool recoveryEnabled;

  @override
  List<NetworkParams> get nodeList {
    if (basic.name == network_name_polkadot) {
      return _randomList(node_list_polkadot)
          .map((e) => NetworkParams.fromJson(e))
          .toList();
    }
    return _randomList(node_list_nuchain)
        .map((e) => NetworkParams.fromJson(e))
        .toList();
  }

  @override
  final Map<String, Widget> tokenIcons = {
    // 'KSM': Image.asset(
    //     'packages/polkawallet_plugin_nuchain/assets/images/tokens/KSM.png'),
    // 'DOT': Image.asset(
    //     'packages/polkawallet_plugin_nuchain/assets/images/tokens/DOT.png'),
    'ARA': Image.asset(
        'packages/polkawallet_plugin_nuchain/assets/images/tokens/ARA.png'),
    'NCO': Image.asset(
        'packages/polkawallet_plugin_nuchain/assets/images/tokens/NCO.png')
    // 'MBS': Image.asset(
    //     'packages/polkawallet_plugin_nuchain/assets/images/tokens/MBS.png'),
  };

  @override
  List<HomeNavItem> getNavItems(BuildContext context, Keyring keyring) {
    final color = basic.name == network_name_polkadot ? 'pink' : 'black';
    return home_nav_items.map((e) {
      final dic = I18n.of(context).getDic(i18n_full_dic_nuchain, 'common');
      return HomeNavItem(
        text: dic[e],
        icon: Image(
            image: AssetImage('assets/images/public/$e.png',
                package: 'polkawallet_plugin_nuchain')),
        iconActive: Image(
            image: AssetImage('assets/images/public/${e}_$color.png',
                package: 'polkawallet_plugin_nuchain')),
        content: e == 'staking' ? Staking(this, keyring) : Gov(this),
      );
    }).toList();
  }

  @override
  Map<String, WidgetBuilder> getRoutes(Keyring keyring) {
    return {
      TxConfirmPage.route: (_) =>
          TxConfirmPage(this, keyring, _service.getPassword),

      // staking pages
      StakePage.route: (_) => StakePage(this, keyring),
      BondExtraPage.route: (_) => BondExtraPage(this, keyring),
      ControllerSelectPage.route: (_) => ControllerSelectPage(this, keyring),
      SetControllerPage.route: (_) => SetControllerPage(this, keyring),
      UnBondPage.route: (_) => UnBondPage(this, keyring),
      RebondPage.route: (_) => RebondPage(this, keyring),
      SetPayeePage.route: (_) => SetPayeePage(this, keyring),
      RedeemPage.route: (_) => RedeemPage(this, keyring),
      PayoutPage.route: (_) => PayoutPage(this, keyring),
      NominatePage.route: (_) => NominatePage(this, keyring),
      StakingDetailPage.route: (_) => StakingDetailPage(this, keyring),
      RewardDetailPage.route: (_) => RewardDetailPage(this, keyring),
      ValidatorDetailPage.route: (_) => ValidatorDetailPage(this, keyring),

      // governance pages
      DemocracyPage.route: (_) => DemocracyPage(this, keyring),
      ReferendumVotePage.route: (_) => ReferendumVotePage(this, keyring),
      CouncilPage.route: (_) => CouncilPage(this, keyring),
      CouncilVotePage.route: (_) => CouncilVotePage(this),
      CandidateListPage.route: (_) => CandidateListPage(this, keyring),
      CandidateDetailPage.route: (_) => CandidateDetailPage(this, keyring),
      MotionDetailPage.route: (_) => MotionDetailPage(this, keyring),
      ProposalDetailPage.route: (_) => ProposalDetailPage(this, keyring),
      TreasuryPage.route: (_) => TreasuryPage(this, keyring),
      SpendProposalPage.route: (_) => SpendProposalPage(this, keyring),
      SubmitProposalPage.route: (_) => SubmitProposalPage(this, keyring),
      SubmitTipPage.route: (_) => SubmitTipPage(this, keyring),
      TipDetailPage.route: (_) => TipDetailPage(this, keyring),
      DAppWrapperPage.route: (_) => DAppWrapperPage(this, keyring),
      WalletExtensionSignPage.route: (_) =>
          WalletExtensionSignPage(this, keyring, _service.getPassword),
    };
  }

  @override
  Future<String> loadJSCode() => null;

  // @override
  // Future<String> loadJSCode(){
  //   rootBundle.loadString(
  //     'sdk/js_api/dist/main.js').then((d){
  //       print("js data");
  //       print(d);
  //     });
  //   return rootBundle.loadString(
  //     'sdk/js_api/dist/main.js');
  // }

  PluginStore _store;
  PluginApi _service;
  PluginStore get store => _store;
  PluginApi get service => _service;

  final StoreCache _cache;

  @override
  Future<void> onWillStart(Keyring keyring) async {
    await GetStorage.init(basic.name == network_name_polkadot
        ? plugin_polkadot_storage_key
        : plugin_nuchain_storage_key);

    _store = PluginStore(_cache);
    _store.staking.loadCache(keyring.current.pubKey);
    _store.gov.clearState();
    _store.gov.loadCache();

    _service = PluginApi(this, keyring);
  }

  // @override
  // Future<void> onStarted(Keyring keyring) async {
  //   _service.staking.queryElectedInfo();
  // }

  @override
  Future<void> onAccountChanged(KeyPairData acc) async {
    _store.staking.loadAccountCache(acc.pubKey);
  }

  List _randomList(List input) {
    final data = input.toList();
    final res = List();
    final _random = Random();
    for (var i = 0; i < input.length; i++) {
      final item = data[_random.nextInt(data.length)];
      res.add(item);
      data.remove(item);
    }
    return res;
  }
}
