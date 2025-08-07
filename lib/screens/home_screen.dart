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
  String? _previsaoTempo;

  @override
  void initState() {
    super.initState();
    _carregarPrevisaoTempo();
  }

  void _carregarPrevisaoTempo() async {
    final weatherService = WeatherService();
    final previsao = await weatherService.getWeatherForDate(DateTime.now());
    setState(() {
      _previsaoTempo = previsao;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Chácara Booking',
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  CustomCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/clientes');
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 48, color: Color(0xFF2E7D32)),
                        SizedBox(height: 16),
                        Text('Clientes',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Gerenciar clientes',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  CustomCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/agendamentos');
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today,
                            size: 48, color: Color(0xFF2E7D32)),
                        SizedBox(height: 16),
                        Text('Agendamentos',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Ver e criar agendamentos',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  CustomCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/servicos');
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.room_service,
                            size: 48, color: Color(0xFF2E7D32)),
                        SizedBox(height: 16),
                        Text('Serviços',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Gerenciar serviços',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  CustomCard(
                    onTap: () {
                      Navigator.pushNamed(context, '/relatorios');
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assessment,
                            size: 48, color: Color(0xFF2E7D32)),
                        SizedBox(height: 16),
                        Text('Relatórios',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Visualizar relatórios',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_previsaoTempo != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      _previsaoTempo!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
}
