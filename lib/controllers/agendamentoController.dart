// lib/controllers/agendamento_controller.dart
import 'package:flutter/material.dart';
import '../dao/agendamentodao.dart';
import '../dto/agendamentodto.dart';

class AgendamentoController extends ChangeNotifier {
  final AgendamentoDAO _dao = AgendamentoDAO();

  List<AgendamentoDTO> _agendamentos = [];
  bool _isLoading = false;
  String? _erro;

  // Getters
  List<AgendamentoDTO> get agendamentos => _agendamentos;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  // Carregar todos os agendamentos
  Future<void> carregarAgendamentos() async {
    _setLoading(true);
    try {
      _agendamentos = await _dao.buscarTodos();
      _erro = null;
      print('✅ Carregados ${_agendamentos.length} agendamentos');
    } catch (e) {
      _erro = 'Erro ao carregar agendamentos: $e';
      print('❌ $_erro');
    } finally {
      _setLoading(false);
    }
  }

  // Criar novo agendamento
  Future<bool> criarAgendamento(AgendamentoDTO agendamento) async {
    _setLoading(true);
    try {
      // Verificar disponibilidade
      final disponivel = await _dao.verificarDisponibilidade(
        agendamento.dataInicio,
        agendamento.dataFim,
      );

      if (!disponivel) {
        _erro = 'As datas selecionadas não estão disponíveis';
        return false;
      }

      final novoAgendamento = await _dao.criar(agendamento);
      print('✅ Agendamento criado com ID: ${novoAgendamento.id}');

      await carregarAgendamentos(); // Recarrega a lista
      _erro = null;
      return true;
    } catch (e) {
      _erro = 'Erro ao criar agendamento: $e';
      print('❌ $_erro');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar agendamento
  Future<bool> atualizarAgendamento(AgendamentoDTO agendamento) async {
    _setLoading(true);
    try {
      // Verificar disponibilidade (excluindo o próprio agendamento)
      final disponivel = await _dao.verificarDisponibilidade(
        agendamento.dataInicio,
        agendamento.dataFim,
        idExcluir: agendamento.id,
      );

      if (!disponivel) {
        _erro = 'As datas selecionadas não estão disponíveis';
        return false;
      }

      final resultado = await _dao.atualizar(agendamento);
      if (resultado != null) {
        await carregarAgendamentos(); // Recarrega a lista
        _erro = null;
        print('✅ Agendamento atualizado: ${agendamento.id}');
        return true;
      } else {
        _erro = 'Agendamento não encontrado';
        return false;
      }
    } catch (e) {
      _erro = 'Erro ao atualizar agendamento: $e';
      print('❌ $_erro');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar status do agendamento
  Future<bool> atualizarStatus(int id, String novoStatus) async {
    _setLoading(true);
    try {
      final resultado = await _dao.atualizarStatus(id, novoStatus);
      if (resultado != null) {
        await carregarAgendamentos(); // Recarrega a lista
        _erro = null;
        print('✅ Status atualizado para: $novoStatus');
        return true;
      } else {
        _erro = 'Agendamento não encontrado';
        return false;
      }
    } catch (e) {
      _erro = 'Erro ao atualizar status: $e';
      print('❌ $_erro');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Excluir agendamento
  Future<bool> excluirAgendamento(int id) async {
    _setLoading(true);
    try {
      final sucesso = await _dao.excluir(id);
      if (sucesso) {
        await carregarAgendamentos(); // Recarrega a lista
        _erro = null;
        print('✅ Agendamento excluído: $id');
        return true;
      } else {
        _erro = 'Agendamento não encontrado';
        return false;
      }
    } catch (e) {
      _erro = 'Erro ao excluir agendamento: $e';
      print('❌ $_erro');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Buscar agendamento por ID
  Future<AgendamentoDTO?> buscarPorId(int id) async {
    try {
      return await _dao.buscarPorId(id);
    } catch (e) {
      _erro = 'Erro ao buscar agendamento: $e';
      print('❌ $_erro');
      notifyListeners();
      return null;
    }
  }

  // Filtrar agendamentos por status
  Future<void> filtrarPorStatus(String status) async {
    _setLoading(true);
    try {
      _agendamentos = await _dao.buscarPorStatus(status);
      _erro = null;
      print('✅ Filtrados agendamentos por status: $status');
    } catch (e) {
      _erro = 'Erro ao filtrar agendamentos: $e';
      print('❌ $_erro');
    } finally {
      _setLoading(false);
    }
  }

  // Verificar disponibilidade de datas
  Future<bool> verificarDisponibilidade(DateTime inicio, DateTime fim,
      {int? idExcluir}) async {
    try {
      return await _dao.verificarDisponibilidade(inicio, fim,
          idExcluir: idExcluir);
    } catch (e) {
      _erro = 'Erro ao verificar disponibilidade: $e';
      print('❌ $_erro');
      notifyListeners();
      return false;
    }
  }

  // Obter estatísticas dos agendamentos
  Future<Map<String, int>> obterEstatisticas() async {
    try {
      final stats = await _dao.contarPorStatus();
      print('✅ Estatísticas obtidas: $stats');
      return stats;
    } catch (e) {
      _erro = 'Erro ao obter estatísticas: $e';
      print('❌ $_erro');
      notifyListeners();
      return {};
    }
  }

  // Calcular valor total do agendamento
  double calcularValorTotal(DateTime inicio, DateTime fim, double valorDiaria) {
    final dias = fim.difference(inicio).inDays + 1;
    final valorTotal = dias * valorDiaria;
    print(
        '📊 Calculando valor: $dias dias x R\$ $valorDiaria = R\$ $valorTotal');
    return valorTotal;
  }

  // Resetar lista (mostrar todos os agendamentos)
  Future<void> resetarFiltros() async {
    await carregarAgendamentos();
  }

  // Buscar agendamentos de hoje
  Future<void> buscarAgendamentosHoje() async {
    _setLoading(true);
    try {
      final todos = await _dao.buscarTodos();
      final hoje = DateTime.now();
      final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
      final fimHoje = inicioHoje.add(const Duration(days: 1));

      _agendamentos = todos.where((agendamento) {
        return agendamento.dataInicio.isBefore(fimHoje) &&
            agendamento.dataFim.isAfter(inicioHoje);
      }).toList();

      _erro = null;
      print('✅ Agendamentos de hoje: ${_agendamentos.length}');
    } catch (e) {
      _erro = 'Erro ao buscar agendamentos de hoje: $e';
      print('❌ $_erro');
    } finally {
      _setLoading(false);
    }
  }

  // Buscar próximos agendamentos (próximos 7 dias)
  Future<void> buscarProximosAgendamentos() async {
    _setLoading(true);
    try {
      final todos = await _dao.buscarTodos();
      final hoje = DateTime.now();
      final proximaSemana = hoje.add(const Duration(days: 7));

      _agendamentos = todos.where((agendamento) {
        return agendamento.dataInicio.isAfter(hoje) &&
            agendamento.dataInicio.isBefore(proximaSemana);
      }).toList();

      _erro = null;
      print('✅ Próximos agendamentos: ${_agendamentos.length}');
    } catch (e) {
      _erro = 'Erro ao buscar próximos agendamentos: $e';
      print('❌ $_erro');
    } finally {
      _setLoading(false);
    }
  }

  // Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  // Método privado para controlar loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Método para debug - contar total de agendamentos
  Future<int> contarTotalAgendamentos() async {
    try {
      final todos = await _dao.buscarTodos();
      print('📊 Total de agendamentos no banco: ${todos.length}');
      return todos.length;
    } catch (e) {
      print('❌ Erro ao contar agendamentos: $e');
      return 0;
    }
  }

  @override
  void dispose() {
    super.dispose();
    print('🔄 AgendamentoController disposed');
  }
}
