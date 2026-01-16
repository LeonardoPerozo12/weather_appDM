import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/screen/forecast_screen.dart';

import '../services/weather_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //instanciar la clase que nos ofrece el servicio
  dynamic _currentWeather;
  String city = "Madrid";
  final TextEditingController _cityController = TextEditingController();

  //metodo para traer la informacion del clima
  final WeatherServices _weatherServices = WeatherServices();

  Future<void> _fetchForecastData() async {
    try {
      final weatherData = await _weatherServices.fetchCurrentWeather(city);
      setState(() {
        _currentWeather = weatherData;
      });
    } catch (e) {
      //
    }
  }


  void _showCitySelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter city name'),
          content: TextField(
            controller: _cityController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter city name"),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Search'),
              onPressed: () {
                if (_cityController.text.isNotEmpty) {
                  setState(() {
                    city = _cityController.text;
                  });
                  _fetchForecastData();
                }
                _cityController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _fetchForecastData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentWeather == null
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    Color(0xff2d4bb0),
                    Color.fromARGB(255, 194, 188, 120),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: AlignmentDirectional.bottomCenter,
                  colors: [
                    Color(0xff2d4bb0),
                    Color.fromARGB(255, 194, 188, 120),
                  ],
                ),
              ),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: _showCitySelectionDialog,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        city,
                        style: GoogleFonts.lato(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Image.network(
                          'https:${_currentWeather!['current']['condition']['icon']}',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          '${_currentWeather!['current']['temp_c'].round()} ℃',
                          style: GoogleFonts.lato(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_currentWeather!['current']['condition']['text']}',
                          style: GoogleFonts.lato(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Max: ${_currentWeather!['current']['temp_c'] + 5} ℃', // Placeholder logic as current API might not give daily max/min in current endpoint
                              style: GoogleFonts.lato(
                                fontSize: 22,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Min: ${_currentWeather!['current']['temp_c'] - 5} ℃', // Placeholder logic
                              style: GoogleFonts.lato(
                                fontSize: 22,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeatherDetails(
                        "Sunrise",
                        Icons.wb_sunny,
                        "6:00 AM",
                      ),
                      _buildWeatherDetails(
                        "Sunset",
                        Icons.brightness_3,
                        "6:00 PM",
                      ),
                    ],
                  ),
                  const SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWeatherDetails(
                        "Humidity",
                        Icons.water_drop,
                        '${_currentWeather!['current']['humidity']}%',
                      ),
                      _buildWeatherDetails(
                        "Wind (KPH)",
                        Icons.air,
                        "${_currentWeather!['current']['wind_kph']}",
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1a2344),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ForecastScreen(city: city);
                            },
                          ),
                        );
                      },
                      child: Text(
                        'Next 7 days Forecast',
                        style: GoogleFonts.lato(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

//Metodo para construir los widgets del detalle del clima
Widget _buildWeatherDetails(String label, IconData icon, dynamic value) {
  return ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              const Color(0xff1a2344).withAlpha(128),
              const Color(0xff1a2344).withAlpha(51),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value is String ? value : value.toString(),
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
