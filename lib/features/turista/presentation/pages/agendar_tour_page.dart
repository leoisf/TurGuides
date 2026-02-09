import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/usuario.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';

class AgendarTourPage extends StatefulWidget {
  final Usuario guia;
  final DateTime data;
  final TimeOfDay horario;

  const AgendarTourPage({
    super.key,
    required this.guia,
    required this.data,
    required this.horario,
  });

  @override
  State<AgendarTourPage> createState() => _AgendarTourPageState();
}

class _AgendarTourPageState extends State<AgendarTourPage> {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();
  
  TimeOfDay? _horarioFim;
  int _duracaoHoras = 2;
  double _valorEstimado = 100.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calcularHorarioFim();
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  void _calcularHorarioFim() {
    final inicioMinutos = widget.horario.hour * 60 + widget.horario.minute;
    final fimMinutos = inicioMinutos + (_duracaoHoras * 60);
    
    setState(() {
      _horarioFim = TimeOfDay(
        hour: (fimMinutos ~/ 60) % 24,
        minute: fimMinutos % 60,
      );
    });
  }

  String _formatarHorario(TimeOfDay horario) {
    return '${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmarAgendamento() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().currentUser;
    if (user == null) {
      debugPrint('❌ Usuário não autenticado');
      return;
    }

    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final agendamento = {
        'turista_id': user.id,
        'guia_id': widget.guia.id,
        'data_agendamento': DateFormat('yyyy-MM-dd').format(widget.data),
        'hora_inicio': _formatarHorario(widget.horario),
        'hora_fim': _formatarHorario(_horarioFim!),
        'duracao_estimada': _duracaoHoras * 60,
        'valor': _valorEstimado,
        'observacoes': _observacoesController.text.trim(),
        'status': 'pendente',
      };

      debugPrint('📝 Criando agendamento');
      debugPrint('👤 Turista ID: ${user.id}');
      debugPrint('🎯 Guia ID: ${widget.guia.id}');
      debugPrint('📅 Data: ${agendamento['data_agendamento']}');
      debugPrint('⏰ Horário: ${agendamento['hora_inicio']} - ${agendamento['hora_fim']}');
      debugPrint('🌐 Endpoint: ${AppConfig.baseUrl}${AppConfig.agendamentos}');

      final response = await _api.post(
        AppConfig.agendamentos,
        agendamento,
        requiresAuth: true,
      );

      debugPrint('✅ Resposta recebida: ${response.toString()}');

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Agendamento criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        debugPrint('⚠️ Resposta sem sucesso: ${response.toString()}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${response['message'] ?? 'Falha ao criar agendamento'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao criar agendamento: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar agendamento: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Tour'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações do guia
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 30,
                            child: Text(
                              widget.guia.nome[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.guia.nome,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.guia.telefone != null)
                                  Text('📞 ${widget.guia.telefone}'),
                                if (widget.guia.lingua != null)
                                  Text('🗣️ ${widget.guia.lingua}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Detalhes do agendamento
              const Text(
                'Detalhes do Tour',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.green),
                          const SizedBox(width: 12),
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy').format(widget.data)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.green),
                          const SizedBox(width: 12),
                          Text(
                            'Horário: ${_formatarHorario(widget.horario)} - ${_horarioFim != null ? _formatarHorario(_horarioFim!) : ""}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Duração
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duração do Tour',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Horas: '),
                          Expanded(
                            child: Slider(
                              value: _duracaoHoras.toDouble(),
                              min: 1,
                              max: 8,
                              divisions: 7,
                              label: '$_duracaoHoras horas',
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  _duracaoHoras = value.round();
                                  _valorEstimado = _duracaoHoras * 50.0;
                                  _calcularHorarioFim();
                                });
                              },
                            ),
                          ),
                          Text('$_duracaoHoras h'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Valor estimado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_money, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        'Valor estimado: R\$ ${_valorEstimado.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Observações
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (opcional)',
                  hintText: 'Alguma preferência ou informação especial?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Botão confirmar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmarAgendamento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirmar Agendamento',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Aviso
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seu agendamento ficará pendente até o guia confirmar.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}