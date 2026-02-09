import 'package:flutter/material.dart';
import '../../../../core/models/atrativo.dart';

class AtrativoDetalhesPage extends StatelessWidget {
  final Atrativo atrativo;

  const AtrativoDetalhesPage({
    super.key,
    required this.atrativo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(atrativo.nome),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com fotos
            _buildPhotosSection(context),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome
                  Text(
                    atrativo.nome,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Avaliação
                  if (atrativo.rating != null)
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (atrativo.rating ?? 0).round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${atrativo.rating} (${atrativo.userRatingsTotal ?? 0} avaliações)',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  
                  // Endereço
                  if (atrativo.enderecoCompleto != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            atrativo.enderecoCompleto!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Coordenadas
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coordenadas',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text('Latitude: ${atrativo.latitude}'),
                          Text('Longitude: ${atrativo.longitude}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Botões de ação
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Abrir no mapa
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade em desenvolvimento'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Ver no Mapa'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Compartilhar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade em desenvolvimento'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Compartilhar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection(BuildContext context) {
    // Debug
    print('📸 _buildPhotosSection chamado');
    print('   Fotos: ${atrativo.fotos}');
    print('   Total: ${atrativo.fotos?.length ?? 0}');
    
    if (atrativo.fotos == null || atrativo.fotos!.isEmpty) {
      // Placeholder quando não há fotos
      return Container(
        height: 200,
        width: double.infinity,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.place,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    // Se há apenas uma foto, mostra em tela cheia
    if (atrativo.fotos!.length == 1) {
      return SizedBox(
        height: 250,
        width: double.infinity,
        child: Image.network(
          atrativo.fotos![0],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.broken_image,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    }

    // Se há múltiplas fotos, mostra em carrossel
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: atrativo.fotos!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showPhotoGallery(context, index),
                child: Image.network(
                  atrativo.fotos![index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // Indicador de páginas
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              atrativo.fotos!.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPhotoGallery(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '${initialIndex + 1} de ${atrativo.fotos!.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: atrativo.fotos!.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    atrativo.fotos![index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
