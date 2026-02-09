import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/routes/app_routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final usuario = authProvider.currentUser;

    if (usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TourGuides - Turista'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
            tooltip: 'Meu Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com saudação e logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.travel_explore,
                            size: 32,
                            color: Color(0xFF1976D2),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${usuario.nome.split(' ')[0]}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pronto para explorar?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Menu principal do turista
            Text(
              'Explore',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildTuristaMenu(context),
            
            const SizedBox(height: 24),
            Text(
              'Minha Conta',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildAccountMenu(context),
          ],
        ),
      ),
    );
  }



  List<Widget> _buildTuristaMenu(BuildContext context) {
    return [
      _buildMenuCard(
        context,
        icon: Icons.person_search,
        title: 'Buscar Guias',
        description: 'Encontre guias disponíveis e agende seu tour',
        color: const Color(0xFF1976D2),
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.buscarGuias),
      ),
      _buildMenuCard(
        context,
        icon: Icons.event_available,
        title: 'Meus Agendamentos',
        description: 'Veja e gerencie seus tours agendados',
        color: const Color(0xFF4CAF50),
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.agendamentos),
      ),
      _buildMenuCard(
        context,
        icon: Icons.route,
        title: 'Roteiros Turísticos',
        description: 'Explore roteiros incríveis pela cidade',
        color: const Color(0xFFFF9800),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.roteiros),
      ),
      _buildMenuCard(
        context,
        icon: Icons.place,
        title: 'Pontos Turísticos',
        description: 'Descubra atrativos e lugares especiais',
        color: const Color(0xFF9C27B0),
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
        ),
        onTap: () => Navigator.pushNamed(context, AppRoutes.atrativos),
      ),
    ];
  }

  List<Widget> _buildAccountMenu(BuildContext context) {
    return [
      _buildMenuCard(
        context,
        icon: Icons.account_circle_outlined,
        title: 'Editar Perfil',
        description: 'Atualize suas informações pessoais',
        color: const Color(0xFF757575),
        onTap: () => Navigator.pushNamed(context, AppRoutes.perfil),
      ),
      _buildMenuCard(
        context,
        icon: Icons.security,
        title: 'Alterar Senha',
        description: 'Modifique sua senha de acesso',
        color: const Color(0xFF757575),
        onTap: () => Navigator.pushNamed(context, AppRoutes.alterarSenha),
      ),
    ];
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    Gradient? gradient,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: gradient ?? LinearGradient(
                    colors: [color.withAlpha(50), color.withAlpha(30)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
