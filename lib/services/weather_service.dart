import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = "90d660709219d96c95761cf3baaee750";
  static const String _baseUrl =
      "https://api.openweathermap.org/data/2.5/weather";

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url =
        Uri.parse("$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=pt_br");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return {
        "temp": data["main"]["temp"].toString(),
        "description": data["weather"][0]["description"],
        "icon": data["weather"][0]["icon"]
      };
    } else {
      throw Exception("Erro ao buscar dados do clima");
    }
  }
}
