// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/database/DatabaseTestView.dart';
import 'package:provider/provider.dart';
import 'controllers/agendamentocontroller.dart';
import 'controllers/chacaracontroller.dart';
import 'view/homeview.dart';
import 'view/agendamentoview.dart';
import 'view/novoagendamentoview.dart';
import 'view/detalhesagendamentoview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Iniciando aplicação da Chácara...');
  print('🌍 Plataforma: ${kIsWeb ? "Web (Navegador)" : "Mobile/Desktop"}');

  runApp(const ChacaraApp());
}

class ChacaraApp extends StatelessWidget {
  const ChacaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AgendamentoController()),
        ChangeNotifierProvider(create: (_) => ChacaraController()),
      ],
      child: MaterialApp(
        title: 'Agendamento Chácara',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const HomeView(),
        routes: {
          '/home': (context) => const HomeView(),
          '/agendamentos': (context) => const AgendamentosView(),
          '/novo-agendamento': (context) => const NovoAgendamentoView(),
          '/detalhes-agendamento': (context) => const DetalhesAgendamentoView(),
          '/database-test': (context) => const DatabaseTestView(),
        },
      ),
    );
  }
}
