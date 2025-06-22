import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:windy/models/weather_model.dart';
import 'package:windy/models/main_weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  static const _mainWeatherURL =
      'https://api.openweathermap.org/data/2.5/weather';
  static const _forecastURL =
      'https://api.openweathermap.org/data/2.5/forecast';
  final String apiKey;

  WeatherService(this.apiKey);

  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      final settings = LocationSettings(accuracy: LocationAccuracy.high);
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: settings,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      return placemarks.first.locality ?? 'Unknown';
    } catch (e) {
      print('Error in getCurrentCity: $e');
      return '';
    }
  }

  Future<MainWeatherModel> getMainWeather(String cityName) async {
    try {
      final uri = Uri.parse(
        '$_mainWeatherURL?q=$cityName&appid=$apiKey&units=metric',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return MainWeatherModel.fromJson(jsonDecode(response.body));
      } else {
        print('MainWeather error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load main weather');
      }
    } catch (e) {
      print('getMainWeather Exception: $e');
      rethrow;
    }
  }

  Future<WeatherModel> getForecast(String cityName) async {
    try {
      final uri = Uri.parse(
        '$_forecastURL?q=$cityName&appid=$apiKey&units=metric',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(jsonDecode(response.body));
      } else {
        print('Forecast error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load forecast');
      }
    } catch (e) {
      print('getForecast Exception: $e');
      rethrow;
    }
  }
}
