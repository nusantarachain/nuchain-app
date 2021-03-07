import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_sdk/webviewWithExtension/types/signExtrinsicParam.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/infoItemRow.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class WalletExtensionSignPage extends StatefulWidget {
  WalletExtensionSignPage(this.plugin, this.keyring, this.getPassword);
  final PolkawalletPlugin plugin;
  final Keyring keyring;
  final Future<String> Function(BuildContext, KeyPairData) getPassword;

  static const String route = '/extension/sign';

  static const String signTypeBytes = 'pub(bytes.sign)';
  static const String signTypeExtrinsic = 'pub(extrinsic.sign)';

  @override
  _WalletExtensionSignPageState createState() =>
      _WalletExtensionSignPageState();
}

class _WalletExtensionSignPageState extends State<WalletExtensionSignPage> {
  bool _submitting = false;

  Future<void> _showPasswordDialog(KeyPairData acc) async {
    final password = await widget.getPassword(context, acc);
    if (password != null) {
      _sign(password);
    }
  }

  Future<void> _sign(String password) async {
    setState(() {
      _submitting = true;
    });
    final SignAsExtensionParam args = ModalRoute.of(context).settings.arguments;
    final res =
        await widget.plugin.sdk.api.keyring.signAsExtension(password, args);
    if (mounted) {
      setState(() {
        _submitting = false;
      });
    }
    Navigator.of(context).pop(ExtensionSignResult.fromJson({
      'id': args.id,
      'signature': res.signature,
    }));
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    final SignAsExtensionParam args = ModalRoute.of(context).settings.arguments;
    final address = args.msgType == WalletExtensionSignPage.signTypeBytes
        ? SignBytesRequest.fromJson(Map<String, dynamic>.of(args.request))
            .address
        : SignBytesRequest.fromJson(Map<String, dynamic>.of(args.request))
            .address;
    final KeyPairData acc = widget.keyring.keyPairs.firstWhere((acc) {
      bool matched = false;
      widget.keyring.store.pubKeyAddressMap.values.forEach((e) {
        e.forEach((k, v) {
          if (acc.pubKey == k && address == v) {
            matched = true;
          }
        });
      });
      return matched;
    });
    return Scaffold(
      appBar: AppBar(
          title: Text(dic[args.msgType == WalletExtensionSignPage.signTypeBytes
              ? 'submit.sign.tx'
              : 'submit.sign.msg']),
          centerTitle: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: AddressFormItem(acc,
                        svg: acc.icon, label: dic['submit.signer']),
                  ),
                  args.msgType == WalletExtensionSignPage.signTypeExtrinsic
                      ? SignExtrinsicInfo(args)
                      : SignBytesInfo(args),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    color: _submitting ? Colors.black12 : Colors.orange,
                    child: FlatButton(
                      padding: EdgeInsets.all(16),
                      child: Text(dic['cancel'],
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: _submitting
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).primaryColor,
                    child: FlatButton(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        dic['submit.sign'],
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed:
                          _submitting ? null : () => _showPasswordDialog(acc),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SignExtrinsicInfo extends StatelessWidget {
  SignExtrinsicInfo(this.msg);
  final SignAsExtensionParam msg;
  @override
  Widget build(BuildContext context) {
    final req =
        SignExtrinsicRequest.fromJson(Map<String, dynamic>.of(msg.request));
    return Column(
      children: [
        InfoItemRow('from', msg.url),
        InfoItemRow('genesis', Fmt.address(req.genesisHash, pad: 10)),
        InfoItemRow('version', int.parse(req.specVersion).toString()),
        InfoItemRow('nonce', int.parse(req.nonce).toString()),
        InfoItemRow('method data', Fmt.address(req.method, pad: 10)),
      ],
    );
  }
}

class SignBytesInfo extends StatelessWidget {
  SignBytesInfo(this.msg);
  final SignAsExtensionParam msg;
  @override
  Widget build(BuildContext context) {
    final req = SignBytesRequest.fromJson(Map<String, dynamic>.of(msg.request));
    return Column(
      children: [
        InfoItemRow('from', msg.url),
        InfoItemRow('bytes', Fmt.address(req.data, pad: 10)),
      ],
    );
  }
}
