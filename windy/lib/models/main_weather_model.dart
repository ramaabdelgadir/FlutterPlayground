class MainWeatherModel {
  final String cityName;
  final double temprature;
  final String description;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int cloudiness;
  final String iconCode;

  MainWeatherModel({
    required this.cityName,
    required this.temprature,
    required this.description,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.cloudiness,
    required this.iconCode,
  });

  factory MainWeatherModel.fromJson(Map<String, dynamic> json) {
    final weatherData =
        (json['weather'] as List?)?.isNotEmpty == true
            ? json['weather'][0]
            : null;

    return MainWeatherModel(
      cityName: json['name'] ?? 'Unknown',
      temprature: (json['main']?['temp'] ?? 0).toDouble(),
      description: weatherData?['description'] ?? 'N/A',
      humidity: json['main']?['humidity'] ?? 0,
      pressure: json['main']?['pressure'] ?? 0,
      windSpeed: (json['wind']?['speed'] ?? 0).toDouble(),
      cloudiness: json['clouds']?['all'] ?? 0,
      iconCode: weatherData?['icon'] ?? '01d',
    );
  }
}
