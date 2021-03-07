

class SafeGetter {
  static String getStr(dynamic obj){
    return obj is List ? (obj[0] == null ? "" : obj[0]) : (obj == null ? "" : obj);
  }

  static int getInt(dynamic obj, int dflt){
    return obj is List ? obj[0] : (obj ?? dflt);
  }
}