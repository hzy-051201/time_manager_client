import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:time_manager_client/data/environment/env.dart';
import 'package:time_manager_client/data/repository/logger.dart';

/// 天气服务类
/// 使用高德天气API获取天气信息
class NetworkWeather {
  // 高德天气API Key（需要选择"Web服务"类型）
  static String get _apiKey => Env.amapWeatherKey.isNotEmpty ? Env.amapWeatherKey : Env.amapKey;
  static const String _baseUrl = 'https://restapi.amap.com/v3/weather';

  /// 获取当前天气
  /// [city] 城市名称，如 "北京" 或 "上海"
  /// [cityCode] 城市编码（adcode），优先使用
  static Future<WeatherInfo?> getCurrentWeather(
    String city, {
    String? cityCode,
  }) async {
    try {
      String url;
      if (cityCode != null && cityCode.isNotEmpty) {
        // 使用城市编码查询
        url = '$_baseUrl/weatherInfo?city=$cityCode&key=$_apiKey&extensions=base';
      } else {
        // 使用城市名称查询
        url = '$_baseUrl/weatherInfo?city=$city&key=$_apiKey&extensions=base';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == '1' && data['lives'] != null && data['lives'].isNotEmpty) {
          final weatherData = data['lives'][0];
          logger.t('天气数据: $weatherData');
          return WeatherInfo.fromJson(weatherData, city);
        } else {
          logger.e('获取天气失败: ${data['info']}');
          return null;
        }
      } else {
        logger.e('获取天气失败: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      logger.e('天气请求异常: $e');
      return null;
    }
  }

  /// 根据经纬度获取天气
  /// [lat] 纬度
  /// [lon] 经度
  static Future<WeatherInfo?> getCurrentWeatherByLocation(
    double lat,
    double lon,
  ) async {
    try {
      // 先通过逆地理编码获取城市名称
      final regeoUrl = 'https://restapi.amap.com/v3/geocode/regeo?location=$lon,$lat&key=$_apiKey&extensions=base';
      
      final regeoResponse = await http.get(Uri.parse(regeoUrl));
      
      if (regeoResponse.statusCode != 200) {
        logger.e('逆地理编码失败: ${regeoResponse.statusCode}');
        return null;
      }
      
      final regeoData = jsonDecode(regeoResponse.body);
      if (regeoData['status'] != '1' || regeoData['regeocode'] == null) {
        logger.e('逆地理编码失败: ${regeoData['info']}');
        return null;
      }
      
      // 获取城市名称
      final addressComponent = regeoData['regeocode']['addressComponent'];
      String cityName = addressComponent['city'] ?? addressComponent['province'] ?? '';
      
      // 如果城市名称为空，使用省份
      if (cityName.isEmpty || cityName == '[]') {
        cityName = addressComponent['province'] ?? '北京';
      }
      
      // 使用城市名称查询天气
      return await getCurrentWeather(cityName);
      
    } catch (e) {
      logger.e('天气请求异常: $e');
      return null;
    }
  }

  /// 获取未来4天天气预报
  /// [city] 城市名称
  /// [cityCode] 城市编码（adcode），优先使用
  static Future<List<DailyWeather>> getForecast(
    String city, {
    String? cityCode,
  }) async {
    try {
      String url;
      if (cityCode != null && cityCode.isNotEmpty) {
        url = '$_baseUrl/weatherInfo?city=$cityCode&key=$_apiKey&extensions=all';
      } else {
        url = '$_baseUrl/weatherInfo?city=$city&key=$_apiKey&extensions=all';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == '1' && data['forecasts'] != null && data['forecasts'].isNotEmpty) {
          final forecastData = data['forecasts'][0];
          final List<dynamic> casts = forecastData['casts'] ?? [];
          logger.t('天气预报数据: ${casts.length}条');
          return casts.map((e) => DailyWeather.fromJson(e, city)).toList();
        } else {
          logger.e('获取天气预报失败: ${data['info']}');
          return [];
        }
      } else {
        logger.e('获取天气预报失败: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      logger.e('天气预报请求异常: $e');
      return [];
    }
  }

  /// 获取天气建议
  /// 基于天气状况给出出行建议
  static String getWeatherSuggestion(WeatherInfo weather) {
    final condition = weather.description;
    final temp = weather.temp;
    
    // 下雨天气
    if (condition.contains('雨')) {
      return '今天有雨，记得带伞！☔ 如果有户外活动，建议调整时间或地点。';
    }
    
    // 雪天
    if (condition.contains('雪')) {
      return '今天有雪，注意保暖和安全！❄️ 道路可能湿滑，出行请小心。';
    }
    
    // 雷暴
    if (condition.contains('雷') || condition.contains('暴')) {
      return '今天有雷暴天气，建议减少外出活动！⚡ 如需出行，请注意安全。';
    }
    
    // 雾霾
    if (condition.contains('雾') || condition.contains('霾') || condition.contains('沙')) {
      return '今天有雾霾，外出请戴口罩！😷 开车请注意安全，减速慢行。';
    }
    
    // 晴天
    if (condition.contains('晴')) {
      if (temp > 30) {
        return '今天天气晴朗但温度较高，注意防晒和补水！☀️ 户外活动建议避开正午。';
      } else if (temp < 10) {
        return '今天天气晴朗但温度较低，注意保暖！🧣 适合户外运动。';
      } else {
        return '今天天气晴朗，温度适宜，适合户外活动！🌤️ 享受美好的一天吧！';
      }
    }
    
    // 多云/阴天
    if (condition.contains('云') || condition.contains('阴')) {
      return '今天${condition}，温度适中，适合出行！☁️ 没有强烈的阳光，很适合散步。';
    }
    
    // 默认建议
    return '今天天气状况：${weather.description}，温度：${weather.temp.toStringAsFixed(1)}℃🌡️ 请根据实际情况安排活动。';
  }
}

/// 天气信息类
class WeatherInfo {
  final String main;        // 主天气状况（如 "晴", "雨", "雪"）
  final String description; // 天气描述
  final double temp;        // 当前温度（摄氏度）
  final double feelsLike;   // 体感温度
  final double tempMin;     // 最低温度
  final double tempMax;     // 最高温度
  final int humidity;       // 湿度
  final double windSpeed;   // 风速（米/秒）
  final String windDirection; // 风向
  final String city;        // 城市名称
  final int timestamp;      // 时间戳
  final String reportTime;  // 报告时间

  WeatherInfo({
    required this.main,
    required this.description,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    this.windDirection = '',
    required this.city,
    required this.timestamp,
    this.reportTime = '',
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json, String cityName) {
    final weather = json['weather'] ?? '';
    final tempStr = json['temperature'] ?? '0';
    final humidityStr = json['humidity'] ?? '0';
    final windPower = json['windpower'] ?? '0';
    final windDir = json['winddirection'] ?? '';

    // 解析温度
    double temp = 0.0;
    try {
      temp = double.parse(tempStr.toString());
    } catch (e) {
      temp = 0.0;
    }

    // 解析湿度
    int humidity = 0;
    try {
      humidity = int.parse(humidityStr.toString());
    } catch (e) {
      humidity = 0;
    }

    // 解析风力
    double windSpeed = 0.0;
    try {
      final powerStr = windPower.toString().replaceAll(RegExp(r'[^\d.]'), '');
      if (powerStr.contains('-')) {
        // 如 "≤3" 取最大值
        final parts = powerStr.split('-');
        windSpeed = double.parse(parts.last.trim());
      } else if (powerStr.contains('>')) {
        // 如 ">3"
        windSpeed = double.parse(powerStr.replaceAll('>', '').trim());
      } else if (powerStr.isNotEmpty) {
        windSpeed = double.parse(powerStr);
      }
    } catch (e) {
      windSpeed = 0.0;
    }

    // 解析报告时间
    int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (json['reporttime'] != null) {
      try {
        final dt = DateTime.parse(json['reporttime']);
        timestamp = dt.millisecondsSinceEpoch ~/ 1000;
      } catch (e) {}
    }

    return WeatherInfo(
      main: _convertWeatherToMain(weather),
      description: weather,
      temp: temp,
      feelsLike: temp, // 高德API不提供体感温度，使用实际温度
      tempMin: temp - 5, // 估算最低温度
      tempMax: temp + 5, // 估算最高温度
      humidity: humidity,
      windSpeed: windSpeed,
      windDirection: windDir,
      city: cityName,
      timestamp: timestamp,
      reportTime: json['reporttime'] ?? '',
    );
  }

  /// 将天气描述转换为标准格式
  static String _convertWeatherToMain(String weather) {
    final w = weather.toLowerCase();
    if (w.contains('雨')) return 'Rain';
    if (w.contains('雪')) return 'Snow';
    if (w.contains('雷') || w.contains('暴')) return 'Thunderstorm';
    if (w.contains('雾') || w.contains('霾') || w.contains('沙')) return 'Mist';
    if (w.contains('云') || w.contains('阴')) return 'Clouds';
    if (w.contains('晴')) return 'Clear';
    return 'Clear';
  }

  /// 获取天气图标（emoji）
  String getWeatherIcon() {
    final condition = main.toLowerCase();
    
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return '🌧️';
    }
    if (condition.contains('thunderstorm')) {
      return '⛈️';
    }
    if (condition.contains('snow')) {
      return '❄️';
    }
    if (condition.contains('mist') || condition.contains('fog') || condition.contains('haze')) {
      return '🌫️';
    }
    if (condition.contains('cloud')) {
      return '☁️';
    }
    if (condition.contains('clear')) {
      return '☀️';
    }
    
    return '🌡️';
  }

  @override
  String toString() {
    return 'WeatherInfo(city: $city, temp: ${temp.toStringAsFixed(1)}℃, condition: $description)';
  }
}

/// 每日天气预报
class DailyWeather {
  final DateTime dateTime;
  final String main;
  final String description;
  final double temp;     // 白天温度
  final double tempMin;  // 夜间温度
  final double tempMax;  // 白天温度
  final String week;     // 星期
  final String dayWeather;   // 白天天气
  final String nightWeather; // 夜间天气

  DailyWeather({
    required this.dateTime,
    required this.main,
    required this.description,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    this.week = '',
    this.dayWeather = '',
    this.nightWeather = '',
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json, String cityName) {
    final dateStr = json['date'] ?? '';
    final dayTempStr = json['daytemp'] ?? '0';
    final nightTempStr = json['nighttemp'] ?? '0';
    final dayWeather = json['dayweather'] ?? '';
    final nightWeather = json['nightweather'] ?? '';

    // 解析日期
    DateTime dateTime = DateTime.now();
    try {
      dateTime = DateTime.parse(dateStr);
    } catch (e) {}

    // 解析温度
    double dayTemp = 0.0;
    double nightTemp = 0.0;
    try {
      dayTemp = double.parse(dayTempStr.toString());
      nightTemp = double.parse(nightTempStr.toString());
    } catch (e) {
      dayTemp = 0.0;
      nightTemp = 0.0;
    }

    // 使用白天天气作为主要天气
    final mainWeather = WeatherInfo._convertWeatherToMain(dayWeather);
    final description = '$dayWeather转$nightWeather';

    return DailyWeather(
      dateTime: dateTime,
      main: mainWeather,
      description: description,
      temp: dayTemp,
      tempMin: nightTemp,
      tempMax: dayTemp,
      week: json['week'] ?? '',
      dayWeather: dayWeather,
      nightWeather: nightWeather,
    );
  }

  String getWeatherIcon() {
    final condition = main.toLowerCase();
    
    if (condition.contains('rain') || condition.contains('drizzle')) {
      return '🌧️';
    }
    if (condition.contains('thunderstorm')) {
      return '⛈️';
    }
    if (condition.contains('snow')) {
      return '❄️';
    }
    if (condition.contains('mist') || condition.contains('fog') || condition.contains('haze')) {
      return '🌫️';
    }
    if (condition.contains('cloud')) {
      return '☁️';
    }
    if (condition.contains('clear')) {
      return '☀️';
    }
    
    return '🌡️';
  }
}