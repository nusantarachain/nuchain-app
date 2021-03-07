import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_scan/qrcode_reader_view.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:polkawallet_sdk/plugin/index.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';
import 'package:polkawallet_ui/utils/format.dart';

class ScanPage extends StatelessWidget {
  ScanPage(this.plugin, this.keyring);
  final PolkawalletPlugin plugin;
  final Keyring keyring;

  static final String route = '/account/scan';

  final GlobalKey<QrcodeReaderViewState> _qrViewKey = GlobalKey();

  Future<bool> canOpenCamera() async {
    var status =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (status != PermissionStatus.granted) {
      var future = await PermissionHandler()
          .requestPermissions([PermissionGroup.camera]);
      for (final item in future.entries) {
        if (item.value != PermissionStatus.granted) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Future onScan(String txt, String rawData) async {
      String address = '';
      final String data = txt.trim();
      if (data != null) {
        List<String> ls = data.split(':');

        if (ls[0] == 'wc') {
          print('walletconnect pairing uri detected.');
          Navigator.of(context).pop(QRCodeResult(
            type: QRCodeResultType.rawData,
            rawData: data,
          ));
          return;
        }

        for (String item in ls) {
          if (Fmt.isAddress(item)) {
            address = item;
            break;
          }
        }

        if (address.length > 0) {
          print('address detected in Qr');
          Navigator.of(context).pop(QRCodeResult(
            type: QRCodeResultType.address,
            address: ls.length == 4
                ? QRCodeAddressResult(ls)
                : QRCodeAddressResult(['', address, '', '']),
          ));
        } else if (Fmt.isHexString(data)) {
          print('hex detected in Qr');
          Navigator.of(context).pop(QRCodeResult(
            type: QRCodeResultType.hex,
            hex: data,
          ));
        } else if (rawData != null &&
            (rawData.endsWith('ec') || rawData.endsWith('ec11'))) {
          print('rawBytes detected in Qr');
          Navigator.of(context).pop(QRCodeResult(
            type: QRCodeResultType.rawData,
            rawData: rawData,
          ));
        } else {
          _qrViewKey.currentState.startScan();
        }
      }
    }

    return Scaffold(
      body: FutureBuilder<bool>(
        future: canOpenCamera(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return QrcodeReaderView(
                key: _qrViewKey,
                headerWidget: SafeArea(
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).cardColor,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                onScan: onScan);
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

enum QRCodeResultType { address, hex, rawData }

class QRCodeResult {
  QRCodeResult({this.type, this.address, this.hex, this.rawData});

  final QRCodeResultType type;
  final QRCodeAddressResult address;
  final String hex;
  final String rawData;
}

class QRCodeAddressResult {
  QRCodeAddressResult(this.rawData)
      : chainType = rawData[0],
        address = rawData[1],
        pubKey = rawData[2],
        name = rawData[3];

  final List<String> rawData;

  final String chainType;
  final String address;
  final String pubKey;
  final String name;
}
