import 'package:json_annotation/json_annotation.dart';

part 'tokenMetadata.g.dart';

@JsonSerializable(explicitToJson: true)
class TokenMetadata extends _TokenMetadata {
  static TokenMetadata fromJson(Map<String, dynamic> json) =>
      _$TokenMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$TokenMetadataToJson(this);
}

abstract class _TokenMetadata {
  String name;
  String symbol;
  int decimals;
  dynamic deposit;
}
