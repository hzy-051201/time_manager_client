import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:time_manager_client/data/environment/env.dart';
import 'package:time_manager_client/data/repository/logger.dart';
import 'package:time_manager_client/data/types/type.dart';
import 'package:time_manager_client/helper/coordinate_helper.dart';

class NetworkAmap {
  // static final url = Uri.https("restapi.amap.com");
  static Future<LatLng?> queryPlace(String keywords, LatLng rawCenter) async {
    final center = CoordinateHelper.wgs84ToGcj02(rawCenter.$1, rawCenter.$2);
    // final url = Uri.https("restapi.amap.com", "/v5/place/around", {
    //   "key": Env.amapKey,
    //   "keywords": keywords,
    //   "location": "${center.$2.toStringAsFixed(6)},${center.$1.toStringAsFixed(6)}}",
    //   // "radius": "50000",
    // });

    final url = Uri.parse(
        "https://restapi.amap.com/v5/place/around?key=${Env.amapKey}&keywords=$keywords&location=${center.$2.toStringAsFixed(6)},${center.$1.toStringAsFixed(6)}");
    // final
    logger.d("request place: ${url.toString()}");

    final r = await http.get(url);
    if (r.statusCode != 200) return null;
    if (r.body.isEmpty) return null;

    final j = jsonDecode(r.body);
    logger.d(j);

    if (j["status"] != "1" || j["infocode"] != "10000") return null;
    final l = (j["pois"] as List).cast<Map<String, dynamic>>();
    // logger.d(l);
    l.sort((a, b) => CoordinateHelper.calculateDistance(rawCenter, _parseLocation(b["location"]))
        .compareTo(CoordinateHelper.calculateDistance(rawCenter, _parseLocation(a["location"]))));
    logger.d(l);

    final loc = l.lastOrNull?["location"];
    if (loc is! String) return null;

    final loc1 = loc.split(",");
    final lng = double.tryParse(loc1.first);
    final lat = double.tryParse(loc1.last);
    if (lat == null || lng == null) return null;

    return (lat, lng);
  }

  static LatLng _parseLocation(String l) {
    final loc1 = l.split(",");
    final lng = double.parse(loc1.first);
    final lat = double.parse(loc1.last);

    return (lat, lng);
  }
}
