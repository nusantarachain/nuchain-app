import "@babel/polyfill";
import { WsProvider, ApiPromise } from "@polkadot/api";
import { subscribeMessage, getNetworkConst, getNetworkProperties } from "./service/setting";
import keyring from "./service/keyring";
import account from "./service/account";
import staking from "./service/staking";
import wc from "./service/walletconnect";
import gov from "./service/gov";
import { genLinks } from "./utils/config/config";
import { Nuchain } from 'nuchain-js-api';

// send message to JSChannel: PolkaWallet
function send(path: string, data: any) {
  if (window.location.href.match("https://localhost:8080/")) {
    PolkaWallet.postMessage(JSON.stringify({ path, data }));
  } else {
    console.log(path, data);
  }
}
send("log", "main js loaded");
(<any>window).send = send;

/**
 * Connect to a specific node.
 *
 * @param {string} nodeEndpoint
 */
async function connect(nodes: string[]) {
  return new Promise(async (resolve, _reject) => {
    const wsProvider = new WsProvider(nodes);
    try {
      //   const res = await ApiPromise.create({
      //     provider: wsProvider,
      //     types: {
      //         Address: 'MultiAddress',
      //         LookupSource: 'MultiAddress'
      //     }
      //   });
      const res = await Nuchain.connectApi({
        provider: wsProvider
      });
      (<any>window).api = res;
      const url = nodes[(<any>res)._options.provider.__private_15_endpointIndex];
      send("log", `${url} wss connected success`);
      resolve(url);
    } catch (err) {
      send("log", `connect failed`);
      wsProvider.disconnect();
      resolve(null);
    }
  });
}

/**
 * Helper function to connect to known public testnet
 * this code for development purpose.
 */
async function testnetConnect() {
  const endpoint = "wss://testnet.nuchain.riset.tech";
  const connected = connect([endpoint]);
  console.log("Testnet Connected")
}

const test = async () => {
  // const props = await api.rpc.system.properties();
  // send("log", props);
};

const settings = {
  test,
  connect,
  testnetConnect,
  subscribeMessage,
  getNetworkConst,
  getNetworkProperties,
  // generate external links to polkascan/subscan/polkassembly...
  genLinks,
};

(<any>window).settings = settings;
(<any>window).keyring = keyring;
(<any>window).account = account;
(<any>window).staking = staking;
(<any>window).gov = gov;
(<any>window).walletConnect = wc;

export default settings;
