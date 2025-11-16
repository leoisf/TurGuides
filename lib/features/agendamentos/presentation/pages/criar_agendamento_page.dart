import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/roteiro.dart';
import '../../../../core/models/usuario.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/api_service.dart';

class CriarAgendamentoPage extends StatefulWidget {
  final Roteiro? roteiro;

  const CriarAgendamentoPage({
    super.key,
    this.roteiro,
  });

  @override
  State<CriarAgendamentoPage> createState() => _CriarAgendamentoPageState();
}

class _CriarAgendamentoPageState extends State<CriarAgendamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  
  DateTime? _selectedDate;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;
  int? _roteiroId;
  int? _guiaId;
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  List<Roteiro> _roteiros = [];
  List<Usuario> _guias = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roteiroId = widget.roteiro?.id;
    _loadData();
  }

  @override
  void dispose() {
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Carregar roteiros
      final roteirosResponse = await _api.get(AppConfig.roteiros);
      if (roteirosResponse['success']) {
        final List<dynamic> data = roteirosResponse['data'];
        _roteiros = data.map((json) => Roteiro.fromJson(json)).toList();
      }

      // Carregar guias (filtrar usuários do tipo guia)
      final usuariosResponse = await _api.get(AppConfig.usuarios);
      if (usuariosResponse['success']) {
        final List<dynamic> data = usuariosResponse['data'];
        _guias = data
            .map((json) => Usuario.fromJson(json))
            .where((user) => user.tipo == 'guia')
            .toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime(bool isInicio) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = time;
        } else {
          _horaFim = time;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma data')),
      );
      return;
    }

    if (_horaInicio == null || _horaFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione os horários')),
      );
      return;
    }

    if (_roteiroId == null || _guiaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione roteiro e guia')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().currentUser;
      
      final data = {
        'turista_id': user!.id,
        'guia_id': _guiaId,
        'roteiro_id': _roteiroId,
        'data_agendamento': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'hora_inicio': _formatTime(_horaInicio!),
        'hora_fim': _formatTime(_horaFim!),
        'valor': double.tryParse(_valorController.text),
        'observacoes': _observacoesController.text.isEmpty 
            ? null 
            : _observacoesController.text,
      };

      final response = await _api.post(
        AppConfig.agendamentos,
        data,
        requiresAuth: true,
      );

      setState(() => _isLoading = false);

      if (response['success'] && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento criado com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar agendamento: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
      ),
      body: _isLoading && _roteiros.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Roteiro
                    DropdownButtonFormField<int>(
                      initialValue: _roteiroId,
                      decoration: const InputDecoration(
                        labelText: 'Roteiro',
                        prefixIcon: Icon(Icons.map),
                      ),
                      items: _roteiros.map((roteiro) {
                        return DropdownMenuItem(
                          value: roteiro.id,
                          child: Text(roteiro.nome),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _roteiroId = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Selecione um roteiro';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Guia
                    DropdownButtonFormField<int>(
                      initialValue: _guiaId,
                      decoration: const InputDecoration(
                        labelText: 'Guia',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _guias.map((guia) {
                        return DropdownMenuItem(
                          value: guia.id,
                          child: Text(guia.nome),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _guiaId = value);
                      },
                      validator: (value) {
                        if (value == null) return 'Selecione um guia';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Data
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _selectedDate == null
                            ? 'Selecionar Data'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectDate,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Horários
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            leading: const Icon(Icons.access_time),
                            title: Text(
                              _horaInicio == null
                                  ? 'Início'
                                  : _horaInicio!.format(context),
                            ),
                            onTap: () => _selectTime(true),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            leading: const Icon(Icons.access_time),
                            title: Text(
                              _horaFim == null
                                  ? 'Fim'
                                  : _horaFim!.format(context),
                            ),
                            onTap: () => _selectTime(false),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Valor
                    TextFormField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: 'Valor (R\$)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    
                    // Observações
                    TextFormField(
                      controller: _observacoesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Botão
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Criar Agendamento'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
