// lib/view/database_test_view.dart
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/cliente.dart';

class DatabaseTestView extends StatefulWidget {
  const DatabaseTestView({super.key});

  @override
  State<DatabaseTestView> createState() => _DatabaseTestViewState();
}

class _DatabaseTestViewState extends State<DatabaseTestView> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<String> _resultados = [];

  @override
  void initState() {
    super.initState();
    _testarBancoDados();
  }

  Future<void> _testarBancoDados() async {
    setState(() {
      _resultados.clear();
    });

    try {
      _adicionarResultado('🔄 Iniciando testes do banco de dados...');

      // Teste 1: Verificar se o banco inicializa
      await _dbHelper.database;
      _adicionarResultado('✅ Banco de dados inicializado');

      // Teste 2: Verificar integridade
      await _dbHelper.verificarIntegridade();
      _adicionarResultado('✅ Integridade do banco verificada');

      // Teste 3: Testar inserção de cliente
      final cliente = Cliente(
        nome: 'Teste Cliente ${DateTime.now().millisecond}',
        telefone: '(11) 99999-9999',
        email: 'teste@email.com',
        cpf: '123.456.789-00',
        dataCadastro: DateTime.now(),
      );

      final clienteId = await _dbHelper.insertCliente(cliente);
      _adicionarResultado('✅ Cliente inserido com ID: $clienteId');

      // Teste 4: Buscar clientes
      final clientes = await _dbHelper.getClientes();
      _adicionarResultado('✅ ${clientes.length} clientes encontrados');

      // Teste 5: Verificar serviços padrão
      final servicos = await _dbHelper.getServicos();
      _adicionarResultado('✅ ${servicos.length} serviços encontrados');

      // Teste 6: Buscar agendamentos
      final agendamentos = await _dbHelper.getAgendamentos();
      _adicionarResultado('✅ ${agendamentos.length} agendamentos encontrados');

      _adicionarResultado('🎉 Todos os testes passaram!');
    } catch (e) {
      _adicionarResultado('❌ Erro nos testes: $e');
    }
  }

  void _adicionarResultado(String resultado) {
    setState(() {
      _resultados.add(resultado);
    });
    print(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste do Banco de Dados'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _testarBancoDados,
            icon: const Icon(Icons.refresh),
            tooltip: 'Executar testes novamente',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status dos Testes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta tela testa a conectividade e funcionalidade do banco de dados.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: _resultados.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _resultados.length,
                        itemBuilder: (context, index) {
                          final resultado = _resultados[index];
                          IconData icon;
                          Color color;

                          if (resultado.startsWith('✅')) {
                            icon = Icons.check_circle;
                            color = Colors.green;
                          } else if (resultado.startsWith('❌')) {
                            icon = Icons.error;
                            color = Colors.red;
                          } else if (resultado.startsWith('🔄')) {
                            icon = Icons.refresh;
                            color = Colors.blue;
                          } else if (resultado.startsWith('🎉')) {
                            icon = Icons.celebration;
                            color = Colors.purple;
                          } else {
                            icon = Icons.info;
                            color = Colors.grey;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  icon,
                                  color: color,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    resultado,
                                    style: TextStyle(
                                      color: color,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _testarBancoDados,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.play_arrow, color: Colors.white),
        tooltip: 'Executar testes',
      ),
    );
  }
}
