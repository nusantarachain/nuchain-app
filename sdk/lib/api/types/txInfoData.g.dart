// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'txInfoData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxInfoData _$TxInfoDataFromJson(Map<String, dynamic> json) {
  return TxInfoData(
    json['module'] as String,
    json['call'] as String,
    json['sender'] == null
        ? null
        : TxSenderData.fromJson(json['sender'] as Map<String, dynamic>),
    tip: json['tip'] as String,
    isUnsigned: json['isUnsigned'] as bool,
    proxy: json['proxy'] == null
        ? null
        : TxSenderData.fromJson(json['proxy'] as Map<String, dynamic>),
    txName: json['txName'] as String,
  );
}

Map<String, dynamic> _$TxInfoDataToJson(TxInfoData instance) =>
    <String, dynamic>{
      'module': instance.module,
      'call': instance.call,
      'sender': instance.sender?.toJson(),
      'tip': instance.tip,
      'isUnsigned': instance.isUnsigned,
      'proxy': instance.proxy?.toJson(),
      'txName': instance.txName,
    };

TxSenderData _$TxSenderDataFromJson(Map<String, dynamic> json) {
  return TxSenderData(
    json['address'] as String,
    json['pubKey'] as String,
  );
}

Map<String, dynamic> _$TxSenderDataToJson(TxSenderData instance) =>
    <String, dynamic>{
      'address': instance.address,
      'pubKey': instance.pubKey,
    };

TxFeeEstimateResult _$TxFeeEstimateResultFromJson(Map<String, dynamic> json) {
  return TxFeeEstimateResult()
    ..weight = json['weight']
    ..partialFee = json['partialFee'];
}

Map<String, dynamic> _$TxFeeEstimateResultToJson(
        TxFeeEstimateResult instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'partialFee': instance.partialFee,
    };
