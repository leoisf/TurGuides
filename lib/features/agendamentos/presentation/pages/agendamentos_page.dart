import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/agendamento.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import '../../../turista/presentation/pages/buscar_guias_page.dart';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key});

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  final ApiService _api = ApiService();
  List<Agendamento> _agendamentos = [];
  bool _isLoading = true;
  String _filtroStatus = 'todos';

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) {
        debugPrint('❌ Usuário não autenticado');
        setState(() => _isLoading = false);
        return;
      }

      debugPrint('📋 Carregando agendamentos do turista ID: ${user.id}');
      final endpoint = '${AppConfig.agendamentos}/turista/${user.id}';
      debugPrint('🌐 Endpoint: ${AppConfig.baseUrl}$endpoint');
      
      final response = await _api.get(endpoint, requiresAuth: true);
      debugPrint('✅ Resposta recebida');
      
      if (response['success']) {
        final List<dynamic> data = response['data'] ?? [];
        debugPrint('📊 Total de agendamentos: ${data.length}');
        
        if (mounted) {
          setState(() {
            _agendamentos = data.map((json) {
              // Adicionar informações do guia ao agendamento
              return Agendamento.fromJson({
                ...json,
                'guia_nome': json['guia_nome'] ?? json['Guia']?['nome'],
                'guia_telefone': json['guia_telefone'] ?? json['Guia']?['telefone'],
              });
            }).toList();
            // Ordenar por data mais recente primeiro
            _agendamentos.sort((a, b) => b.dataAgendamento.compareTo(a.dataAgendamento));
            _isLoading = false;
          });
        }
      } else {
        debugPrint('⚠️ Resposta sem sucesso: ${response.toString()}');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao carregar agendamentos: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar agendamentos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  List<Agendamento> get _agendamentosFiltrados {
    if (_filtroStatus == 'todos') return _agendamentos;
    return _agendamentos.where((a) => a.status == _filtroStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado':
        return Colors.green;
      case 'pendente':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      case 'concluido':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmado':
        return 'Confirmado';
      case 'pendente':
        return 'Pendente';
      case 'cancelado':
        return 'Cancelado';
      case 'concluido':
        return 'Concluído';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmado':
        return Icons.check_circle;
      case 'pendente':
        return Icons.schedule;
      case 'cancelado':
        return Icons.cancel;
      case 'concluido':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _formatarData(String data) {
    try {
      final date = DateTime.parse(data);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return data;
    }
  }

  String _formatarHora(String hora) {
    if (hora.length > 5) {
      return hora.substring(0, 5);
    }
    return hora;
  }

  Future<void> _cancelarAgendamento(Agendamento agendamento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text('Tem certeza que deseja cancelar este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        debugPrint('🚫 Cancelando agendamento ID: ${agendamento.id}');
        
        final response = await _api.put(
          '${AppConfig.agendamentos}/${agendamento.id}/status',
          {'status': 'cancelado'},
          requiresAuth: true,
        );

        debugPrint('✅ Resposta recebida: ${response.toString()}');

        if (response['success']) {
          _loadAgendamentos();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Agendamento cancelado'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('❌ Erro ao cancelar: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao cancelar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFiltroChip('todos', 'Todos'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('pendente', 'Pendentes'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('confirmado', 'Confirmados'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('concluido', 'Concluídos'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('cancelado', 'Cancelados'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agendamentosFiltrados.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadAgendamentos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _agendamentosFiltrados.length,
                    itemBuilder: (context, index) {
                      final agendamento = _agendamentosFiltrados[index];
                      return _buildAgendamentoCard(agendamento);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BuscarGuiasPage(),
            ),
          );
          if (result == true) {
            _loadAgendamentos();
          }
        },
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Tour'),
      ),
    );
  }

  Widget _buildFiltroChip(String valor, String label) {
    final isSelected = _filtroStatus == valor;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtroStatus = valor;
        });
      },
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _filtroStatus == 'todos' 
                ? 'Nenhum agendamento encontrado'
                : 'Nenhum agendamento ${_getStatusText(_filtroStatus).toLowerCase()}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Que tal agendar seu primeiro tour?',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuscarGuiasPage(),
                ),
              );
              if (result == true) {
                _loadAgendamentos();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.search),
            label: const Text('Buscar Guias'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendamentoCard(Agendamento agendamento) {
    final statusColor = _getStatusColor(agendamento.status);
    final canCancel = agendamento.status == 'pendente' || agendamento.status == 'confirmado';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(agendamento.status),
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusText(agendamento.status),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Tour #${agendamento.id}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Informações do guia
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Text(
                    agendamento.guiaNome?[0].toUpperCase() ?? 'G',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agendamento.guiaNome ?? 'Guia não informado',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (agendamento.guiaTelefone != null)
                        Text(
                          '📞 ${agendamento.guiaTelefone}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Detalhes do agendamento
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Data: ${_formatarData(agendamento.dataAgendamento)}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Horário: ${_formatarHora(agendamento.horaInicio)} - ${_formatarHora(agendamento.horaFim)}'),
                    ],
                  ),
                  if (agendamento.duracaoEstimada != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Duração: ${(agendamento.duracaoEstimada! / 60).round()}h'),
                      ],
                    ),
                  ],
                  if (agendamento.valor != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text('Valor: R\$ ${agendamento.valor!.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            if (agendamento.observacoes != null && agendamento.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        agendamento.observacoes!,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Ações
            if (canCancel) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (agendamento.guiaTelefone != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implementar chamada ou WhatsApp
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Telefone: ${agendamento.guiaTelefone}'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Contato'),
                      ),
                    ),
                  if (agendamento.guiaTelefone != null) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _cancelarAgendamento(agendamento),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
