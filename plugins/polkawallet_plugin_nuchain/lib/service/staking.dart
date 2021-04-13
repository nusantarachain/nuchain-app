import 'package:polkawallet_plugin_nuchain/polkawallet_plugin_nuchain.dart';
import 'package:polkawallet_plugin_nuchain/store/index.dart';
import 'package:polkawallet_plugin_nuchain/utils/format.dart';
import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

class ApiStaking {
  ApiStaking(this.plugin, this.keyring)
      : api = plugin.sdk.api,
        store = plugin.store;

  final PluginNuchain plugin;
  final Keyring keyring;
  final PolkawalletApi api;
  final PluginStore store;

  Future<List> fetchAccountRewardsEraOptions() async {
    final List res = await api.staking.getAccountRewardsEraOptions();
    return res;
  }

  // this query takes extremely long time
  Future<Map> fetchAccountRewards(int eras) async {
    if (store.staking.ownStashInfo != null &&
        store.staking.ownStashInfo.stakingLedger != null) {
      int bonded = store.staking.ownStashInfo.stakingLedger['active'];
      List unlocking = store.staking.ownStashInfo.stakingLedger['unlocking'];
      if (bonded > 0 || unlocking.length > 0) {
        String address = store.staking.ownStashInfo.stashId;
        print('fetching staking rewards...');
        Map res = await api.staking.queryAccountRewards(address, eras);
        return res;
      }
    }
    return {};
  }

  Future<Map> updateStakingTxs(int skip) async {
    if (store.staking.ownStashInfo == null) {
      return null;
    }

    store.staking.setTxsLoading(true);

    Map res;
    try {
      res = await api.subScan.fetchAccountStakingTxsAsync(
        stashId: store.staking.ownStashInfo.stashId,
      );
    } catch (err) {
      print('fetchAccountStakingRewardsSlashesTxsAsync error $err');
    }

    if (res != null) {
      await store.staking.addTxs(
        res,
        keyring.current.pubKey,
        shouldCache: skip == 0,
        reset: skip == 0,
      );
    }

    store.staking.setTxsLoading(false);

    return res;
  }

  Future<Map> updateStakingRewards() async {
    if (store.staking.ownStashInfo?.stashId != null) {
      Map res;
      try {
        res = await api.subScan.fetchAccountStakingRewardsSlashesTxsAsync(
          stashId: store.staking.ownStashInfo.stashId,
        );
      } catch (err) {
        print('fetchAccountStakingRewardsSlashesTxsAsync error $err');
      }
      await store.staking
          .addTxsRewards(res, keyring.current.pubKey, shouldCache: true);
      return res;
    }
    return null;
  }

  // this query takes a long time
  Future<void> queryElectedInfo() async {
    // fetch all validators details
    final res = await api.staking.queryElectedInfo();
    store.staking.setValidatorsInfo(res);

    queryNominations();

    List validatorAddressList = res['validatorIds'];
    validatorAddressList.addAll(res['waitingIds']);
    plugin.service.gov.updateIconsAndIndices(validatorAddressList);
  }

  Future<void> queryNominations() async {
    // fetch nominators for all validators
    final res = await api.staking.queryNominations();
    store.staking.setNominations(res);
  }

  Future<Map> queryValidatorRewards(String accountId) async {
    int timestamp = DateTime.now().second;
    Map cached = store.staking.rewardsChartDataCache[accountId];
    if (cached != null && cached['timestamp'] > timestamp - 1800) {
      return cached;
    }
    print('fetching rewards chart data');
    Map data = await api.staking.loadValidatorRewardsData(accountId);
    if (data != null) {
      // format rewards data & set cache
      Map chartData = PluginFmt.formatRewardsChartData(data);
      chartData['timestamp'] = timestamp;
      store.staking.setRewardsChartData(accountId, chartData);
    }
    return data;
  }

  Future<Map> queryOwnStashInfo() async {
    final data =
        await api.service.staking.queryOwnStashInfo(keyring.current.address);
    store.staking.setOwnStashInfo(keyring.current.pubKey, data);

    final List<String> addressesNeedIcons =
        store.staking.ownStashInfo?.nominating != null
            ? store.staking.ownStashInfo.nominating.toList()
            : [];
    final List<String> addressesNeedDecode = [];
    if (store.staking.ownStashInfo?.stashId != null) {
      addressesNeedIcons.add(store.staking.ownStashInfo.stashId);
      addressesNeedDecode.add(store.staking.ownStashInfo.stashId);
    }
    if (store.staking.ownStashInfo?.controllerId != null) {
      addressesNeedIcons.add(store.staking.ownStashInfo.controllerId);
      addressesNeedDecode.add(store.staking.ownStashInfo.controllerId);
    }

    final icons = await api.account.getAddressIcons(addressesNeedIcons);
    store.accounts.setAddressIconsMap(icons);

    // get stash&controller's pubKey
    final pubKeys = await api.account.decodeAddress(addressesNeedDecode);
    store.accounts.setPubKeyAddressMap(
        Map<String, Map>.from({api.connectedNode.ss58.toString(): pubKeys}));

    return data;
  }

  Future<void> queryAccountBondedInfo() async {
    final data = await api.staking
        .queryBonded(keyring.allAccounts.map((e) => e.pubKey).toList());
    store.staking.setAccountBondedMap(data);
  }
}
