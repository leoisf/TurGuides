import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/models/atrativo.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/map_widget.dart';
import 'atrativo_detalhes_page.dart';

class AtrativosMapPage extends StatefulWidget {
  const AtrativosMapPage({super.key});

  @override
  State<AtrativosMapPage> createState() => _AtrativosMapPageState();
}

class _AtrativosMapPageState extends State<AtrativosMapPage> {
  final ApiService _api = ApiService();
  List<Atrativo> _atrativos = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final Set<String> _tiposSelecionados = {};
  bool _mostrarFiltros = false;
  Atrativo? _atrativoSelecionado;
  int? _cardExpandido; // ID do card expandido

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

  void _handleMarkerTap(Atrativo atrativo) {
    setState(() {
      // Se clicar no mesmo, desmarca
      if (_atrativoSelecionado?.id == atrativo.id) {
        _atrativoSelecionado = null;
        _cardExpandido = null;
      } else {
        _atrativoSelecionado = atrativo;
        _cardExpandido = null; // Fecha detalhes ao selecionar outro
      }
    });
  }

  void _handleCardTap(Atrativo atrativo) {
    setState(() {
      // Se já está selecionado, expande/colapsa detalhes
      if (_atrativoSelecionado?.id == atrativo.id) {
        _cardExpandido = _cardExpandido == atrativo.id ? null : atrativo.id;
      } else {
        // Seleciona e foca no mapa
        _atrativoSelecionado = atrativo;
        _cardExpandido = null;
      }
    });
  }

