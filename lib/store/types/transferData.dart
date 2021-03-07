import 'package:json_annotation/json_annotation.dart';

// part 'transferData.g.dart';


TransferData _$TransferDataFromJson(Map<String, dynamic> json) {
  return TransferData()
    ..blockNum = json['block'] as int
    ..blockTimestamp = json['ts'] as int
    ..extrinsicIndex = ""
    ..fee = "-"
    ..from = json['src'] as String
    ..to = json['dst'] as String
    ..amount = json['amount'] as String
    ..token = ""
    ..hash = "-"
    ..module = "balances"
    ..success = true;
}

Map<String, dynamic> _$TransferDataToJson(TransferData instance) =>
    <String, dynamic>{
      'block': instance.blockNum,
      'ts': instance.blockTimestamp,
      'extrinsic_index': instance.extrinsicIndex,
      'fee': instance.fee,
      'src': instance.from,
      'dst': instance.to,
      'amount': instance.amount,
      'token': instance.token,
      'hash': instance.hash,
      'module': instance.module,
      'success': instance.success,
    };


@JsonSerializable()
class TransferData extends _TransferData {
  static TransferData fromJson(Map<String, dynamic> json) =>
      _$TransferDataFromJson(json);
  static Map<String, dynamic> toJson(TransferData data) =>
      _$TransferDataToJson(data);
}

abstract class _TransferData {
  @JsonKey(name: 'block')
  int blockNum = 0;

  @JsonKey(name: 'ts')
  int blockTimestamp = 0;

  @JsonKey(name: 'extrinsic_index')
  String extrinsicIndex = "";

  String fee = "";

  String from = "";
  String to = "";
  String amount = "";
  String token = "";
  String hash = "";
  String module = "";
  bool success = true;
}
