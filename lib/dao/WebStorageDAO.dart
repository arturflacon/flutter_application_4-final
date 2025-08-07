// lib/dao/web_storage_dao.dart
import 'dart:convert';
import 'dart:html' as html;
import '../dto/agendamentodto.dart';

class WebStorageDAO {
  static final WebStorageDAO _instance = WebStorageDAO._internal();
  factory WebStorageDAO() => _instance;
  WebStorageDAO._internal();

  static const String _storageKey = 'chacara_agendamentos';
  late List<AgendamentoDTO> _agendamentos;
  int _nextId = 1;

  // Inicializar dados do localStorage
  Future<void> _initializeFromStorage() async {
    try {
      final stored = html.window.localStorage[_storageKey];
      if (stored != null) {
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
      } else {
        _agendamentos = _getInitialData();
        await _saveToStorage();
      }
    } catch (e) {
      print('Erro ao carregar dados do localStorage: $e');
      _agendamentos = _getInitialData();
    }
  }

  // Salvar dados no localStorage
  Future<void> _saveToStorage() async {
    try {
      final jsonList = _agendamentos.map((a) => a.toMap()).toList();
      html.window.localStorage[_storageKey] = json.encode(jsonList);
    } catch (e) {
      print('Erro ao salvar dados no localStorage: $e');
    }
  }

  // Dados iniciais para demonstração
  List<AgendamentoDTO> _getInitialData() {
    return [
      AgendamentoDTO(
        id: 1,
        nomeCliente: 'João Silva',
        telefone: '(11) 99999-9999',
        email: 'joao@email.com',
        dataInicio: DateTime(2025, 6, 15),
        dataFim: DateTime(2025, 6, 16),
        quantidadePessoas: 20,
        valorTotal: 800.0,
        status: 'Confirmado',
        observacoes: 'Festa de aniversário',
      ),
      AgendamentoDTO(
        id: 2,
        nomeCliente: 'Maria Santos',
        telefone: '(11) 88888-8888',
        email: 'maria@email.com',
        dataInicio: DateTime(2025, 6, 22),
        dataFim: DateTime(2025, 6, 23),
        quantidadePessoas: 15,
        valorTotal: 600.0,
        status: 'Pendente',
        observacoes: 'Reunião familiar',
      ),
      AgendamentoDTO(
        id: 3,
        nomeCliente: 'Pedro Costa',
        telefone: '(11) 77777-7777',
        email: 'pedro@email.com',
        dataInicio: DateTime(2025, 7, 1),
        dataFim: DateTime(2025, 7, 2),
        quantidadePessoas: 30,
        valorTotal: 1000.0,
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
    return novoAgendamento;
  }

  // READ - Buscar todos os agendamentos
  Future<List<AgendamentoDTO>> buscarTodos() async {
    await _initializeFromStorage();
    return List.from(_agendamentos);
  }

  // READ - Buscar agendamento por ID
  Future<AgendamentoDTO?> buscarPorId(int id) async {
    await _initializeFromStorage();
    try {
      return _agendamentos.firstWhere((agendamento) => agendamento.id == id);
    } catch (e) {
      return null;
    }
  }

  // READ - Buscar agendamentos por status
  Future<List<AgendamentoDTO>> buscarPorStatus(String status) async {
    await _initializeFromStorage();
    return _agendamentos
        .where((agendamento) => agendamento.status == status)
        .toList();
  }

  // UPDATE - Atualizar agendamento
  Future<AgendamentoDTO?> atualizar(AgendamentoDTO agendamento) async {
    await _initializeFromStorage();

    final index = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) {
      _agendamentos[index] = agendamento;
      await _saveToStorage();
      return agendamento;
    }
    return null;
  }

  // UPDATE - Atualizar status do agendamento
  Future<AgendamentoDTO?> atualizarStatus(int id, String novoStatus) async {
    await _initializeFromStorage();

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
      return true;
    }
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
        return false;
      }
    }
    return true;
  }

  // Contar agendamentos por status
  Future<Map<String, int>> contarPorStatus() async {
    await _initializeFromStorage();

    final contadores = <String, int>{};
    for (final agendamento in _agendamentos) {
      contadores[agendamento.status] =
          (contadores[agendamento.status] ?? 0) + 1;
    }
    return contadores;
  }

  // Limpar todos os dados (útil para testes)
  Future<void> limparDados() async {
    _agendamentos.clear();
    _nextId = 1;
    html.window.localStorage.remove(_storageKey);
  }

  // Verificar se está executando no navegador
  static bool get isWebPlatform => identical(0, 0.0);
}
