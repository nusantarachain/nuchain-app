import 'dart:math';

import 'package:intl/intl.dart';

class ValidatorData extends _ValidatorData {
  static ValidatorData fromJson(Map<String, dynamic> json) {
    ValidatorData data = ValidatorData();
    data.accountId = json['accountId'];
    if (json['exposure'] != null) {
      data.total = BigInt.parse(json['exposure']['total'].toString());
      data.bondOwn = BigInt.parse(json['exposure']['own'].toString());
      data.bondOther = data.total - data.bondOwn;

      data.isActive = json['isActive'];
      data.isElected = json['isElected'];

      data.numNominators = json['numNominators'];
      data.rankBondTotal = json['rankBondTotal'];
      data.rankReward = json['rankReward'];

      data.stakedReturn = double.parse(json['stakedReturn'].toString());
      data.stakedReturnCmp = double.parse(json['stakedReturnCmp'].toString());

      data.commission = NumberFormat('0.00%')
          .format(json['validatorPrefs']['commission'] / pow(10, 9));
      data.nominators =
          List<Map<String, dynamic>>.from(json['exposure']['others']);
    }
    return data;
  }
}

abstract class _ValidatorData {
  String accountId = '';

  BigInt total = BigInt.zero;
  BigInt bondOwn = BigInt.zero;
  BigInt bondOther = BigInt.zero;

  bool isActive = false;
  bool isElected = false;

  int numNominators = 0;
  int rankBondTotal = 0;
  int rankReward = 0;

  double stakedReturn = 0;
  double stakedReturnCmp = 0;

  String commission = '';

  List<Map<String, dynamic>> nominators = List<Map<String, dynamic>>();
}
