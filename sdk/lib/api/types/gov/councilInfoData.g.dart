// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'councilInfoData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CouncilInfoData _$CouncilInfoDataFromJson(Map<String, dynamic> json) {
  return CouncilInfoData()
    ..desiredSeats = json['desiredSeats'] as String
    ..termDuration = json['termDuration'] as String
    ..votingBond = json['votingBond'] as String
    ..members = (json['members'] as List)?.map((e) => e as List)?.toList()
    ..runnersUp = (json['runnersUp'] as List)?.map((e) => e as List)?.toList()
    ..candidates =
        (json['candidates'] as List)?.map((e) => e as String)?.toList()
    ..candidateCount = json['candidateCount'] as String
    ..candidacyBond = json['candidacyBond'] as String;
}

Map<String, dynamic> _$CouncilInfoDataToJson(CouncilInfoData instance) =>
    <String, dynamic>{
      'desiredSeats': instance.desiredSeats,
      'termDuration': instance.termDuration,
      'votingBond': instance.votingBond,
      'members': instance.members,
      'runnersUp': instance.runnersUp,
      'candidates': instance.candidates,
      'candidateCount': instance.candidateCount,
      'candidacyBond': instance.candidacyBond,
    };
