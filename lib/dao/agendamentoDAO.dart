// lib/dao/agendamento_dao.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../dto/agendamentodto.dart';

class AgendamentoDAO {
  static final AgendamentoDAO _instance = AgendamentoDAO._internal();
  factory AgendamentoDAO() => _instance;
  AgendamentoDAO._internal();

  static const String _storageKey = 'chacara_agendamentos';
  List<AgendamentoDTO> _agendamentos = [];
  int _nextId = 1;
  bool _initialized = false;

  // Inicializar dados da persistência
  Future<void> _initializeFromStorage() async {
    if (_initialized) return;

    try {
      String? stored = await _getStoredData();

      if (stored != null && stored.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(stored);
        _agendamentos =
            jsonList.map((json) => AgendamentoDTO.fromMap(json)).toList();

        // Encontrar o próximo ID disponível
        if (_agendamentos.isNotEmpty) {
          _nextId = _agendamentos
                  .map((a) => a.id ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;
        }

        print(
            '✅ Carregados ${_agendamentos.length} agendamentos da persistência');
      } else {
        _agendamentos = _getInitialData();
        await _saveToStorage();
        print('✅ Dados iniciais criados: ${_agendamentos.length} agendamentos');
      }

      _initialized = true;
    } catch (e) {
      print('⚠️ Erro ao carregar dados: $e - usando dados iniciais');
      _agendamentos = _getInitialData();
      _initialized = true;
    }
  }

  // Método para obter dados salvos (específico para cada plataforma)
  Future<String?> _getStoredData() async {
    if (kIsWeb) {
      try {
        // Para Web: simular localStorage usando memória estática
        return _webStorage[_storageKey];
      } catch (e) {
        print('Erro ao acessar storage web: $e');
        return null;
      }
    } else {
      try {
        // Para Mobile: tentar usar SharedPreferences
        // Se não estiver disponível, usar armazenamento em memória
        return _mobileStorage[_storageKey];
      } catch (e) {
        print('Erro ao acessar storage mobile: $e');
        return null;
      }
    }
  }

  // Storage estático para simular persistência
  static final Map<String, String> _webStorage = {};
  static final Map<String, String> _mobileStorage = {};

  // Salvar dados na persistência
  Future<void> _saveToStorage() async {
    try {
      final jsonList = _agendamentos.map((a) => a.toMap()).toList();
      final jsonString = json.encode(jsonList);

      if (kIsWeb) {
        _webStorage[_storageKey] = jsonString;
        print('💾 Dados salvos no storage web');
      } else {
        _mobileStorage[_storageKey] = jsonString;
        print('💾 Dados salvos no storage mobile');
      }
    } catch (e) {
      print('Erro ao salvar dados: $e');
    }
  }

  // Dados iniciais para demonstração
  List<AgendamentoDTO> _getInitialData() {
    _nextId = 4; // Próximo ID após os dados iniciais

    final now = DateTime.now();
    return [
      AgendamentoDTO(
        id: 1,
        nomeCliente: 'João Silva',
        telefone: '(11) 99999-9999',
        email: 'joao@email.com',
        dataInicio: now.add(const Duration(days: 10)),
        dataFim: now.add(const Duration(days: 11)),
        quantidadePessoas: 20,
        valorTotal: 900.0,
        status: 'Confirmado',
        observacoes: 'Festa de aniversário',
      ),
      AgendamentoDTO(
        id: 2,
        nomeCliente: 'Maria Santos',
        telefone: '(11) 88888-8888',
        email: 'maria@email.com',
        dataInicio: now.add(const Duration(days: 20)),
        dataFim: now.add(const Duration(days: 21)),
        quantidadePessoas: 15,
        valorTotal: 900.0,
        status: 'Pendente',
        observacoes: 'Reunião familiar',
      ),
      AgendamentoDTO(
        id: 3,
        nomeCliente: 'Pedro Costa',
        telefone: '(11) 77777-7777',
        email: 'pedro@email.com',
        dataInicio: now.add(const Duration(days: 30)),
        dataFim: now.add(const Duration(days: 31)),
        quantidadePessoas: 30,
        valorTotal: 900.0,
        status: 'Confirmado',
        observacoes: 'Evento corporativo',
      ),
    ];
  }

  // CREATE - Criar novo agendamento
  Future<AgendamentoDTO> criar(AgendamentoDTO agendamento) async {
    await _initializeFromStorage();

    final novoAgendamento = agendamento.copyWith(id: _nextId++);
    _agendamentos.add(novoAgendamento);

    await _saveToStorage();
    print('✅ Agendamento criado: ID ${novoAgendamento.id}');
    return novoAgendamento;
  }

  // READ - Buscar todos os agendamentos
  Future<List<AgendamentoDTO>> buscarTodos() async {
    await _initializeFromStorage();
    print('📊 Retornando ${_agendamentos.length} agendamentos');
    return List.from(_agendamentos);
  }

  // READ - Buscar agendamento por ID
  Future<AgendamentoDTO?> buscarPorId(int id) async {
    await _initializeFromStorage();
    try {
      final agendamento = _agendamentos.firstWhere((a) => a.id == id);
      print('✅ Agendamento encontrado: ID $id');
      return agendamento;
    } catch (e) {
      print('❌ Agendamento não encontrado: ID $id');
      return null;
    }
  }

  // READ - Buscar agendamentos por status
  Future<List<AgendamentoDTO>> buscarPorStatus(String status) async {
    await _initializeFromStorage();
    final filtrados = _agendamentos
        .where((agendamento) =>
            agendamento.status.toLowerCase() == status.toLowerCase())
        .toList();
    print('📊 ${filtrados.length} agendamentos com status: $status');
    return filtrados;
  }

  // UPDATE - Atualizar agendamento
  Future<AgendamentoDTO?> atualizar(AgendamentoDTO agendamento) async {
    await _initializeFromStorage();

    final index = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) {
      _agendamentos[index] = agendamento;
      await _saveToStorage();
      print('✅ Agendamento atualizado: ID ${agendamento.id}');
      return agendamento;
    }
    print('❌ Agendamento não encontrado para atualizar: ID ${agendamento.id}');
    return null;
  }

