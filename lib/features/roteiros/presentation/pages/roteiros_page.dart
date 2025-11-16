import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/roteiro.dart';
import '../../../../core/services/api_service.dart';
import 'roteiro_detalhes_page.dart';

class RoteirosPage extends StatefulWidget {
  const RoteirosPage({super.key});

  @override
  State<RoteirosPage> createState() => _RoteirosPageState();
}

class _RoteirosPageState extends State<RoteirosPage> {
  final ApiService _api = ApiService();
  List<Roteiro> _roteiros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoteiros();
  }

  Future<void> _loadRoteiros() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get(AppConfig.roteiros);
      if (response['success']) {
        final List<dynamic> data = response['data'];
        setState(() {
          _roteiros = data.map((json) => Roteiro.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar roteiros: $e')),
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_roteiros.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhum roteiro encontrado'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRoteiros,
              child: const Text('Recarregar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRoteiros,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _roteiros.length,
        itemBuilder: (context, index) {
          final roteiro = _roteiros[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.map),
              ),
              title: Text(roteiro.nome),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (roteiro.distanciaTotal != null)
                    Text('Distância: ${roteiro.distanciaTotal!.toStringAsFixed(1)} km'),
                  if (roteiro.tempoEstimado != null)
                    Text('Tempo: ${_formatTempo(roteiro.tempoEstimado)}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoteiroDetalhesPage(roteiro: roteiro),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
