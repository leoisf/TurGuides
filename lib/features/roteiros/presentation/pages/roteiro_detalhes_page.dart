import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/roteiro.dart';
import '../../../../core/models/atrativo.dart';
import '../../../../core/services/api_service.dart';

class RoteiroDetalhesPage extends StatefulWidget {
  final Roteiro roteiro;

  const RoteiroDetalhesPage({
    super.key,
    required this.roteiro,
  });

  @override
  State<RoteiroDetalhesPage> createState() => _RoteiroDetalhesPageState();
}

class _RoteiroDetalhesPageState extends State<RoteiroDetalhesPage> {
  final ApiService _api = ApiService();
  List<Atrativo> _pontos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetalhes();
  }

  Future<void> _loadDetalhes() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get('${AppConfig.roteiros}/${widget.roteiro.id}');
      if (response['success']) {
        final data = response['data'];
        if (data['pontos'] != null) {
          final List<dynamic> pontosData = data['pontos'];
          setState(() {
            _pontos = pontosData.map((json) => Atrativo.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar detalhes: $e')),
        );
      }
    }
  }

  String _formatTempo(int? minutos) {
    if (minutos == null) return 'N/A';
    final horas = minutos ~/ 60;
    final mins = minutos % 60;
    if (horas > 0) {
      return '${horas}h ${mins}min';
    }
    return '${mins}min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roteiro.nome),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.roteiro.nome,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.route,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.roteiro.distanciaTotal?.toStringAsFixed(1) ?? "N/A"} km',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Icon(
                              Icons.access_time,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTempo(widget.roteiro.tempoEstimado),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Pontos do roteiro
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pontos do Roteiro (${_pontos.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        
                        if (_pontos.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('Nenhum ponto cadastrado'),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _pontos.length,
                            itemBuilder: (context, index) {
                              final ponto = _pontos[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                  title: Text(ponto.nome),
                                  subtitle: ponto.endereco != null
                                      ? Text(ponto.endereco!)
                                      : null,
                                  trailing: ponto.rating != null
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text('${ponto.rating}'),
                                          ],
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  
                  // Botão de ação
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navegar para criar agendamento
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em desenvolvimento'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Agendar Tour'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
