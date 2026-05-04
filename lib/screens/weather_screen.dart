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
  Weather? _weather;
  double? _temperature;
  bool _coldOfficeMode = false;
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
      setState(() => _loading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions denied');
        setState(() => _loading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions permanently denied');
      setState(() => _loading = false);
      return;
    }

    try {
      final Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _fetchWeather(location.latitude, location.longitude);
    } catch (e) {
      _showSnackBar('Failed to get location: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&daily=weather_code&temperature_unit=fahrenheit'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>;
        final weatherCode = current['weather_code'] as int;
        final description = _weatherCodeToDescription(weatherCode);

        setState(() {
          _temperature = (current['temperature_2m'] as num).toDouble();
          _weather = Weather(
            description: description,
            code: weatherCode,
          );
          _loading = false;
        });
      } else {
        _showSnackBar('Failed to fetch weather data');
        setState(() => _loading = false);
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshWeather() async {
    setState(() => _loading = true);
    await _checkLocationPermission();
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Unable to fetch weather data. Make sure location services are enabled.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text('Weather Reality Check'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refreshWeather,
          ),
        ],
      ),
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
                    '${(_temperature ?? 0).round()}°F',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weather!.description,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildConditionSummary(),
            const SizedBox(height: 20),
            // Outfit Recommendations
            Text(
              'Outfit Recommendations',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                value: _coldOfficeMode,
                activeColor: const Color(0xFFC9A688),
                title: const Text('Cold office mode'),
                subtitle: const Text(
                    'Adds blazer/layering suggestions for strong indoor AC'),
                onChanged: (value) {
                  setState(() {
                    _coldOfficeMode = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            _buildOutfitCard('Casual Comfort', _getCasualOutfit()),
            const SizedBox(height: 12),
            _buildOutfitCard('Work Appropriate', _getWorkOutfit()),
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
                  ..._buildWeatherTips().map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.tips_and_updates_outlined,
                              color: Color(0xFFC9A688), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
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

  Widget _buildConditionSummary() {
    final tags = _buildConditionTags();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4DC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Context Rules Applied',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    backgroundColor: const Color(0xFFFAF9F6),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  List<String> _buildConditionTags() {
    final tags = <String>[];
    if (_isRainy) {
      tags.add('Rain: avoid sandals/open-toe');
    }
    if (_isHot) {
      tags.add('Hot: avoid wool/heavy knit');
    }
    if (_isCold || _isSnowy) {
      tags.add('Cold: include a warm layer');
    }
    if (_coldOfficeMode) {
      tags.add('Cold office: suggest blazer');
    }
    if (tags.isEmpty) {
      tags.add('No weather restrictions');
    }
    return tags;
  }

  String _getCasualOutfit() {
    final pieces = <String>[
      if (_isHot) 'Breathable top (cotton/linen)',
      if (!_isHot) 'Versatile top',
      if (_isHot) 'Light bottoms',
      if (!_isHot) 'Jeans or comfortable pants',
      if (_isRainy) 'Water-resistant jacket',
      if (_isRainy) 'Closed-toe shoes (avoid sandals)',
      if (_isSnowy) 'Insulated coat and boots',
      if (_isHot) 'No wool or heavy knit layers',
    ];
    return pieces.join(', ');
  }

  String _getWorkOutfit() {
    final pieces = <String>[
      if (_isHot) 'Lightweight office shirt',
      if (!_isHot) 'Structured shirt or blouse',
      'Tailored bottoms',
      if (_isRainy) 'Trench/umbrella and closed-toe shoes',
      if (_isCold || _isSnowy || _coldOfficeMode) 'Add blazer for warmth',
    ];
    return pieces.join(', ');
  }

  String _getLayeringOutfit() {
    if (_coldOfficeMode) {
      return 'Blazer or cardigan for cold office AC.';
    }
    if (_isCold || _isSnowy) {
      return 'Thermal base + sweater + coat for outdoor comfort.';
    }
    if (_isHot) {
      return 'Keep a very light layer for indoor spaces; skip heavy wool.';
    }
    return 'Light cardigan or jacket that can be added or removed as needed.';
  }

  List<String> _buildWeatherTips() {
    return [
      if (_isRainy) 'Carry a compact umbrella and choose water-safe footwear.',
      if (_isHot)
        'Prioritize breathable fabrics and reduce thick, heat-trapping layers.',
      if (_isCold || _isSnowy)
        'Use layered insulation to stay warm without overheating indoors.',
      if (_coldOfficeMode) 'Keep a blazer nearby for cold office temperatures.',
      'Check the forecast before heading out to avoid outfit mismatches.',
    ];
  }

  IconData get _weatherIcon {
    final description = _weather?.description ?? '';
    if (description.contains('Clear')) return Icons.wb_sunny;
    if (description.contains('Rain')) return Icons.water_drop;
    if (description.contains('Snow')) return Icons.snowing;
    if (description.contains('Thunder')) return Icons.bolt;
    if (description.contains('Fog')) return Icons.straighten;
    return Icons.cloud;
  }

  Color _getWeatherIconColor() {
    final description = _weather?.description ?? '';
    if (description.contains('Clear')) return Colors.orange;
    if (description.contains('Rain')) return Colors.blue;
    if (description.contains('Snow')) return Colors.grey;
    if (description.contains('Thunder')) return Colors.purple;
    return Colors.orange.withValues(alpha: 0.7);
  }

  int get _weatherCode => _weather?.code ?? -1;

  bool get _isRainy =>
      (_weatherCode >= 51 && _weatherCode <= 67) ||
      (_weatherCode >= 80 && _weatherCode <= 82);

  bool get _isSnowy =>
      (_weatherCode >= 71 && _weatherCode <= 77) ||
      _weatherCode == 85 ||
      _weatherCode == 86;

  bool get _isHot => (_temperature ?? 70) >= 82;

  bool get _isCold => (_temperature ?? 70) <= 55;
}

class Weather {
  final String description;
  final int code;

  Weather({required this.description, required this.code});
}
