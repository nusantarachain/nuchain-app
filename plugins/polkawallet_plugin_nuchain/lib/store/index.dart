import 'package:polkawallet_plugin_nuchain/store/accounts.dart';
import 'package:polkawallet_plugin_nuchain/store/cache/storeCache.dart';
import 'package:polkawallet_plugin_nuchain/store/gov/governance.dart';
import 'package:polkawallet_plugin_nuchain/store/staking/staking.dart';

class PluginStore {
  PluginStore(StoreCache cache)
      : staking = StakingStore(cache),
        gov = GovernanceStore(cache);
  final StakingStore staking;
  final GovernanceStore gov;
  final AccountsStore accounts = AccountsStore();
}
