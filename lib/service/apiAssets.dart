import 'package:app/service/index.dart';

class ApiAssets {
  ApiAssets(this.apiRoot);

  final AppService apiRoot;

  Future<Map> updateTxs(int page) async {
    apiRoot.store.assets.setTxsLoading(true);

    final acc = apiRoot.keyring.current;
    Map res = await apiRoot.araScan.fetchTransfersAsync(
      acc.address,
      page,
      network: apiRoot.plugin.basic.name,
    );

    if (page == 0) {
      apiRoot.store.assets.clearTxs();
    }
    // cache first page of txs
    await apiRoot.store.assets.addTxs(
      res,
      acc,
      apiRoot.plugin.basic.name,
      shouldCache: page == 0,
    );

    apiRoot.store.assets.setTxsLoading(false);
    return res;
  }

  Future<void> fetchMarketPrice() async {
    if (apiRoot.plugin.basic.isTestNet) return;

    final Map res =
        await apiRoot.araScan.fetchTokenPriceAsync(apiRoot.plugin.basic.name);
    if (res == null || res['token'] == null) {
      print('fetch market price failed');
      return;
    }

    List<dynamic> tokens = res['token'];
    // final String token = res['token'][0];

    tokens.forEach((token){
    if (token is String){
          apiRoot.store.assets
              .setMarketPrices(token, res['detail'][token]['price']);
          apiRoot.store.assets
              .setTokenIds(token, res['detail'][token]['asset_id']);
              }
        });
  }

//   // @TODO(*): check this
//   Future<void> fetchExtraTokens() async {
//     if (apiRoot.plugin.basic.isTestNet) return;

//     final Map res =
//         await apiRoot.araScan.fetchExtraTokensAsync(apiRoot.plugin.basic.name);
//     if (res == null || res['tokens'] == null) {
//       print('fetch market price failed');
//       return;
//     }

//     List<dynamic> tokens = res['tokens'];

//     tokens.forEach((token) => {
//           apiRoot.store.assets
//               .setMarketPrices(token, res['detail'][token]['price'])
//         });
//   }
}
