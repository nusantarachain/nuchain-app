import 'package:get_storage/get_storage.dart';

const String sdk_storage_key = 'polka_wallet_sdk';

/// this is where we save keyPairs locally
class KeyringStorage {
  static final _storage = () => GetStorage(sdk_storage_key);

  final keyPairs = [].val('keyPairs', getBox: _storage);
  final contacts = [].val('contacts', getBox: _storage);
  final currentPubKey = ''.val('currentPubKey', getBox: _storage);
  final encryptedRawSeeds = {}.val('encryptedRawSeeds', getBox: _storage);
  final encryptedMnemonics = {}.val('encryptedMnemonics', getBox: _storage);
}