  // UPDATE - Atualizar status do agendamento
  Future<AgendamentoDTO?> atualizarStatus(int id, String novoStatus) async {
    final agendamento = await buscarPorId(id);
    if (agendamento != null) {
      final agendamentoAtualizado = agendamento.copyWith(status: novoStatus);
      return await atualizar(agendamentoAtualizado);
    }
    return null;
  }

  // DELETE - Excluir agendamento
  Future<bool> excluir(int id) async {
    await _initializeFromStorage();

    final index =
        _agendamentos.indexWhere((agendamento) => agendamento.id == id);
    if (index != -1) {
      _agendamentos.removeAt(index);
      await _saveToStorage();
      print('✅ Agendamento excluído: ID $id');
      return true;
    }
    print('❌ Agendamento não encontrado para exclusão: ID $id');
    return false;
  }

  // Verificar disponibilidade de datas
  Future<bool> verificarDisponibilidade(DateTime inicio, DateTime fim,
      {int? idExcluir}) async {
    await _initializeFromStorage();

    for (final agendamento in _agendamentos) {
      // Pula o agendamento atual se estiver editando
      if (idExcluir != null && agendamento.id == idExcluir) continue;

      // Verifica se há conflito de datas
      if (agendamento.dataInicio.isBefore(fim.add(const Duration(days: 1))) &&
          agendamento.dataFim
              .isAfter(inicio.subtract(const Duration(days: 1)))) {
        print(
            '❌ Conflito de datas encontrado com agendamento ID: ${agendamento.id}');
        return false;
      }
    }
    print('✅ Datas disponíveis para agendamento');
    return true;
  }

  // Contar agendamentos por status
  Future<Map<String, int>> contarPorStatus() async {
    await _initializeFromStorage();

    final contadores = <String, int>{};
    for (final agendamento in _agendamentos) {
      final status = agendamento.status;
      contadores[status] = (contadores[status] ?? 0) + 1;
    }
    print('📊 Estatísticas por status: $contadores');
    return contadores;
  }

  // Limpar todos os dados (útil para testes)
  Future<void> limparDados() async {
    _agendamentos.clear();
    _nextId = 1;
    _initialized = false;

    if (kIsWeb) {
      _webStorage.clear();
    } else {
      _mobileStorage.clear();
    }

    print('🧹 Todos os dados foram limpos');
  }

  // Reset para dados iniciais
  Future<void> resetarParaDadosIniciais() async {
    await limparDados();
    _agendamentos = _getInitialData();
    _initialized = true;
    await _saveToStorage();
    print('🔄 Dados resetados para valores iniciais');
  }

  // Método para debug
  Future<void> logEstadoAtual() async {
    await _initializeFromStorage();
    print('📊 Estado atual do DAO:');
    print('   - Total de agendamentos: ${_agendamentos.length}');
    print('   - Próximo ID: $_nextId');
    print('   - Inicializado: $_initialized');
    print('   - Plataforma: ${kIsWeb ? "Web" : "Mobile"}');

    // Log dos agendamentos
    for (final agendamento in _agendamentos) {
      print(
          '   - ID: ${agendamento.id}, Cliente: ${agendamento.nomeCliente}, Status: ${agendamento.status}');
    }
  }

  // Método para verificar se há dados persistidos
  Future<bool> temDadosPersistidos() async {
    final stored = await _getStoredData();
    return stored != null && stored.isNotEmpty;
  }
}
