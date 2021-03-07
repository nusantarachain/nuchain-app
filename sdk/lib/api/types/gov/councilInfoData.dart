import 'package:json_annotation/json_annotation.dart';

part 'councilInfoData.g.dart';

@JsonSerializable()
class CouncilInfoData extends _CouncilInfoData {
  static CouncilInfoData fromJson(Map<String, dynamic> json) =>
      _$CouncilInfoDataFromJson(json);
  static Map<String, dynamic> toJson(CouncilInfoData info) =>
      _$CouncilInfoDataToJson(info);
}

abstract class _CouncilInfoData {
  String desiredSeats; // hex string
  String termDuration; // hex string
  String votingBond; // hex string

  List<List<dynamic>> members;
  List<List<dynamic>> runnersUp;
  List<String> candidates;

  String candidateCount; // hex string
  String candidacyBond; // hex string
}
