import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/api/types/recoveryInfo.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:polkawallet_ui/components/addressFormItem.dart';
import 'package:polkawallet_ui/components/tapTooltip.dart';
import 'package:polkawallet_ui/components/txButton.dart';
import 'package:polkawallet_ui/pages/accountListPage.dart';
import 'package:polkawallet_ui/pages/qrSenderPage.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/i18n.dart';

class TxConfirmPage extends StatefulWidget {
  const TxConfirmPage(this.plugin, this.keyring, this.getPassword);
  final PolkawalletPlugin plugin;
  final Keyring keyring;
  final Future<String> Function(BuildContext, KeyPairData) getPassword;

  static final String route = '/tx/confirm';

  @override
  _TxConfirmPageState createState() => _TxConfirmPageState();
}

class _TxConfirmPageState extends State<TxConfirmPage> {
  bool _submitting = false;

  TxFeeEstimateResult _fee;
  double _tip = 0;
  BigInt _tipValue = BigInt.zero;
  KeyPairData _proxyAccount;
  RecoveryInfo _recoveryInfo = RecoveryInfo();

  Future<String> _getTxFee({bool reload = false}) async {
    if (_fee?.partialFee != null && !reload) {
      return _fee.partialFee.toString();
    }
    if (widget.plugin.basic.name == 'kusama' &&
        (widget.keyring.current.observation ?? false)) {
      final recoveryInfo = await widget.plugin.sdk.api.recovery
          .queryRecoverable(widget.keyring.current.address);
      setState(() {
        _recoveryInfo = recoveryInfo;
      });
    }

    final TxConfirmParams args = ModalRoute.of(context).settings.arguments;
    final sender = TxSenderData(
        widget.keyring.current.address, widget.keyring.current.pubKey);
    final txInfo =
        TxInfoData(args.module, args.call, sender, txName: args.txName);
    // if (_proxyAccount != null) {
    //   txInfo['proxy'] = _proxyAccount.pubKey;
    // }
    final fee = await widget.plugin.sdk.api.tx
        .estimateFees(txInfo, args.params, rawParam: args.rawParams);
    setState(() {
      _fee = fee;
    });
    return fee.partialFee.toString();
  }

  Future<void> _onSwitch(bool value) async {
    if (value) {
      final accounts = widget.keyring.keyPairs.toList();
      accounts.addAll(widget.keyring.externals);
      final acc = await Navigator.of(context).pushNamed(
        AccountListPage.route,
        arguments: AccountListPageParams(list: accounts),
      );
      if (acc != null) {
        setState(() {
          _proxyAccount = acc;
        });
      }
    } else {
      setState(() {
        _proxyAccount = null;
      });
    }
    _getTxFee(reload: true);
  }

  void _onTxFinish(BuildContext context, Map res) {
    print('callback triggered, blockHash: ${res['hash']}');
    if (mounted) {
      final ScaffoldState state = Scaffold.of(context);

      state.removeCurrentSnackBar();
      state.showSnackBar(SnackBar(
        backgroundColor: Colors.white,
        content: ListTile(
          leading: Container(
            width: 24,
            child: Image.asset(
                'packages/polkawallet_ui/assets/images/success.png'),
          ),
          title: Text(
            I18n.of(context).getDic(i18n_full_dic_ui, 'common')['success'],
            style: TextStyle(color: Colors.black54),
          ),
        ),
        duration: Duration(seconds: 2),
      ));

      Timer(Duration(seconds: 2), () {
        Navigator.of(context).pop(res);
      });
    }
  }