  void _verDetalhes(Atrativo atrativo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AtrativoDetalhesPage(atrativo: atrativo),
      ),
    );
  }

  List<String> get _tiposUnicos {
    final tipos = <String>{};
    for (var atrativo in _atrativos) {
      if (atrativo.tipos != null) {
        tipos.addAll(atrativo.tipos!);
      }
    }
    return tipos.toList()..sort();
  }

  List<Atrativo> get _atrativosFiltrados {
    var filtrados = _atrativos;

    // Filtro por busca de texto
    if (_searchQuery.isNotEmpty) {
      filtrados = filtrados.where((atrativo) {
        final searchLower = _searchQuery.toLowerCase();
        final matchNome = atrativo.nome.toLowerCase().contains(searchLower);
        final matchEndereco = atrativo.endereco?.toLowerCase().contains(searchLower) ?? false;
        final matchTipo = atrativo.tipos?.any((tipo) => tipo.toLowerCase().contains(searchLower)) ?? false;
        return matchNome || matchEndereco || matchTipo;
      }).toList();
    }

    // Filtro por tipos selecionados
    if (_tiposSelecionados.isNotEmpty) {
      filtrados = filtrados.where((atrativo) {
        if (atrativo.tipos == null) return false;
        return atrativo.tipos!.any((tipo) => _tiposSelecionados.contains(tipo));
      }).toList();
    }

    return filtrados;
  }

  void _toggleTipo(String tipo) {
    setState(() {
      if (_tiposSelecionados.contains(tipo)) {
        _tiposSelecionados.remove(tipo);
      } else {
        _tiposSelecionados.add(tipo);
      }
    });
  }

  void _limparFiltros() {
    setState(() {
      _searchQuery = '';
      _tiposSelecionados.clear();
      _atrativoSelecionado = null;
      _cardExpandido = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pontos Turísticos'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          // Botão de filtros
          IconButton(
            icon: Icon(_mostrarFiltros ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () {
              setState(() {
                _mostrarFiltros = !_mostrarFiltros;
              });
            },
            tooltip: 'Filtros',
          ),
          // Botão de limpar filtros
          if (_searchQuery.isNotEmpty || _tiposSelecionados.isNotEmpty || _atrativoSelecionado != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _limparFiltros,
              tooltip: 'Limpar tudo',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar pontos turísticos...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF1976D2)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Painel de filtros (checkboxes como no web)
                if (_mostrarFiltros && _tiposUnicos.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.category, size: 20, color: Color(0xFF1976D2)),
                            const SizedBox(width: 8),
                            const Text(
                              'Filtrar por tipo:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            if (_tiposSelecionados.isNotEmpty)
                              Text(
                                '${_tiposSelecionados.length} selecionado(s)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Checkboxes como no sistema web
                        ...(_tiposUnicos.map((tipo) {
                          final selecionado = _tiposSelecionados.contains(tipo);
                          return InkWell(
                            onTap: () => _toggleTipo(tipo),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selecionado,
                                    onChanged: (_) => _toggleTipo(tipo),
                                    activeColor: const Color(0xFF1976D2),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tipo,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList()),
                      ],
                    ),
                  ),
                
                // Mapa
                MapWidget(
                  atrativos: _atrativosFiltrados,
                  onMarkerTap: _handleMarkerTap,
                  selectedAtrativo: _atrativoSelecionado,
                  height: 300,
                ),
                
                // Informações
                if (_atrativoSelecionado != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF1976D2).withAlpha(25),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: Color(0xFF1976D2)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _atrativoSelecionado!.nome,
                            style: const TextStyle(
                              color: Color(0xFF1976D2),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            setState(() {
                              _atrativoSelecionado = null;
                              _cardExpandido = null;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                
                // Lista de atrativos
                Expanded(
                  child: _atrativosFiltrados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty && _tiposSelecionados.isEmpty
                                    ? 'Nenhum ponto turístico encontrado'
                                    : 'Nenhum resultado para os filtros aplicados',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _limparFiltros,
                                icon: const Icon(Icons.clear_all),
                                label: const Text('Limpar filtros'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAtrativos,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _atrativosFiltrados.length,
                            itemBuilder: (context, index) {
                              final atrativo = _atrativosFiltrados[index];
                              final selecionado = _atrativoSelecionado?.id == atrativo.id;
                              final expandido = _cardExpandido == atrativo.id;
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: selecionado ? 4 : 1,
                                color: selecionado 
                                    ? const Color(0xFF1976D2).withAlpha(25)
                                    : null,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: selecionado
                                            ? const Color(0xFF1976D2)
                                            : Colors.grey.shade300,
                                        child: Icon(
                                          Icons.place,
                                          color: selecionado ? Colors.white : Colors.grey.shade600,
                                        ),
                                      ),
                                      title: Text(
                                        atrativo.nome,
                                        style: TextStyle(
                                          fontWeight: selecionado ? FontWeight.bold : FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: atrativo.endereco != null
                                          ? Text(
                                              atrativo.endereco!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : null,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (selecionado)
                                            IconButton(
                                              icon: Icon(
                                                expandido ? Icons.expand_less : Icons.expand_more,
                                                color: const Color(0xFF1976D2),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _cardExpandido = expandido ? null : atrativo.id;
                                                });
                                              },
                                              tooltip: expandido ? 'Ocultar detalhes' : 'Ver detalhes',
                                            ),
                                        ],
                                      ),
                                      onTap: () => _handleCardTap(atrativo),
                                    ),
                                    
                                    // Detalhes expansíveis
                                    if (expandido)
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          border: Border(
                                            top: BorderSide(color: Colors.grey.shade200),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (atrativo.enderecoCompleto != null) ...[
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      atrativo.enderecoCompleto!,
                                                      style: const TextStyle(fontSize: 13),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                            
                                            if (atrativo.rating != null) ...[
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, size: 16, color: Colors.amber),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${atrativo.rating} (${atrativo.userRatingsTotal ?? 0} avaliações)',
                                                    style: const TextStyle(fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                            
                                            if (atrativo.tipos != null && atrativo.tipos!.isNotEmpty) ...[
                                              const Text(
                                                'Tipos:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: atrativo.tipos!.map((tipo) {
                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF1976D2).withAlpha(25),
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(
                                                        color: const Color(0xFF1976D2).withAlpha(51),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      tipo,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF1976D2),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                              const SizedBox(height: 12),
                                            ],
                                            
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: () => _verDetalhes(atrativo),
                                                icon: const Icon(Icons.info_outline, size: 18),
                                                label: const Text('Ver Detalhes Completos'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF1976D2),
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
