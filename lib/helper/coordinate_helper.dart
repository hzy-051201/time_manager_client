import 'dart:math';

import 'package:time_manager_client/data/types/type.dart';

class CoordinateHelper {
  static const double pi = 3.14159265358979324;
  static const double xPi = (pi * 3000.0) / 180.0;
  static const double a = 6378245.0;
  static const double ee = 0.00669342162296594323;

  static bool _outOfChina(double lat, double lon) {
    if (lon < 72.004 || lon > 137.8347) return true;
    if (lat < 0.8293 || lat > 55.8271) return true;
    return false;
  }

  static double _transformLat(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  static double _transformLon(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return ret;
  }

  // static LatLng wgs84ToGcj02(double wgslat, double wgslon) {
  static LatLng wgs84ToGcj02(double wgslat, double wgslon) {
    if (_outOfChina(wgslat, wgslon)) return (wgslat, wgslon);

    double dlat = _transformLat(wgslon - 105.0, wgslat - 35.0);
    double dlng = _transformLon(wgslon - 105.0, wgslat - 35.0);
    double radlat = wgslat / 180.0 * pi;
    double magic = 1 - ee * sin(radlat) * sin(radlat);
    double sqrtmagic = sqrt(magic);
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * pi);
    dlng = (dlng * 180.0) / (a / sqrtmagic * cos(radlat) * pi);
    double mglat = wgslat + dlat;
    double mglng = wgslon + dlng;
    return (mglat, mglng);
  }

  static double calculateDistance(LatLng p1, LatLng p2) {
    const int earthRadius = 6371; // 地球半径，单位为公里

    // 将经纬度从度数转换为弧度
    double radLat1 = _degreesToRadians(p1.$1);
    double radLon1 = _degreesToRadians(p1.$2);
    double radLat2 = _degreesToRadians(p2.$1);
    double radLon2 = _degreesToRadians(p2.$2);

    // 计算纬度和经度的差值
    double deltaLat = radLat2 - radLat1;
    double deltaLon = radLon2 - radLon1;

    // 使用 Haversine 公式计算距离
    double a = pow(sin(deltaLat / 2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(deltaLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // 计算最终的距离
    double distance = earthRadius * c;

    return distance;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}
