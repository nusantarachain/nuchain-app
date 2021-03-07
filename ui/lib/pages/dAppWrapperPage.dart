import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/webviewWithExtension/webviewWithExtension.dart';
import 'package:polkawallet_ui/pages/walletExtensionSignPage.dart';

class DAppWrapperPage extends StatefulWidget {
  DAppWrapperPage(this.plugin, this.keyring);
  final PolkawalletPlugin plugin;
  final Keyring keyring;

  static const String route = '/extension/app';

  @override
  _DAppWrapperPageState createState() => _DAppWrapperPageState();
}

class _DAppWrapperPageState extends State<DAppWrapperPage> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    final String url = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            url,
            style: TextStyle(fontSize: 16),
          ),
          centerTitle: true),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWithExtension(
              widget.plugin.sdk.api,
              url,
              widget.keyring,
              onPageFinished: (url) {
                setState(() {
                  _loading = false;
                });
              },
              onSignBytesRequest: (req) async {
                final signed = await Navigator.of(context)
                    .pushNamed(WalletExtensionSignPage.route, arguments: req);
                return signed;
              },
              onSignExtrinsicRequest: (req) async {
                final signed = await Navigator.of(context)
                    .pushNamed(WalletExtensionSignPage.route, arguments: req);
                return signed;
              },
            ),
            _loading ? Center(child: CupertinoActivityIndicator()) : Container()
          ],
        ),
      ),
    );
  }
}
