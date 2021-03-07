import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class PasswordInputDialog extends StatefulWidget {
  PasswordInputDialog(this.api,
      {this.account, this.userPass, this.title, this.content});

  final PolkawalletApi api;
  final KeyPairData account;
  final String userPass;
  final Widget title;
  final Widget content;

  @override
  _PasswordInputDialog createState() => _PasswordInputDialog();
}

class _PasswordInputDialog extends State<PasswordInputDialog> {
  final TextEditingController _passCtrl = new TextEditingController();

  bool _submitting = false;

  Future<void> _submit(String password) async {
    setState(() {
      _submitting = true;
    });
    var passed =
        await widget.api.keyring.checkPassword(widget.account, password);
    if (mounted) {
      setState(() {
        _submitting = false;
      });
    }
    if (!passed) {
      final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(dic['pass.error']),
            content: Text(dic['pass.error.text']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(dic['ok']),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).pop(password);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userPass != null) {
        _submit(widget.userPass);
      }
    });
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');

    return CupertinoAlertDialog(
      title: widget.title ?? Container(),
      content: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: widget.content ?? Container(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: CupertinoTextField(
              placeholder: dic['pass.old'],
              controller: _passCtrl,
              obscureText: true,
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        CupertinoButton(
          child: Text(dic['cancel']),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _submitting ? CupertinoActivityIndicator() : Container(),
              Text(dic['ok'])
            ],
          ),
          onPressed: _submitting ? null : () => _submit(_passCtrl.text.trim()),
        ),
      ],
    );
  }
}
