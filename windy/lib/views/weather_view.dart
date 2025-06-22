import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:windy/models/weather_model.dart';
import 'package:windy/models/main_weather_model.dart';
import '../services/main_weather_service.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final _weatherService = WeatherService('bc6325bca3caef4fffb2a39d07ca2a56');
  MainWeatherModel? _mainWeather;
  WeatherModel? _weather;

  late Timer _weatherTimer;
  late Timer _clockTimer;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _weatherTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _fetchWeather(),
    );
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _weatherTimer.cancel();
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    try {
      String cityName = await _weatherService.getCurrentCity();

      if (cityName.isEmpty || cityName == 'Unknown') {
        _showSnackBar('Could not detect your city. Please enter it manually.');
        cityName = await _askForCityManually();
      }

      bool success = await _tryFetchingWeather(cityName);

      if (!success) {
        _showSnackBar('City not found. Please enter it manually.');
        String manualCity = await _askForCityManually();
        bool manualSuccess = await _tryFetchingWeather(manualCity);

        if (!manualSuccess) {
          _showSnackBar('Failed to fetch weather even after manual entry.');
        }
      }
    } catch (e) {
      _showSnackBar('Unexpected error occurred. Please try again.');
    }
  }

  Future<bool> _tryFetchingWeather(String cityName) async {
    try {
      final mainWeather = await _weatherService.getMainWeather(cityName);
      final weather = await _weatherService.getForecast(cityName);
      setState(() {
        _mainWeather = mainWeather;
        _weather = weather;
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> _askForCityManually() async {
    String enteredCity = '';

    while (enteredCity.trim().isEmpty) {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          String tempCity = '';
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Enter Your City',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'e.g., Cairo',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (value) => tempCity = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(''),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(tempCity.trim()),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF1E1E1E)),
                ),
              ),
            ],
          );
        },
      );

      enteredCity = result?.trim() ?? '';

      if (enteredCity.isEmpty) {
        _showSnackBar('City name is required to fetch weather.');
      }
    }

    return enteredCity;
  }

  void _showSnackBar(String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.redAccent,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(8),
      duration: const Duration(seconds: 7),
      flushbarPosition: FlushbarPosition.TOP,
      forwardAnimationCurve: Curves.easeOut,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body:
          _mainWeather == null
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        _mainWeather!.cityName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('h:mm a').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_mainWeather?.iconCode != null)
                        Image.network(
                          'https://openweathermap.org/img/wn/${_mainWeather!.iconCode}@2x.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      Text(
                        '${_mainWeather!.temprature.round()}°C',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _mainWeather!.description,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildInfoTile(
                            'Humidity',
                            '${_mainWeather!.humidity}%',
                          ),
                          _buildInfoTile(
                            'Pressure',
                            '${_mainWeather!.pressure} hPa',
                          ),
                          _buildInfoTile(
                            'Wind',
                            '${_mainWeather!.windSpeed} m/s',
                          ),
                          _buildInfoTile(
                            'Clouds',
                            '${_mainWeather!.cloudiness}%',
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      if (_weather != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            height: 280,
                            child: PageView.builder(
                              controller: PageController(
                                viewportFraction: 0.75,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _weather!.dailyForecasts.length,
                              itemBuilder: (context, index) {
                                final forecast =
                                    _weather!.dailyForecasts[index];
                                final displayDate = DateFormat(
                                  'MMMM d',
                                ).format(DateTime.parse(forecast.date));

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Card(
                                    color: const Color(0xFF1E1E1E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            forecast.dayName,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            displayDate,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Image.network(
                                            'https://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                                            height: 80,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Min: ${forecast.minTemp.round()}°C / Max: ${forecast.maxTemp.round()}°C',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            forecast.weatherDescription,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
