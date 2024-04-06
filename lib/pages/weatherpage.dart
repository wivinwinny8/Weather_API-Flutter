import 'package:app/pages/api_key.dart';
import 'package:app/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherFactory _wf = WeatherFactory(API_KEY);
  Weather? _weather;
  String? city;
  bool isLoading = true;
  bool isDarkMode = false;
  TextEditingController mycontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _getCurrentCity();
  }

  Future<void> _getCurrentCity() async {
    setState(() {
      isLoading = true; // Set loading to true when fetching starts
    });

    // Get location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle when location permission is permanently denied
      setState(() {
        isLoading = false; // Set loading to false when fetching ends
      });
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    // Get placemark from coordinates
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      city = placemarks.isNotEmpty ? placemarks[0].locality : "Unknown";
    });

    // Fetch weather data for the current city
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    if (city != null) {
      Weather weather = await _wf.currentWeatherByCityName(city!);
      setState(() {
        _weather = weather;
        isLoading = false; // Set loading to false when fetching ends
      });
    }
  }
  

  void changecity() {
    setState(() {
      _wf.currentWeatherByCityName(mycontroller.text).then((w) {
        setState(() {
          _weather = w;
          mycontroller.clear();
        });
      });
    });
  }

  String getAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/sunny.json';
    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return 'assets/sunny.json';
      case 'clouds':
        return 'assets/scatter_broke_clouds.json';
      case 'rain':
        return 'assets/rainy.json';
      case 'thunderstorm':
        return 'assets/thunderstorm.json';
      case 'snow':
        return 'assets/snow.json';
      case 'mist':
        return 'assets/mist.json';
      case 'drizzle':
        return 'assets/rainy.json';
      case 'haze':
        return 'assets/scatter_broke_clouds.json';
      case 'fog':
        return 'assets/scatter_broke_clouds.json';
      case 'smoke':
        return 'assets/scatter_broke_clouds.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: isDarkMode ? MyTheme.darkTheme : MyTheme.lightTheme,
      home: Scaffold(
        appBar: appbar(),
        drawer: drawer(),
        body: bodymethod(),
      ),
    );
  }

  AnimatedSwitcher bodymethod() {
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 700), // Adjust animation duration as needed
        child: isLoading
            ? Center(child: Lottie.asset('assets/fetch.json'))
            : ListView(
                key: Key('weather_data'),
                children: [
                  searchBar(),
                  cityName(),
                  Lottie.asset(getAnimation(_weather?.weatherMain)),
                  description(),
                  temperature(),
                  dateTime(),
                  min_max(),
                  data(),
                ],
              ),
      );
  }

  Drawer drawer() {
    return Drawer(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              DrawerHeader(child: Lottie.asset('assets/splash.json')),
              ListTile(
                leading: Icon(Icons.developer_mode),
                title: Text('wivinwinny8'),
              )
            ],
          ),
        ),
      );
  }

  AppBar appbar() {
    return AppBar(
        centerTitle: true,
        title: Text(
          'Weather',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            icon: isDarkMode ? Icon(Icons.nightlight) : Icon(Icons.sunny),
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
          ),
        ],
      );
  }

  Padding data() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 15,
            ),
            Text(
              "Wind Speed: ${_weather?.windSpeed?.toStringAsFixed(0)}m/s",
              style: TextStyle(
                  color: Colors.black,
                   fontSize: 20, fontFamily: 'Poppins'),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
              style: TextStyle(
                  color: Colors.black,
                   fontSize: 20, fontFamily: 'Poppins'),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              _weather?.sunrise != null
                  ? 'Sunrise: ' +
                      DateFormat('h:mm a').format(_weather!.sunrise!)
                  : "", // Format time to HH:mm
              style: TextStyle(
                  color: Colors.black,
                   fontSize: 20, fontFamily: 'Poppins'),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              _weather?.sunset != null
                  ? 'Sunset: ' + DateFormat('h:mm a').format(_weather!.sunset!)
                  : "", // Format time to HH:mm
              style: TextStyle(
                  color: Colors.black,
                   fontSize: 20, fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }

  Center min_max() {
    return Center(
      child: Text(
        '${_weather?.weatherMain ?? ""} ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}°C / ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}°C',
        style: TextStyle(fontSize: 30, fontFamily: 'Poppins'),
      ),
    );
  }

  Center dateTime() {
    return Center(
      child: Text(
        _weather?.date != null
            ? DateFormat('dd MMM yyyy').format(_weather!.date!)
            : "", // Format date to dd MMM yyyy
        style: TextStyle(fontSize: 20, fontFamily: 'Poppins'),
      ),
    );
  }

  Center temperature() => Center(
          child: Text(
        "${_weather?.temperature?.celsius?.toStringAsFixed(0)}°C",
        style: TextStyle(fontSize: 100, fontFamily: 'Poppins'),
      ));

  Center description() => Center(
          child: Text(
        _weather?.weatherDescription ?? "",
        style: TextStyle(fontSize: 20, fontFamily: 'Poppins'),
      ));

  Padding cityName() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10),
      child: Row(
        children: [
          Text(
            _weather?.areaName ?? "",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins'),
          ),
          Icon(
            Icons.location_on,
            size: 30,
          )
        ],
      ),
    );
  }

  Padding searchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: CupertinoSearchTextField(
        
        controller: mycontroller,
        placeholder: 'Search city',
        style: TextStyle(
             fontSize: 20, fontFamily: 'Poppins',color: Colors.grey[500]),
        prefixIcon: Icon(
          Icons.location_on,
          color: Colors.grey[500],
          size: 27,
        ),
        padding: EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 40),
        suffixIcon: Icon(
          color: Colors.grey[500],
          Icons.close,
          size: 27,
        ),
        onSubmitted: (value) {
          setState(() {
            _wf.currentWeatherByCityName(mycontroller.text).then((w) {
              setState(() {
                _weather = w;
                mycontroller.clear();
              });
            });
          });
        },
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(40),
          
        ),
      ),
    );
  }
}
