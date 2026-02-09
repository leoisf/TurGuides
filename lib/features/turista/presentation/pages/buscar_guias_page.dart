import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/usuario.dart';
import '../../../../core/services/api_service.dart';
import 'agendar_tour_page.dart';

class BuscarGuiasPage extends StatefulWidget {
  const BuscarGuiasPage({super.key});

  @override
  State<BuscarGuiasPage> createState() => _BuscarGuiasPageState();
}

class _BuscarGuiasPageState extends State<BuscarGuiasPage> {
  final ApiService _api = ApiService();
  List<Usuario> _guias = [];
  bool _isLoading = false;
  DateTime? _dataSelecionada;
  TimeOfDay? _horarioSelecionado;

  @override
  void initState() {
    super.initState();
    _dataSelecionada = DateTime.now().add(const Duration(days: 1));
    _horarioSelecionado = const TimeOfDay(hour: 9, minute: 0);
  }

  Future<void> _buscarGuias() async {
    if (_dataSelecionada == null || _horarioSelecionado == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione data e horário')),
      );
      return;
    }

    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final dataFormatada = DateFormat('yyyy-MM-dd').format(_dataSelecionada!);
      
      debugPrint('🔍 [BUSCAR GUIAS] Iniciando busca');
      debugPrint('📅 [BUSCAR GUIAS] Data: $dataFormatada');
      debugPrint('⏰ [BUSCAR GUIAS] Horário: ${_formatarHorario(_horarioSelecionado!)}');
      
      // Usar a rota correta do backend: /api/agenda/turistas/guias-disponiveis
      final response = await _api.get(
        '/agenda/turistas/guias-disponiveis?data=$dataFormatada',
        requiresAuth: true,
      );

      debugPrint('✅ [BUSCAR GUIAS] Resposta recebida');
      debugPrint('📦 [BUSCAR GUIAS] Response: ${response.toString()}');

      if (!mounted) return;

      if (response['success'] == true) {
        final List<dynamic> guiasData = response['data'] ?? [];
        
        debugPrint('👥 [BUSCAR GUIAS] Total de guias disponíveis: ${guiasData.length}');
        
        // A API retorna guia_id, guia_nome, etc. Precisamos mapear para o formato esperado
        final guias = guiasData.map((json) {
          // Mapear campos com prefixo 'guia_' para o formato padrão
          final usuarioJson = {
            'id': json['guia_id'],
            'nome': json['guia_nome'],
            'email': json['guia_email'],
            'telefone': json['guia_telefone'],
            'tipo': 'guia',  // Corrigido: era 'tipo_usuario'
            'lingua': json['guia_lingua'],
            'hora_trabalho': json['guia_hora_trabalho'],
            'disponibilidades': json['disponibilidades'],
          };
          
          debugPrint('📦 [BUSCAR GUIAS] Mapeando guia: ${usuarioJson['nome']} (ID: ${usuarioJson['id']})');
          
          return Usuario.fromJson(usuarioJson);
        }).toList();
        
        setState(() {
          _guias = guias;
          _isLoading = false;
        });
        
        if (_guias.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum guia disponível para esta data'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          debugPrint('✅ [BUSCAR GUIAS] ${_guias.length} guias carregados com sucesso');
        }
      } else {
        debugPrint('⚠️ [BUSCAR GUIAS] Resposta sem sucesso: ${response['message']}');
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erro ao buscar guias'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [BUSCAR GUIAS] Erro: $e');
      debugPrint('📍 [BUSCAR GUIAS] Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao buscar guias: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (data != null) {
      setState(() {
        _dataSelecionada = data;
      });
    }
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: _horarioSelecionado ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF1976D2),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (horario != null) {
      setState(() {
        _horarioSelecionado = horario;
      });
    }
  }

  String _formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  String _formatarHorario(TimeOfDay horario) {
    return '${horario.hour.toString().padLeft(2, '0')}:${horario.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Guias'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1976D2).withAlpha(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quando você quer fazer o tour?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selecionarData,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                              const SizedBox(width: 8),
                              Text(
                                _dataSelecionada != null
                                    ? _formatarData(_dataSelecionada!)
                                    : 'Selecionar data',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _selecionarHorario,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: Color(0xFF1976D2)),
                              const SizedBox(width: 8),
                              Text(
                                _horarioSelecionado != null
                                    ? _formatarHorario(_horarioSelecionado!)
                                    : 'Selecionar horário',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _buscarGuias,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Buscar Guias'),
                  ),
                ),
              ],
            ),
          ),

          // Lista de guias
          Expanded(
            child: _guias.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum guia encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tente uma data ou horário diferente',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _guias.length,
                    itemBuilder: (context, index) {
                      final guia = _guias[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF1976D2),
                            child: Text(
                              guia.nome[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            guia.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (guia.telefone != null)
                                Text('📞 ${guia.telefone}'),
                              if (guia.lingua != null)
                                Text('🗣️ ${guia.lingua}'),
                              if (guia.horaTrabalho != null)
                                Text('⏰ ${guia.horaTrabalho}h/dia'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AgendarTourPage(
                                    guia: guia,
                                    data: _dataSelecionada!,
                                    horario: _horarioSelecionado!,
                                  ),
                                ),
                              );
                              
                              if (result == true && mounted) {
                                Navigator.pop(context, true);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Agendar'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}