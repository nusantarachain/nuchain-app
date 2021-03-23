import 'package:mobx/mobx.dart';
import 'package:polkawallet_sdk/api/types/balanceData.dart';
import 'package:polkawallet_sdk/plugin/store/tokenData.dart';

part 'balances.g.dart';

class BalancesStore = BalancesStoreBase with _$BalancesStore;

abstract class BalancesStoreBase with Store {
  @observable
  BalanceData native;

  @observable
  List<TokenBalanceData> tokens;

  @observable
  ExtraTokenDataList extraTokens;

  @action
  void setBalance(BalanceData data) {
    native = data;
  }

  @action
  void setTokens(List<TokenBalanceData> ls) {
    tokens = ls;
  }

  @action
  void setExtraTokens(ExtraTokenDataList ls) {
    extraTokens = ls;
  }
}
