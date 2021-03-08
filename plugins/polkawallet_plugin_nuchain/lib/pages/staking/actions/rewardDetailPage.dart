import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_nuchain/polkawallet_plugin_nuchain.dart';
import 'package:polkawallet_plugin_nuchain/store/staking/types/txData.dart';
import 'package:polkawallet_plugin_nuchain/utils/i18n/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/txDetail.dart';
import 'package:polkawallet_ui/utils/format.dart';

class RewardDetailPage extends StatelessWidget {
  RewardDetailPage(this.plugin, this.keyring);

  static final String route = '/staking/rewards';
  final PluginNuchain plugin;
  final Keyring keyring;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_nuchain, 'common');
    final dicStaking = I18n.of(context).getDic(i18n_full_dic_nuchain, 'staking');
    final decimals = plugin.networkState.tokenDecimals[0];
    final symbol = plugin.networkState.tokenSymbol[0];
    final TxRewardData detail = ModalRoute.of(context).settings.arguments;

    return TxDetail(
      networkName: plugin.basic.name,
      success: true,
      action: detail.eventId,
      hash: detail.extrinsicHash,
      eventId: detail.eventIndex,
      infoItems: <TxDetailInfoItem>[
        TxDetailInfoItem(label: dicStaking['txs.event'], title: detail.eventId),
        TxDetailInfoItem(
          label: dic['amount'],
          title: '${Fmt.balance(detail.amount, decimals)} $symbol',
        ),
      ],
      blockTime: Fmt.dateTime(
          DateTime.fromMillisecondsSinceEpoch(detail.blockTimestamp)),
      blockNum: detail.blockNum,
    );
  }
}
