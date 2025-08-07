import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chacaracontroller.dart';
import '../services/weather_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ChacaraController>();
      controller.carregarInformacoes().then((_) {
        if (controller.chacara != null) {
          _loadWeather(controller.chacara!.cidade);
        }
      });
    });
  }

  Future<void> _loadWeather(String cidade) async {
    try {
      var data = await WeatherService().getWeather(cidade);
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    } catch (_) {
      setState(() {
        _weatherData = null;
        _isLoadingWeather = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chácara Nossa Senhora De Lurdes'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/database-test'),
            icon: const Icon(Icons.storage),
            tooltip: 'Testar Banco de Dados',
          ),
        ],
      ),
      body: Consumer<ChacaraController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.erro != null) {
            return _buildErro(controller);
          }

          final chacara = controller.chacara;
          if (chacara == null) {
            return _buildSemDados();
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardPrincipal(chacara),
                const SizedBox(height: 24),
                _buildBotoes(),
                const SizedBox(height: 24),
                Text(
                  'Comodidades Disponíveis:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildComodidades(chacara),
                const SizedBox(height: 24),
                Text(
                  'Previsão do Tempo:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _isLoadingWeather
                    ? const Center(child: CircularProgressIndicator())
                    : _weatherData != null
                        ? _buildWeatherCard()
                        : const Text(
                            'Não foi possível carregar o clima no momento.'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  Widget _buildComodidades(chacara) {
    return Expanded(
      child: GridView.builder(
        itemCount: chacara.comodidades.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final comodidade = chacara.comodidades[index];
          return Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _getComodidadeIcon(comodidade),
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      comodidade,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardPrincipal(chacara) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.home_work, color: Colors.green[700], size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chacara.nome,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chacara.endereco),
                    Text(chacara.cidade),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.people,
                    title: 'Capacidade',
                    value: '${chacara.capacidadeMaxima} pessoas',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.attach_money,
                    title: 'Diária',
                    value: 'R\$ ${chacara.valorDiaria.toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotoes() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/agendamentos'),
            icon: const Icon(Icons.calendar_today),
            label: const Text('Ver Agendamentos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/novo-agendamento'),
            icon: const Icon(Icons.add),
            label: const Text('Novo Agendamento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getComodidadeIcon(String comodidade) {
    switch (comodidade.toLowerCase()) {
      case 'piscina':
        return Icons.pool;
      case 'churrasqueira':
        return Icons.outdoor_grill;
      case 'salão de festas':
        return Icons.celebration;
      case 'riacho':
        return Icons.water;
      case 'área verde':
        return Icons.nature;
      case 'estacionamento':
        return Icons.local_parking;
      default:
        return Icons.check_circle;
    }
  }

  Widget _buildErro(ChacaraController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erro: ${controller.erro}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.carregarInformacoes(),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildSemDados() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Nenhuma informação encontrada'),
        ],
      ),
    );
  }
}
