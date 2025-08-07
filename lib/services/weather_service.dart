import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "90d660709219d96c95761cf3baaee750";
  final String city = "Terra Rica, PR";
  final String country = "BR";

  Future<String> getWeatherForDate(DateTime date) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&lang=pt_br&units=metric");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final desc = data['weather'][0]['description'];
      final temp = data['main']['temp'];
      return "$desc, ${temp.toStringAsFixed(0)}°C";
    } else {
      return "Não disponível";
    }
  }
}
