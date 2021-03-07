import 'dart:async';

import 'package:app/common/consts.dart';
import 'package:app/service/index.dart';
import 'package:app/utils/i18n/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_plugin_nuchain/utils/i18n/index.dart';
import 'package:polkawallet_sdk/api/apiKeyring.dart';
import 'package:polkawallet_sdk/api/types/recoveryInfo.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_sdk/utils/i18n.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:polkawallet_ui/components/passwordInputDialog.dart';

class ApiAccount {
  ApiAccount(this.apiRoot);

  final AppService apiRoot;

  final _biometricEnabledKey = 'biometric_enabled_';
  final _biometricPasswordKey = 'biometric_password_';

  Future<void> generateAccount() async {
    final mnemonic = await apiRoot.plugin.sdk.api.keyring.generateMnemonic();
    apiRoot.store.account.setNewAccountKey(mnemonic);
  }

  Future<Map> importAccount({
    KeyType keyType = KeyType.mnemonic,
    CryptoType cryptoType = CryptoType.sr25519,
    String derivePath = '',
  }) async {
    final acc = apiRoot.store.account.newAccount;
    final res = await apiRoot.plugin.sdk.api.keyring.importAccount(
      apiRoot.keyring,
      keyType: keyType,
      cryptoType: cryptoType,
      derivePath: derivePath,
      key: acc.key,
      name: acc.name,
      password: acc.password,
    );
    return res;
  }

  Future<KeyPairData> addAccount({
    Map json,
    KeyType keyType = KeyType.mnemonic,
    CryptoType cryptoType = CryptoType.sr25519,
    String derivePath = '',
  }) async {
    final acc = apiRoot.store.account.newAccount;
    final res = await apiRoot.plugin.sdk.api.keyring.addAccount(
      apiRoot.keyring,
      keyType: keyType,
      acc: json,
      password: acc.password,
    );
    return res;
  }

  void setBiometricEnabled(String pubKey) {
    apiRoot.store.storage.write(
        '$_biometricEnabledKey$pubKey', DateTime.now().millisecondsSinceEpoch);
  }

  void setBiometricDisabled(String pubKey) {
    apiRoot.store.storage.write('$_biometricEnabledKey$pubKey',
        DateTime.now().millisecondsSinceEpoch - SECONDS_OF_DAY * 7000);
  }

  bool getBiometricEnabled(String pubKey) {
    final timestamp =
        apiRoot.store.storage.read('$_biometricEnabledKey$pubKey');
    // we cache user's password with biometric for 7 days.
    if (timestamp != null &&
        timestamp + SECONDS_OF_DAY * 7000 >
            DateTime.now().millisecondsSinceEpoch) {
      return true;
    }
    return false;
  }

  Future<BiometricStorageFile> getBiometricPassStoreFile(
    BuildContext context,
    String pubKey,
  ) async {
    return BiometricStorage().getStorage(
      '$_biometricPasswordKey$pubKey',
      options:
          StorageFileInitOptions(authenticationValidityDurationSeconds: 30),
      androidPromptInfo: AndroidPromptInfo(
        title:
            I18n.of(context).getDic(i18n_full_dic_app, 'account')['unlock.bio'],
        negativeButton:
            I18n.of(context).getDic(i18n_full_dic_nuchain, 'common')['cancel'],
      ),
    );
  }

  Future<String> getPasswordWithBiometricAuth(
      BuildContext context, String pubKey) async {
    final response = await BiometricStorage().canAuthenticate();

    final supportBiometric = response == CanAuthenticateResponse.success;
    final isBiometricAuthorized = getBiometricEnabled(pubKey);
    if (supportBiometric) {
      final authStorage = await getBiometricPassStoreFile(context, pubKey);
      // we prompt biometric auth here if device supported
      // and user authorized to use biometric.
      if (isBiometricAuthorized) {
        try {
          final result = await authStorage.read();
          print('read password from authStorage: $result');
          if (result != null) {
            return result;
          }
        } catch (err) {
          print(err);
          // Navigator.of(context).pop();
        }
      }
    }
    return null;
  }

  Future<String> getPassword(BuildContext context, KeyPairData acc) async {
    final bioPass = await getPasswordWithBiometricAuth(context, acc.pubKey);
    final password = await showCupertinoDialog(
      context: context,
      builder: (_) {
        return PasswordInputDialog(
          apiRoot.plugin.sdk.api,
          title: Text(
              I18n.of(context).getDic(i18n_full_dic_app, 'account')['unlock']),
          account: acc,
          userPass: bioPass,
        );
      },
    );
    return password;
  }

  Future<void> queryAddressIcons(List addresses) async {
    addresses.retainWhere(
        (e) => !apiRoot.store.account.addressIconsMap.containsKey(e));
    if (addresses.length == 0) return;

    final icons =
        await apiRoot.plugin.sdk.api.account.getAddressIcons(addresses);
    apiRoot.store.account.setAddressIconsMap(icons);
  }

  Future<RecoveryInfo> queryRecoverable(String address) async {
//    address = "J4sW13h2HNerfxTzPGpLT66B3HVvuU32S6upxwSeFJQnAzg";
    final res = await apiRoot.plugin.sdk.api.recovery.queryRecoverable(address);

    if (res != null && res.friends.length > 0) {
      queryAddressIcons(res.friends);
    }
    return res;
  }
}
