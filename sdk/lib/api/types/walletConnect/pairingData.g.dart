// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pairingData.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WCPairingData _$WCPairingDataFromJson(Map<String, dynamic> json) {
  return WCPairingData()
    ..topic = json['topic'] as String
    ..relay = json['relay'] as Map<String, dynamic>
    ..proposer = json['proposer'] == null
        ? null
        : WCProposerInfo.fromJson(json['proposer'] as Map<String, dynamic>)
    ..signal = json['signal'] as Map<String, dynamic>
    ..permissions = json['permissions'] == null
        ? null
        : WCPermissionData.fromJson(json['permissions'] as Map<String, dynamic>)
    ..ttl = json['ttl'] as int;
}

Map<String, dynamic> _$WCPairingDataToJson(WCPairingData instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'relay': instance.relay,
      'proposer': instance.proposer?.toJson(),
      'signal': instance.signal,
      'permissions': instance.permissions?.toJson(),
      'ttl': instance.ttl,
    };

WCPairedData _$WCPairedDataFromJson(Map<String, dynamic> json) {
  return WCPairedData()
    ..topic = json['topic'] as String
    ..relay = json['relay'] as Map<String, dynamic>
    ..peer = json['peer'] == null
        ? null
        : WCProposerInfo.fromJson(json['peer'] as Map<String, dynamic>)
    ..permissions = json['permissions'] == null
        ? null
        : WCPermissionData.fromJson(json['permissions'] as Map<String, dynamic>)
    ..state = json['state'] as Map<String, dynamic>
    ..expiry = json['expiry'] as int;
}

Map<String, dynamic> _$WCPairedDataToJson(WCPairedData instance) =>
    <String, dynamic>{
      'topic': instance.topic,
      'relay': instance.relay,
      'peer': instance.peer?.toJson(),
      'permissions': instance.permissions?.toJson(),
      'state': instance.state,
      'expiry': instance.expiry,
    };

WCProposerInfo _$WCProposerInfoFromJson(Map<String, dynamic> json) {
  return WCProposerInfo()
    ..publicKey = json['publicKey'] as String
    ..metadata = json['metadata'] == null
        ? null
        : WCProposerMeta.fromJson(json['metadata'] as Map<String, dynamic>);
}

Map<String, dynamic> _$WCProposerInfoToJson(WCProposerInfo instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'metadata': instance.metadata?.toJson(),
    };

WCProposerMeta _$WCProposerMetaFromJson(Map<String, dynamic> json) {
  return WCProposerMeta()
    ..name = json['name'] as String
    ..description = json['description'] as String
    ..url = json['url'] as String
    ..icons = (json['icons'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$WCProposerMetaToJson(WCProposerMeta instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'url': instance.url,
      'icons': instance.icons,
    };

WCPermissionData _$WCPermissionDataFromJson(Map<String, dynamic> json) {
  return WCPermissionData()
    ..blockchain = json['blockchain'] as Map<String, dynamic>
    ..jsonrpc = json['jsonrpc'] as Map<String, dynamic>
    ..notifications = json['notifications'] as Map<String, dynamic>;
}

Map<String, dynamic> _$WCPermissionDataToJson(WCPermissionData instance) =>
    <String, dynamic>{
      'blockchain': instance.blockchain,
      'jsonrpc': instance.jsonrpc,
      'notifications': instance.notifications,
    };
