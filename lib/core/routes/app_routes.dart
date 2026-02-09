import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/welcome_page.dart';
import '../../features/atrativos/presentation/pages/atrativos_map_page.dart';
import '../../features/roteiros/presentation/pages/roteiros_map_page.dart';
import '../../features/agendamentos/presentation/pages/agendamentos_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/turista/presentation/pages/buscar_guias_page.dart';
import '../../features/turista/presentation/pages/perfil_page.dart';
import '../../features/turista/presentation/pages/alterar_senha_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String welcome = '/welcome';
  static const String atrativos = '/atrativos';
  static const String roteiros = '/roteiros';
  static const String agendamentos = '/agendamentos';
  static const String buscarGuias = '/buscar-guias';
  static const String perfil = '/perfil';
  static const String alterarSenha = '/alterar-senha';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());
      case atrativos:
        return MaterialPageRoute(builder: (_) => const AtrativosMapPage());
      case roteiros:
        return MaterialPageRoute(builder: (_) => const RoteirosMapPage());
      case agendamentos:
        return MaterialPageRoute(builder: (_) => const AgendamentosPage());
      case buscarGuias:
        return MaterialPageRoute(builder: (_) => const BuscarGuiasPage());
      case perfil:
        return MaterialPageRoute(builder: (_) => const PerfilPage());
      case alterarSenha:
        return MaterialPageRoute(builder: (_) => const AlterarSenhaPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
