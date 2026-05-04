import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double? _latitude;
  double? _longitude;
  Weather? _weather;
  String? _weatherDescription;
  double? _temperature;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions denied');
        _loading = false;
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions permanently denied');
      _loading = false;
      return;
    }

    try {
      final LocationData location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = location.latitude;
        _longitude = location.longitude;
        _fetchWeather(location.latitude, location.longitude);
      });
    } catch (e) {
      _showSnackBar('Failed to get location: $e');
      _loading = false;
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&daily=weather_code&temperature_unit=fahrenheit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final daily = data['daily'];

        setState(() {
          _latitude = lat;
          _longitude = lon;
          _temperature = current['temperature_2m'];
          _weather = Weather(
            description: _weatherCodeToDescription(current['weather_code']),
            code: current['weather_code'],
          );
          _loading = false;
        });
      } else {
        _showSnackBar('Failed to fetch weather data');
        _loading = false;
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      _loading = false;
    }
  }

  String _weatherCodeToDescription(int wmoCode) {
    const codes = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Fog',
      48: 'Depositing rime fog',
      51: 'Drizzle',
      53: 'Drizzle',
      55: 'Drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      71: 'Slight snow',
      73: 'Moderate snow',
      75: 'Heavy snow',
      77: 'Snow grains',
      80: 'Rain showers',
      81: 'Rain showers',
      82: 'Violent showers',
      85: 'Snow showers',
      86: 'Snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with hail',
      99: 'Thunderstorm with heavy hail',
    };
    return codes[wmoCode] ?? 'Unknown';
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(title: const Text('Weather Reality Check')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_weather == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(title: const Text('Weather Reality Check')),
        body: Center(
          child: Card(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to fetch weather data. Make sure location services are enabled.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(title: const Text('Weather Reality Check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Temperature Display
            Center(
              child: Column(
                children: [
                  Icon(
                    _weatherIcon,
                    size: 80,
                    color: _getWeatherIconColor(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_temperature}°F',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weatherDescription!,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Outfit Recommendations
            Text(
              'Outfit Recommendations',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 12),
            _buildOutfitCard('Casual Comfort', _getCasualOutfit(_weatherDescription!)),
            const SizedBox(height: 12),
            _buildOutfitCard('Work Appropriate', _getWorkOutfit(_weatherDescription!)),
            const SizedBox(height: 12),
            _buildOutfitCard('Layering Option', _getLayeringOutfit()),
            const SizedBox(height: 24),
            // Tips
            Text(
              'Tips',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E4DC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: const Color(0xFFC9A688)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Wear breathable fabrics in warm weather and layers for cooler days.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates_outlined, color: const Color(0xFFC9A688)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Check the forecast before planning your outfit to stay comfortable.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitCard(String title, String items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFC9A688).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.style),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(items, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCasualOutfit(String weather) {
    if (weather.contains('Clear') || weather.contains('Sunny')) {
      return 'Light-colored top, denim shorts, sandals';
    } else if (weather.contains('Rain') || weather.contains('Drizzle')) {
      return 'Water-resistant jacket, comfortable pants, sneakers';
    } else if (weather.contains('Snow') || weather.contains('Freezing')) {
      return 'Warm sweater, coat, winter boots, scarf';
    } else {
      return 'Versatile top, jeans, comfortable shoes';
    }
  }

  String _getWorkOutfit(String weather) {
    if (weather.contains('Clear') || weather.contains('Sunny')) {
      return 'Blouse, tailored pants, closed-toe shoes';
    } else if (weather.contains('Rain')) {
      return 'Umbrella, trench coat, work-appropriate shoes';
    } else {
      return 'Professional outfit suitable for conditions';
    }
  }

  String _getLayeringOutfit() {
    return 'Light cardigan or jacket that can be added or removed as needed';
  }

  IconData get _weatherIcon {
    if (_weatherDescription?.contains('Clear') ?? false) return Icons.wb_sunny;
    if (_weatherDescription?.contains('Rain') ?? false) return Icons.water_drop;
    if (_weatherDescription?.contains('Snow') ?? false) return Icons.snowing;
    if (_weatherDescription?.contains('Thunder') ?? false) return Icons.lightning;
    if (_weatherDescription?.contains('Fog') ?? false) return Icons.straighten;
    return Icons.cloud;
  }

  Color _getWeatherIconColor() {
    if (_weatherDescription?.contains('Clear') ?? false) return Colors.orange;
    if (_weatherDescription?.contains('Rain') ?? false) return Colors.blue;
    if (_weatherDescription?.contains('Snow') ?? false) return Colors.grey;
    if (_weatherDescription?.contains('Thunder') ?? false) return Colors.purple;
    return Colors.orange.withOpacity(0.7);
  }
}

class Weather {
  final String description;
  final int code;

  Weather({required this.description, required this.code});
}
