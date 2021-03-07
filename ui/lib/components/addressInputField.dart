import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:polkawallet_sdk/api/api.dart';
import 'package:polkawallet_sdk/storage/types/keyPairData.dart';
import 'package:polkawallet_ui/components/addressIcon.dart';
import 'package:polkawallet_ui/utils/format.dart';
import 'package:polkawallet_ui/utils/index.dart';

class AddressInputField extends StatefulWidget {
  AddressInputField(
    this.api,
    this.localAccounts, {
    this.label,
    this.initialValue,
    this.onChanged,
    Key key,
  }) : super(key: key);
  final PolkawalletApi api;
  final List<KeyPairData> localAccounts;
  final String label;
  final KeyPairData initialValue;
  final Function(KeyPairData) onChanged;

  @override
  _AddressInputFieldState createState() => _AddressInputFieldState();
}

class _AddressInputFieldState extends State<AddressInputField> {
  Map _addressIndexMap = {};
  Map _addressIconsMap = {};

  Map _getAddressInfo(KeyPairData acc) {
    return acc.indexInfo ?? _addressIndexMap[acc.address];
  }

  Future<List<KeyPairData>> _getAccountsFromInput(String input) async {
    // return local account list if input empty
    if (input.isEmpty || input.trim().length < 3) {
      return widget.localAccounts;
    }

    // check if user input is valid address or indices
    final checkAddress = await widget.api.account.decodeAddress([input]);
    if (checkAddress == null) {
      return widget.localAccounts;
    }

    final acc = KeyPairData();
    acc.address = input;
    if (input.length < 47) {
      // check if input indices in local account list
      final int indicesIndex = widget.localAccounts.indexWhere((e) {
        final Map accInfo = e.indexInfo;
        return accInfo != null && accInfo['accountIndex'] == input;
      });
      if (indicesIndex >= 0) {
        return [widget.localAccounts[indicesIndex]];
      }
      // query account address with account indices
      final queryRes =
          await widget.api.account.queryAddressWithAccountIndex(input);
      if (queryRes != null) {
        acc.address = queryRes;
        acc.name = input;
      }
    } else {
      // check if input address in local account list
      final int addressIndex = widget.localAccounts
          .indexWhere((e) => _itemAsString(e).contains(input));
      if (addressIndex >= 0) {
        return [widget.localAccounts[addressIndex]];
      }
    }

    // fetch address info if it's a new address
    final res = await widget.api.account.getAddressIcons([acc.address]);
    if (res != null) {
      if (res.length > 0) {
        final icon = res[0][1] is String ? res[0][1] : null;
        acc.icon = icon;
        setState(() {
          _addressIconsMap.addAll({acc.address: icon});
        });
      }

      final addressInfo =
          await widget.api.account.queryIndexInfo([acc.address]);
      if (addressInfo != null && addressInfo.length > 0) {
        acc.name = UI.accountDisplayNameString(acc.address, addressInfo[0]);
        setState(() {
          _addressIndexMap.addAll({acc.address: addressInfo[0]});
        });
      }
    }
    return [acc];
  }

  String _itemAsString(KeyPairData item) {
    final Map accInfo = _getAddressInfo(item);
    String idx = '';
    if (accInfo != null && accInfo['accountIndex'] != null) {
      idx = accInfo['accountIndex'];
    }
    if (item.name != null) {
      return '${item.name} $idx ${item.address}';
    }
    return '${UI.accountDisplayNameString(item.address, accInfo)} $idx ${item.address}';
  }

  Widget _selectedItemBuilder(
      BuildContext context, KeyPairData item, String itemDesignation) {
    if (item == null) {
      return Container();
    }
    final Map accInfo = _getAddressInfo(item);
    return Container(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          AddressIcon(item.address,
              size: 32,
              svg: item.icon ?? _addressIconsMap[item.address],
              tapToCopy: false),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Fmt.address(item.address)),
                Text(
                  item.name != null && item.name.isNotEmpty
                      ? item.name
                      : UI.accountDisplayNameString(item.address, accInfo),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).unselectedWidgetColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _listItemBuilder(
      BuildContext context, KeyPairData item, bool isSelected) {
    final Map accInfo = _getAddressInfo(item);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        dense: true,
        title: Text(Fmt.address(item.address)),
        subtitle: Text(
          item.name != null && item.name.isNotEmpty
              ? item.name
              : UI.accountDisplayNameString(item.address, accInfo),
        ),
        leading: AddressIcon(
          item.address,
          svg: item.icon ?? _addressIconsMap[item.address],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<KeyPairData>(
      mode: Mode.BOTTOM_SHEET,
      isFilteredOnline: true,
      showSearchBox: true,
      showSelectedItem: true,
      autoFocusSearchBox: true,
      searchBoxDecoration: InputDecoration(hintText: widget.label),
      label: widget.label,
      selectedItem: widget.initialValue,
      compareFn: (KeyPairData i, s) => i.pubKey == s?.pubKey,
      validator: (KeyPairData u) =>
          u == null ? "user field is required " : null,
      onFind: (String filter) => _getAccountsFromInput(filter),
      itemAsString: _itemAsString,
      onChanged: (KeyPairData data) {
        if (widget.onChanged != null) {
          widget.onChanged(data);
        }
      },
      dropdownBuilder: _selectedItemBuilder,
      popupItemBuilder: _listItemBuilder,
    );
  }
}
