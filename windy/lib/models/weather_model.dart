import 'package:intl/intl.dart';

class DailyForecast {
  final String cityName;
  final String date;
  final String dayName;
  final double minTemp;
  final double maxTemp;
  final String weatherDescription;
  final String icon;

  DailyForecast({
    required this.cityName,
    required this.date,
    required this.dayName,
    required this.minTemp,
    required this.maxTemp,
    required this.weatherDescription,
    required this.icon,
  });
}

class WeatherModel {
  final List<DailyForecast> dailyForecasts;

  WeatherModel({required this.dailyForecasts});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> forecasts = json['list'] as List<dynamic>;
    final cityName = json['city']['name'] as String? ?? 'Unknown';

    final Map<String, List<dynamic>> grouped = {};
    for (var item in forecasts) {
      final dtTxt = item['dt_txt'] as String;
      final dateKey = dtTxt.split(' ')[0];
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }

    final List<DailyForecast> days = [];
    grouped.forEach((dateKey, items) {
      double minTemp = double.infinity;
      double maxTemp = -double.infinity;
      final Map<String, int> descCount = {};
      final Map<String, String> descIcon = {};

      for (var entry in items) {
        final temp = (entry['main']['temp'] as num?)?.toDouble() ?? 0.0;
        minTemp = temp < minTemp ? temp : minTemp;
        maxTemp = temp > maxTemp ? temp : maxTemp;

        final desc = entry['weather'][0]['description'] as String? ?? 'N/A';
        final ico = entry['weather'][0]['icon'] as String? ?? '01d';
        descCount[desc] = (descCount[desc] ?? 0) + 1;
        descIcon.putIfAbsent(desc, () => ico);
      }

      String commonDesc =
          descCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      final commonIcon = descIcon[commonDesc] ?? '01d';

      final dt = DateTime.parse('$dateKey 00:00:00');
      final dayName = DateFormat('EEEE').format(dt);

      days.add(
        DailyForecast(
          cityName: cityName,
          date: dateKey,
          dayName: dayName,
          minTemp: minTemp.isFinite ? minTemp : 0.0,
          maxTemp: maxTemp.isFinite ? maxTemp : 0.0,
          weatherDescription: commonDesc,
          icon: commonIcon,
        ),
      );
    });

    days.sort(
      (a, b) => DateTime.parse(a.date).compareTo(DateTime.parse(b.date)),
    );
    return WeatherModel(dailyForecasts: days.take(8).toList());
  }
}
