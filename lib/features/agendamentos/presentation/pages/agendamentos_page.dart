import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/agendamento.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';
import 'criar_agendamento_page.dart';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key});

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  final ApiService _api = ApiService();
  List<Agendamento> _agendamentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      String endpoint = AppConfig.agendamentos;
      if (user.tipo == 'turista') {
        endpoint = '${AppConfig.agendamentos}/turista/${user.id}';
      } else if (user.tipo == 'guia') {
        endpoint = '${AppConfig.agendamentos}/guia/${user.id}';
      }

      final response = await _api.get(endpoint, requiresAuth: true);
      if (response['success']) {
        final List<dynamic> data = response['data'];
        setState(() {
          _agendamentos = data.map((json) => Agendamento.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
        );
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isTurista = user?.tipo == 'turista';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_agendamentos.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Nenhum agendamento encontrado'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAgendamentos,
                child: const Text('Recarregar'),
              ),
            ],
          ),
        ),
        floatingActionButton: isTurista
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CriarAgendamentoPage(),
                    ),
                  );
                  if (result == true) {
                    _loadAgendamentos();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Novo'),
              )
            : null,
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAgendamentos,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _agendamentos.length,
          itemBuilder: (context, index) {
            final agendamento = _agendamentos[index];
            final dateFormat = DateFormat('dd/MM/yyyy');
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(agendamento.status),
                  child: const Icon(Icons.calendar_today, color: Colors.white),
                ),
                title: Text('Agendamento #${agendamento.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data: ${dateFormat.format(agendamento.dataAgendamento)}'),
                    Text('Horário: ${agendamento.horaInicio} - ${agendamento.horaFim}'),
                    Text('Status: ${agendamento.status}'),
                    if (agendamento.valor != null)
                      Text('Valor: R\$ ${agendamento.valor!.toStringAsFixed(2)}'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navegar para detalhes do agendamento
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: isTurista
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CriarAgendamentoPage(),
                  ),
                );
                if (result == true) {
                  _loadAgendamentos();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Novo'),
            )
          : null,
    );
  }
}
