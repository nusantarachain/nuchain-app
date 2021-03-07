import 'dart:convert';

import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/api/types/txInfoData.dart';
import 'package:polkawallet_sdk/service/uos.dart';
import 'package:polkawallet_sdk/storage/keyring.dart';

/// Steps to complete offline-signature as a cold-wallet:
/// 1. parseQrCode: parse raw data of QR code, and get signer address from it.
/// 2. signAsync: sign the extrinsic with password, get signature.
/// 3. addSignatureAndSend: send tx with address of step1 & signature of step2.
///
/// Support offline-signature as a hot-wallet: makeQrCode
class ApiUOS {
  ApiUOS(this.apiRoot, this.service);

  final PolkawalletApi apiRoot;
  final ServiceUOS service;

  /// parse data of QR code.
  /// @return: signer pubKey [String]
  Future<String> parseQrCode(Keyring keyring, String data) async {
    return service.parseQrCode(keyring.store.list.toList(), data);
  }

  /// this function must be called after parseQrCode.
  /// @return: signature [String]
  Future<String> signAsync(String password) async {
    return service.signAsync(password);
  }

  /// [onStatusChange] is a callback when tx status change.
  /// @return txHash [string] if tx finalized success.
  Future<Map> addSignatureAndSend(
    String address,
    signed,
    Function(String) onStatusChange,
  ) async {
    final res = service.addSignatureAndSend(
      address,
      signed,
      onStatusChange ?? (status) => print(status),
    );
    return res;
  }

  Future<Map> makeQrCode(TxInfoData txInfo, List params,
      {String rawParam}) async {
    final Map res = await service.makeQrCode(
      txInfo.toJson(),
      params,
      rawParam: rawParam,
      ss58: apiRoot.connectedNode.ss58,
    );
    return res;
  }
}
