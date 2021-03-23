// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExtraTokenDataList _$ExtraTokenDataListFromJson(Map<String, dynamic> json) {
  return ExtraTokenDataList()
    ..extraTokenData = (json['extraTokenData'] as List)
        ?.map((e) => e == null
            ? null
            : ExtraTokenData.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$ExtraTokenDataListToJson(ExtraTokenDataList instance) =>
    <String, dynamic>{
      'extraTokenData':
          instance.extraTokenData?.map((e) => e?.toJson())?.toList(),
    };

ExtraTokenData _$ExtraTokenDataFromJson(Map<String, dynamic> json) {
  return ExtraTokenData()
    ..title = json['title'] as String
    ..tokens = (json['tokens'] as List)
        ?.map((e) => e == null
            ? null
            : TokenBalanceData.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$ExtraTokenDataToJson(ExtraTokenData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'tokens': instance.tokens?.map((e) => e?.toJson())?.toList(),
    };

TokenBalanceData _$TokenBalanceDataFromJson(Map<String, dynamic> json) {
  return TokenBalanceData()
    ..name = json['name'] as String
    ..symbol = json['symbol'] as String
    ..amount = json['amount']
    ..detailPageRoute = json['detailPageRoute'] as String;
}

Map<String, dynamic> _$TokenBalanceDataToJson(TokenBalanceData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'amount': instance.amount,
      'detailPageRoute': instance.detailPageRoute,
    };
