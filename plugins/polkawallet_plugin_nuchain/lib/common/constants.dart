import 'package:flutter/material.dart';

const int SECONDS_OF_DAY = 24 * 60 * 60; // seconds of one day
const int SECONDS_OF_YEAR = 365 * 24 * 60 * 60; // seconds of one year

const node_list_nuchain = [
  {
    'name': 'Nuchain (hosted by Rantai Nusantara)',
    'ss58': 42,
    'endpoint': 'wss://node-sg.nuchain.riset.tech',
  },
  {
    'name': 'Nuchain (hosted by Enco Indonesia)',
    'ss58': 42,
    'endpoint': 'wss://id01.nuchain.live',
  },
  // hanya untuk testing/development
  // comment out endpoint testnet ini ketika build untuk production
  {
    'name': 'Nuchain Testnet (hosted by Rantai Nusantara)',
    'ss58': 42,
    'endpoint': 'wss://testnet.nuchain.riset.tech',
  }
];
const node_list_polkadot = [
  {
    'name': 'Polkadot (Live, hosted by PatractLabs)',
    'ss58': 0,
    'endpoint': 'wss://polkadot.elara.patract.io',
  }
];

const home_nav_items = ['staking', 'governance'];

const MaterialColor nuchain_black = const MaterialColor(
  0xFF222222,
  const <int, Color>{
    50: const Color(0xFF555555),
    100: const Color(0xFF444444),
    200: const Color(0xFF444444),
    300: const Color(0xFF333333),
    400: const Color(0xFF333333),
    500: const Color(0xFF222222),
    600: const Color(0xFF111111),
    700: const Color(0xFF111111),
    800: const Color(0xFF000000),
    900: const Color(0xFF000000),
  },
);

const String network_name_nuchain = 'nuchain';
const String network_name_polkadot = 'polkadot';
