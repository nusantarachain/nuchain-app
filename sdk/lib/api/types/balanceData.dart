import 'package:json_annotation/json_annotation.dart';

part 'balanceData.g.dart';

@JsonSerializable(explicitToJson: true)
class BalanceData extends _BalanceData {
  static BalanceData fromJson(Map<String, dynamic> json) =>
      _$BalanceDataFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceDataToJson(this);
}

abstract class _BalanceData {
  String accountId;
  dynamic accountNonce;
  dynamic availableBalance;
  dynamic freeBalance;
  dynamic frozenFee;
  dynamic frozenMisc;
  bool isVesting;
  dynamic lockedBalance;
  List<BalanceBreakdownData> lockedBreakdown;
  dynamic reservedBalance;
  dynamic vestedBalance;
  dynamic vestedClaimable;
  dynamic vestingEndBlock;
  dynamic vestingLocked;
  dynamic vestingPerBlock;
  dynamic vestingTotal;
  dynamic votingBalance;
}

@JsonSerializable()
class BalanceBreakdownData extends _BalanceBreakdownData {
  static BalanceBreakdownData fromJson(Map<String, dynamic> json) =>
      _$BalanceBreakdownDataFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceBreakdownDataToJson(this);
}

abstract class _BalanceBreakdownData {
  String id;
  dynamic amount;
  String reasons;
  String use;
}
