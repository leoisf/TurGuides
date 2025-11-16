import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/atrativo.dart';
import '../../../../core/services/api_service.dart';
import 'atrativo_detalhes_page.dart';

class AtrativosPage extends StatefulWidget {
  const AtrativosPage({super.key});

  @override
  State<AtrativosPage> createState() => _AtrativosPageState();
}

class _AtrativosPageState extends State<AtrativosPage> {
  final ApiService _api = ApiService();
  List<Atrativo> _atrativos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAtrativos();
  }

  Future<void> _loadAtrativos() async {
    setState(() => _isLoading = true);
    try {
      final response = await _api.get(AppConfig.atrativos);
      if (response['success']) {
        final List<dynamic> data = response['data'];
        setState(() {
          _atrativos = data.map((json) => Atrativo.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar atrativos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_atrativos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.place_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhum atrativo encontrado'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAtrativos,
              child: const Text('Recarregar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAtrativos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _atrativos.length,
        itemBuilder: (context, index) {
          final atrativo = _atrativos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.place),
              ),
              title: Text(atrativo.nome),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (atrativo.endereco != null)
                    Text(atrativo.endereco!),
                  if (atrativo.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${atrativo.rating} (${atrativo.userRatingsTotal ?? 0})'),
                      ],
                    ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AtrativoDetalhesPage(atrativo: atrativo),
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
