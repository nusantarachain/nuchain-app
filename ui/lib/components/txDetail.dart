import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/jumpToBrowserLink.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';

class TxDetail extends StatelessWidget {
  TxDetail({
    this.success,
    this.networkName,
    this.action,
    @required this.eventId,
    this.hash,
    this.blockTime,
    this.blockNum,
    this.infoItems,
  });

  final bool success;
  final String networkName;
  final String action;
  final String eventId;
  final String hash;
  final String blockTime;
  final int blockNum;
  final List<TxDetailInfoItem> infoItems;

  List<Widget> _buildListView(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    Widget buildLabel(String name) {
      return Container(
        padding: EdgeInsets.only(left: 8),
        width: 80,
        child: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).unselectedWidgetColor,
          ),
        ),
      );
    }

    var list = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 88,
            padding: EdgeInsets.all(24),
            child: success
                ? Image.asset(
                    'packages/polkawallet_ui/assets/images/success.png')
                : Image.asset(
                    'packages/polkawallet_ui/assets/images/error.png'),
          ),
          Text(
            '$action ${success ? dic['success'] : dic['fail']}',
            style: Theme.of(context).textTheme.headline4,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8, bottom: 32),
            child: Text(blockTime),
          ),
        ],
      ),
      Divider(),
    ];
    list.addAll(infoItems.map((i) {
      return ListTile(
        leading: buildLabel(i.label),
        title: Text(i.title),
        subtitle: i.subtitle != null ? Text(i.subtitle) : null,
        trailing: i.copyText != null
            ? IconButton(
                icon: Image.asset(
                    'packages/polkawallet_ui/assets/images/copy.png',
                    width: 16),
                onPressed: () => UI.copyAndNotify(context, i.copyText),
              )
            : null,
      );
    }));

    // final pnLink = networkName == 'polkadot' || networkName == 'kusama'
    //     ? 'https://polkascan.io/${networkName.toLowerCase()}/transaction/$hash'
    //     : null;
    // final snLink =
    //     'https://${networkName.toLowerCase()}.subscan.io/extrinsic/$hash';
    list.addAll(<Widget>[
      ListTile(
        leading: buildLabel('Event'),
        title: Text(eventId),
      ),
      ListTile(
        leading: buildLabel('Block'),
        title: Text('#$blockNum'),
      ),
      // ListTile(
      //   leading: buildLabel('Hash'),
      //   title: Text(Fmt.address(hash)),
      //   trailing: Container(
      //     width: 140,
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: <Widget>[
      //         JumpToBrowserLink(
      //           arascanLink,
      //           text: 'AraScan',
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    ]);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    return Scaffold(
      appBar: AppBar(
        title: Text(dic['detail']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(bottom: 32),
          children: _buildListView(context),
        ),
      ),
    );
  }
}

class TxDetailInfoItem {
  TxDetailInfoItem({this.label, this.title, this.subtitle, this.copyText});
  final String label;
  final String title;
  final String subtitle;
  final String copyText;
}
