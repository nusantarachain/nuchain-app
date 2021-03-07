// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountStore on _AccountStore, Store {
  final _$newAccountAtom = Atom(name: '_AccountStore.newAccount');

  @override
  AccountCreate get newAccount {
    _$newAccountAtom.reportRead();
    return super.newAccount;
  }

  @override
  set newAccount(AccountCreate value) {
    _$newAccountAtom.reportWrite(value, super.newAccount, () {
      super.newAccount = value;
    });
  }

  final _$pubKeyAddressMapAtom = Atom(name: '_AccountStore.pubKeyAddressMap');

  @override
  ObservableMap<int, Map<String, String>> get pubKeyAddressMap {
    _$pubKeyAddressMapAtom.reportRead();
    return super.pubKeyAddressMap;
  }

  @override
  set pubKeyAddressMap(ObservableMap<int, Map<String, String>> value) {
    _$pubKeyAddressMapAtom.reportWrite(value, super.pubKeyAddressMap, () {
      super.pubKeyAddressMap = value;
    });
  }

  final _$addressIconsMapAtom = Atom(name: '_AccountStore.addressIconsMap');

  @override
  ObservableMap<String, String> get addressIconsMap {
    _$addressIconsMapAtom.reportRead();
    return super.addressIconsMap;
  }

  @override
  set addressIconsMap(ObservableMap<String, String> value) {
    _$addressIconsMapAtom.reportWrite(value, super.addressIconsMap, () {
      super.addressIconsMap = value;
    });
  }

  final _$recoveryInfoAtom = Atom(name: '_AccountStore.recoveryInfo');

  @override
  RecoveryInfo get recoveryInfo {
    _$recoveryInfoAtom.reportRead();
    return super.recoveryInfo;
  }

  @override
  set recoveryInfo(RecoveryInfo value) {
    _$recoveryInfoAtom.reportWrite(value, super.recoveryInfo, () {
      super.recoveryInfo = value;
    });
  }

  final _$_AccountStoreActionController =
      ActionController(name: '_AccountStore');

  @override
  void setNewAccount(String name, String password) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setNewAccount');
    try {
      return super.setNewAccount(name, password);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setNewAccountKey(String key) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setNewAccountKey');
    try {
      return super.setNewAccountKey(key);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetNewAccount() {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.resetNewAccount');
    try {
      return super.resetNewAccount();
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPubKeyAddressMap(Map<String, Map<dynamic, dynamic>> data) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setPubKeyAddressMap');
    try {
      return super.setPubKeyAddressMap(data);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAddressIconsMap(List<dynamic> list) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAddressIconsMap');
    try {
      return super.setAddressIconsMap(list);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAccountRecoveryInfo(Map<dynamic, dynamic> json) {
    final _$actionInfo = _$_AccountStoreActionController.startAction(
        name: '_AccountStore.setAccountRecoveryInfo');
    try {
      return super.setAccountRecoveryInfo(json);
    } finally {
      _$_AccountStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
newAccount: ${newAccount},
pubKeyAddressMap: ${pubKeyAddressMap},
addressIconsMap: ${addressIconsMap},
recoveryInfo: ${recoveryInfo}
    ''';
  }
}

mixin _$AccountCreate on _AccountCreate, Store {
  final _$nameAtom = Atom(name: '_AccountCreate.name');

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  final _$passwordAtom = Atom(name: '_AccountCreate.password');

  @override
  String get password {
    _$passwordAtom.reportRead();
    return super.password;
  }

  @override
  set password(String value) {
    _$passwordAtom.reportWrite(value, super.password, () {
      super.password = value;
    });
  }

  final _$keyAtom = Atom(name: '_AccountCreate.key');

  @override
  String get key {
    _$keyAtom.reportRead();
    return super.key;
  }

  @override
  set key(String value) {
    _$keyAtom.reportWrite(value, super.key, () {
      super.key = value;
    });
  }

  @override
  String toString() {
    return '''
name: ${name},
password: ${password},
key: ${key}
    ''';
  }
}
