import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../atrativos/presentation/pages/atrativos_page.dart';
import '../../../roteiros/presentation/pages/roteiros_page.dart';
import '../../../agendamentos/presentation/pages/agendamentos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const AtrativosPage(),
    const RoteirosPage(),
    const AgendamentosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TourGuides'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Perfil'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nome: ${user?.nome ?? ""}'),
                      Text('Email: ${user?.email ?? ""}'),
                      Text('Tipo: ${user?.tipo ?? ""}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        }
                      },
                      child: const Text('Sair'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.place),
            label: 'Atrativos',
          ),
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Roteiros',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
        ],
      ),
    );
  }
}
