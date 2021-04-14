// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokenMetadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenMetadata _$TokenMetadataFromJson(Map<String, dynamic> json) {
  return TokenMetadata()
    ..name = json['name'] as String
    ..symbol = json['symbol'] as String
    ..decimals = json['decimals'] as int
    ..deposit = json['deposit'];
}

Map<String, dynamic> _$TokenMetadataToJson(TokenMetadata instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'decimals': instance.decimals,
      'deposit': instance.deposit,
    };
