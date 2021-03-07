// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balanceData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BalanceData _$BalanceDataFromJson(Map<String, dynamic> json) {
  return BalanceData()
    ..accountId = json['accountId'] as String
    ..accountNonce = json['accountNonce']
    ..availableBalance = json['availableBalance']
    ..freeBalance = json['freeBalance']
    ..frozenFee = json['frozenFee']
    ..frozenMisc = json['frozenMisc']
    ..isVesting = json['isVesting'] as bool
    ..lockedBalance = json['lockedBalance']
    ..lockedBreakdown = (json['lockedBreakdown'] as List)
        ?.map((e) => e == null
            ? null
            : BalanceBreakdownData.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..reservedBalance = json['reservedBalance']
    ..vestedBalance = json['vestedBalance']
    ..vestedClaimable = json['vestedClaimable']
    ..vestingEndBlock = json['vestingEndBlock']
    ..vestingLocked = json['vestingLocked']
    ..vestingPerBlock = json['vestingPerBlock']
    ..vestingTotal = json['vestingTotal']
    ..votingBalance = json['votingBalance'];
}

Map<String, dynamic> _$BalanceDataToJson(BalanceData instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountNonce': instance.accountNonce,
      'availableBalance': instance.availableBalance,
      'freeBalance': instance.freeBalance,
      'frozenFee': instance.frozenFee,
      'frozenMisc': instance.frozenMisc,
      'isVesting': instance.isVesting,
      'lockedBalance': instance.lockedBalance,
      'lockedBreakdown':
          instance.lockedBreakdown?.map((e) => e?.toJson())?.toList(),
      'reservedBalance': instance.reservedBalance,
      'vestedBalance': instance.vestedBalance,
      'vestedClaimable': instance.vestedClaimable,
      'vestingEndBlock': instance.vestingEndBlock,
      'vestingLocked': instance.vestingLocked,
      'vestingPerBlock': instance.vestingPerBlock,
      'vestingTotal': instance.vestingTotal,
      'votingBalance': instance.votingBalance,
    };

BalanceBreakdownData _$BalanceBreakdownDataFromJson(Map<String, dynamic> json) {
  return BalanceBreakdownData()
    ..id = json['id'] as String
    ..amount = json['amount']
    ..reasons = json['reasons'] as String
    ..use = json['use'] as String;
}

Map<String, dynamic> _$BalanceBreakdownDataToJson(
        BalanceBreakdownData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'reasons': instance.reasons,
      'use': instance.use,
    };