  void _onTxError(BuildContext context, String errorMsg) {
    if (mounted) {
      Scaffold.of(context).removeCurrentSnackBar();
    }
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Container(),
          content: Text(errorMsg),
          actions: <Widget>[
            CupertinoButton(
              child: Text(
                  I18n.of(context).getDic(i18n_full_dic_ui, 'common')['ok']),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _validateProxy() async {
    List proxies = await widget.plugin.sdk.api.recovery
        .queryRecoveryProxies([_proxyAccount.address]);
    print(proxies);
    return proxies[0] == widget.keyring.current.address;
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    if (_proxyAccount != null && !(await _validateProxy())) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(Fmt.address(widget.keyring.current.address)),
            content: Text(dic['tx.proxy.invalid']),
            actions: <Widget>[
              CupertinoButton(
                child: Text(
                  dic['cancel'],
                  style: TextStyle(
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final password = await widget.getPassword(
        context, _proxyAccount ?? widget.keyring.current);
    if (password != null) {
      _onSubmit(context, password: password);
    }
  }

  Future<void> _onSubmit(
    BuildContext context, {
    String password,
    bool viaQr = false,
  }) async {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    final TxConfirmParams args = ModalRoute.of(context).settings.arguments;

    setState(() {
      _submitting = true;
    });
    _updateTxStatus(context, dic['tx.wait']);

    final TxSenderData sender = TxSenderData(
      widget.keyring.current.address,
      widget.keyring.current.pubKey,
    );
    final TxInfoData txInfo = TxInfoData(
      args.module,
      args.call,
      sender,
      proxy: _proxyAccount != null
          ? TxSenderData(_proxyAccount.address, _proxyAccount.pubKey)
          : null,
      tip: _tipValue.toString(),
      txName: args.txName,
    );

    try {
      final res = viaQr
          ? await _sendTxViaQr(context, txInfo, args)
          : await _sendTx(context, txInfo, args, password);
      _onTxFinish(context, res);
    } catch (err) {
      _onTxError(context, err.toString());
    }
    setState(() {
      _submitting = false;
    });
  }

  Future<Map> _sendTx(
    BuildContext context,
    TxInfoData txInfo,
    TxConfirmParams args,
    String password,
  ) async {
    return widget.plugin.sdk.api.tx.signAndSend(txInfo, args.params, password,
        rawParam: args.rawParams, onStatusChange: (status) {
      final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
      _updateTxStatus(context, dic['tx.$status'] ?? status);
    });
  }

  Future<Map> _sendTxViaQr(
    BuildContext context,
    TxInfoData txInfo,
    TxConfirmParams args,
  ) async {
    final Map dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    print('show qr');
    final signed = await Navigator.of(context).pushNamed(
      QrSenderPage.route,
      arguments: QrSenderPageParams(
        txInfo,
        args.params,
        rawParams: args.rawParams,
      ),
    );
    if (signed == null) {
      throw Exception(dic['tx.cancelled']);
    }
    final res = await widget.plugin.sdk.api.uos.addSignatureAndSend(
        widget.keyring.current.address, signed.toString(), (status) {
      _updateTxStatus(context, dic['tx.$status'] ?? status);
    });
    return res;
  }

  void _updateTxStatus(BuildContext context, String status) {
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Theme.of(context).cardColor,
      content: ListTile(
        leading: CupertinoActivityIndicator(),
        title: Text(
          status,
          style: TextStyle(color: Colors.black54),
        ),
      ),
      duration: Duration(minutes: 5),
    ));
  }

  void _onTipChanged(double tip) {
    final decimals = (widget.plugin.networkState.tokenDecimals ?? [12])[0];

    /// tip division from 0 to 19:
    /// 0-10 for 0-0.1
    /// 10-19 for 0.1-1
    BigInt value = Fmt.tokenInt('0.01', decimals) * BigInt.from(tip.toInt());
    if (tip > 10) {
      value = Fmt.tokenInt('0.1', decimals) * BigInt.from((tip - 9).toInt());
    }
    setState(() {
      _tip = tip;
      _tipValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context).getDic(i18n_full_dic_ui, 'common');
    final dicAcc = I18n.of(context).getDic(i18n_full_dic_ui, 'account');

    final bool isKusama = widget.plugin.basic.name == 'kusama';
    final String symbol = (widget.plugin.networkState.tokenSymbol ?? [''])[0];
    final int decimals = (widget.plugin.networkState.tokenDecimals ?? [12])[0];

    final TxConfirmParams args = ModalRoute.of(context).settings.arguments;

    final bool isObservation = widget.keyring.current.observation ?? false;
    final bool isProxyObservation =
        _proxyAccount != null ? _proxyAccount.observation ?? false : false;

    bool isUnsigned = args.isUnsigned ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(args.txTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      dic['tx.submit'],
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  isUnsigned
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: AddressFormItem(
                            widget.keyring.current,
                            label: dic["tx.from"],
                          ),
                        ),
                  isKusama && isObservation && _recoveryInfo?.address != null
                      ? Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            children: [
                              TapTooltip(
                                message: dic['tx.proxy.brief'],
                                child: Icon(Icons.info_outline, size: 16),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Text(dic['tx.proxy']),
                                ),
                              ),
                              CupertinoSwitch(
                                value: _proxyAccount != null,
                                onChanged: (res) => _onSwitch(res),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  _proxyAccount != null
                      ? GestureDetector(
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: AddressFormItem(
                              _proxyAccount,
                              label: dicAcc["proxy"],
                            ),
                          ),
                          onTap: () => _onSwitch(true),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Container(width: 64, child: Text(dic["tx.call"])),
                        Text('${args.module}.${args.call}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: <Widget>[
                        Container(width: 64, child: Text(dic["detail"])),
                        Container(
                          width: MediaQuery.of(context).copyWith().size.width -
                              120,
                          child: Text(
                            JsonEncoder.withIndent('  ')
                                .convert(args.txDisplay),
                          ),
                        ),
                      ],
                    ),
                  ),
                  isUnsigned
                      ? Container()
                      : FutureBuilder<String>(
                          future: _getTxFee(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              String fee = Fmt.balance(
                                _fee.partialFee.toString(),
                                decimals,
                                length: 6,
                              );
                              return Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 8),
                                      width: 64,
                                      child: Text(dic["tx.fee"]),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 8),
                                      width: MediaQuery.of(context)
                                              .copyWith()
                                              .size
                                              .width -
                                          120,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '$fee $symbol',
                                          ),
                                          Text(
                                            '${_fee.weight} Weight',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .unselectedWidgetColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 64,
                          child: Text(dic['tx.tip']),
                        ),
                        Text('${Fmt.token(_tipValue, decimals)} $symbol'),
                        TapTooltip(
                          message: dic['tx.tip.brief'],
                          child: Icon(
                            Icons.info,
                            color: Theme.of(context).unselectedWidgetColor,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Row(
                      children: <Widget>[
                        Text('0'),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: 19,
                            divisions: 19,
                            value: _tip,
                            onChanged: _submitting ? null : _onTipChanged,
                          ),
                        ),
                        Text('1')
                      ],
                    ),
                  )
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
                    child: Builder(
                      builder: (BuildContext context) {
                        return FlatButton(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            isUnsigned
                                ? dic['tx.no.sign']
                                : (isObservation && _proxyAccount == null) ||
                                        isProxyObservation
                                    ? dic['tx.qr']
                                    // dicAcc['observe.invalid']
                                    : dic['tx.submit'],
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: isUnsigned
                              ? () => _onSubmit(context)
                              : (isObservation && _proxyAccount == null) ||
                                      isProxyObservation
                                  ? () => _onSubmit(context, viaQr: true)
                                  : _submitting
                                      ? null
                                      : () => _showPasswordDialog(context),
                        );
                      },
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
