import 'package:json_annotation/json_annotation.dart';

part 'tokenData.g.dart';

@JsonSerializable(explicitToJson: true)
class ExtraTokenDataList extends _ExtraTokenDataList {
  // ExtraTokenDataList(List<ExtraTokenData> extra){
  //   this.extraTokenData = extra;
  // }
  
  static ExtraTokenDataList fromJson(Map<String, dynamic> json) =>
      _$ExtraTokenDataListFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraTokenDataListToJson(this);

  int get length => this.extraTokenData.length;

  List<ExtraTokenData> get data => this.extraTokenData;

  static ExtraTokenDataList load(List<ExtraTokenData> extra){
    ExtraTokenDataList rv = ExtraTokenDataList();
    rv.extraTokenData = extra;
    return rv;
  }
}

abstract class _ExtraTokenDataList {
  List<ExtraTokenData> extraTokenData;
}

@JsonSerializable(explicitToJson: true)
class ExtraTokenData extends _ExtraTokenData {
  static ExtraTokenData fromJson(Map<String, dynamic> json) =>
      _$ExtraTokenDataFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraTokenDataToJson(this);
}

abstract class _ExtraTokenData {
  String title;
  List<TokenBalanceData> tokens;
}

@JsonSerializable()
class TokenBalanceData extends _TokenBalanceData {
  static TokenBalanceData fromJson(Map<String, dynamic> json) =>
      _$TokenBalanceDataFromJson(json);
  Map<String, dynamic> toJson() => _$TokenBalanceDataToJson(this);
}

abstract class _TokenBalanceData {
  String name;
  String symbol;
  dynamic amount;

  String detailPageRoute;
}
