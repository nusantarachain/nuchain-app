import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/components/roundedButton.dart';
import 'package:polkawallet_ui/utils/i18n.dart';
import 'package:polkawallet_ui/utils/index.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:polkawallet_sdk/utils/i18n.dart';

class AccountQrCodePage extends StatelessWidget {
  AccountQrCodePage(this.plugin, this.keyring);
  final PolkawalletPlugin plugin;
  final Keyring keyring;

  static final String route = '/assets/receive';

  @override
  Widget build(BuildContext context) {
    String codeAddress =
        'substrate:${keyring.current.address}:${keyring.current.pubKey}:${keyring.current.name}';
    Color themeColor = Theme.of(context).primaryColor;

    final accInfo = keyring.current.indexInfo;

    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
            I18n.of(context).getDic(i18n_full_dic_ui, 'account')['receive']),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Stack(
              alignment: AlignmentDirectional.topCenter,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(32),
                  child: Image.asset(
                      'packages/polkawallet_ui/assets/images/receive_line.png'),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.all(const Radius.circular(4)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: AddressIcon(
                          keyring.current.address,
                          svg: keyring.current.icon,
                        ),
                      ),
                      Text(
                        UI.accountDisplayNameString(
                            keyring.current.address, keyring.current.indexInfo),
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      accInfo != null && accInfo['accountIndex'] != null
                          ? Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(accInfo['accountIndex']),
                            )
                          : Container(width: 8, height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: themeColor),
                          borderRadius:
                              BorderRadius.all(const Radius.circular(8)),
                        ),
                        margin: EdgeInsets.fromLTRB(48, 16, 48, 24),
                        child: QrImage(
                          data: codeAddress,
                          size: 200,
                          embeddedImage: AssetImage(
                              'packages/polkawallet_ui/assets/images/app.png'),
                          embeddedImageStyle:
                              QrEmbeddedImageStyle(size: Size(40, 40)),
                        ),
                      ),
                      Container(
                        width: 160,
                        child: Text(keyring.current.address),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        padding: EdgeInsets.only(top: 16, bottom: 32),
                        child: RoundedButton(
                          text: I18n.of(context)
                              .getDic(i18n_full_dic_ui, 'common')['copy'],
                          onPressed: () => UI.copyAndNotify(
                              context, keyring.current.address),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
