import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_card.dart';
import 'package:flutter_application_4/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      var data = await WeatherService().getWeather("Terra Rica");
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _weatherData = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Chácara Nossa Senhora De Lurdes"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chácara Nossa Senhora De Lurdes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Frente aos 3 Morrinhos\nTerra Rica - PR",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: const [
                            Icon(Icons.group, color: Colors.blue),
                            SizedBox(height: 4),
                            Text("Capacidade"),
                            Text(
                              "50 pessoas",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: const [
                            Icon(Icons.attach_money, color: Colors.green),
                            SizedBox(height: 4),
                            Text("Diária"),
                            Text(
                              "R\$ 450.00",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Ver Agendamentos"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Novo Agendamento"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              "Comodidades Disponíveis:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _ComodidadeItem(Icons.pool, "Piscina"),
                _ComodidadeItem(Icons.outdoor_grill, "Churrasqueira"),
                _ComodidadeItem(Icons.celebration, "Salão de festas"),
                _ComodidadeItem(Icons.water, "Riacho"),
                _ComodidadeItem(Icons.park, "Área verde"),
                _ComodidadeItem(Icons.local_parking, "Estacionamento"),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              "Previsão do Tempo:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _weatherData != null
                    ? Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.network(
                                    "https://openweathermap.org/img/wn/${_weatherData!['icon']}@2x.png",
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "${_weatherData!['temp']}°C",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _weatherData!['description'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const Text(
                        "Não foi possível carregar o clima no momento."),
          ],
        ),
      ),
    );
  }
}

class _ComodidadeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ComodidadeItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: Colors.green),
      label: Text(label),
      backgroundColor: Colors.grey[100],
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
