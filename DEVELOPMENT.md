# Guia de Desenvolvimento

## 🚀 Começando

### Executar o App
```bash
flutter run
```

### Ver Logs
```bash
flutter logs
```

### Limpar Build
```bash
flutter clean
flutter pub get
```

## 📱 Testando por Perfil

### Criar Usuários de Teste

```bash
# Turista
curl -X POST http://localhost:3001/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Turista Teste","email":"turista@teste.com","cpf":"11111111111","senha":"123456","telefone":"11999999999","tipo":"turista"}'

# Guia
curl -X POST http://localhost:3001/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Guia Teste","email":"guia@teste.com","cpf":"22222222222","senha":"123456","telefone":"11888888888","tipo":"guia","matricula":"G001","hora_trabalho":"8"}'

# Admin
curl -X POST http://localhost:3001/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Admin Teste","email":"admin@teste.com","cpf":"33333333333","senha":"123456","telefone":"11777777777","tipo":"admin"}'
```

### Credenciais de Teste

| Perfil | Email | Senha |
|--------|-------|-------|
| Turista | turista@teste.com | 123456 |
| Guia | guia@teste.com | 123456 |
| Admin | admin@teste.com | 123456 |

## 🏗️ Estrutura do Projeto

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart          # Configurações (URL da API)
│   ├── models/
│   │   ├── usuario.dart             # ✅ Atualizado
│   │   ├── atrativo.dart            # ✅ Corrigido
│   │   ├── roteiro.dart             # ✅ Corrigido
│   │   ├── agendamento.dart         # ✅ Novo
│   │   └── disponibilidade.dart     # ✅ Novo
│   ├── providers/
│   │   └── auth_provider.dart       # ✅ Com logs de debug
│   ├── routes/
│   │   └── app_routes.dart          # ✅ Atualizado
│   ├── services/
│   │   ├── api_service.dart         # ✅ Com tratamento de erros
│   │   └── storage_service.dart
│   └── theme/
│       └── app_theme.dart
└── features/
    ├── auth/
    │   └── presentation/pages/
    │       ├── login_page.dart      # ✅ Atualizado
    │       └── register_page.dart
    ├── home/
    │   └── presentation/pages/
    │       └── welcome_page.dart    # ✅ Novo (baseado no React)
    ├── atrativos/
    │   └── presentation/pages/
    │       ├── atrativos_page.dart
    │       └── atrativo_detalhes_page.dart
    ├── roteiros/
    │   └── presentation/pages/
    │       ├── roteiros_page.dart
    │       └── roteiro_detalhes_page.dart
    ├── agendamentos/
    │   └── presentation/pages/
    │       ├── agendamentos_page.dart
    │       └── criar_agendamento_page.dart
    └── splash/
        └── presentation/pages/
            └── splash_page.dart     # ✅ Atualizado
```

## 🔨 Implementando Nova Funcionalidade

### 1. Criar Modelo (se necessário)
```dart
// lib/core/models/meu_modelo.dart
class MeuModelo {
  final int id;
  final String nome;

  MeuModelo({required this.id, required this.nome});

  factory MeuModelo.fromJson(Map<String, dynamic> json) {
    return MeuModelo(
      id: json['id'],
      nome: json['nome'],
    );
  }
}
```

### 2. Criar Service (se necessário)
```dart
// lib/core/services/meu_service.dart
import 'api_service.dart';
import '../models/meu_modelo.dart';

class MeuService {
  final ApiService _api = ApiService();

  Future<List<MeuModelo>> listar() async {
    final response = await _api.get('/meu-endpoint');
    final List<dynamic> data = response['data'];
    return data.map((json) => MeuModelo.fromJson(json)).toList();
  }
}
```

### 3. Criar Página
```dart
// lib/features/minha_feature/presentation/pages/minha_page.dart
import 'package:flutter/material.dart';

class MinhaPage extends StatefulWidget {
  const MinhaPage({super.key});

  @override
  State<MinhaPage> createState() => _MinhaPageState();
}

class _MinhaPageState extends State<MinhaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Página')),
      body: const Center(child: Text('Conteúdo')),
    );
  }
}
```

### 4. Adicionar Rota
```dart
// lib/core/routes/app_routes.dart
static const String minhaRota = '/minha-rota';

case minhaRota:
  return MaterialPageRoute(builder: (_) => const MinhaPage());
```

## 🐛 Debug

### Logs do AuthProvider
O AuthProvider agora tem logs detalhados:
- 🔐 Tentando login
- 📡 URL da requisição
- ✅ Resposta recebida
- 💾 Salvando dados
- ❌ Erros

### Ver Logs no Terminal
```bash
flutter logs
```

### Adicionar Logs Personalizados
```dart
debugPrint('🔍 Minha mensagem de debug');
```

## 📝 Convenções de Código

### Nomenclatura
- Classes: `PascalCase`
- Variáveis/Funções: `camelCase`
- Constantes: `camelCase` com `const`
- Arquivos: `snake_case.dart`

### Estrutura de Widgets
```dart
class MinhaPage extends StatefulWidget {
  const MinhaPage({super.key});

  @override
  State<MinhaPage> createState() => _MinhaPageState();
}

class _MinhaPageState extends State<MinhaPage> {
  // 1. Variáveis de estado
  bool _isLoading = false;
  
  // 2. Lifecycle methods
  @override
  void initState() {
    super.initState();
  }
  
  // 3. Métodos privados
  Future<void> _carregarDados() async {
    // ...
  }
  
  // 4. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
  
  // 5. Métodos auxiliares de build
  Widget _buildItem() {
    return Container();
  }
}
```

## 🧪 Testes

### Testar Conexão
```bash
dart test_connection.dart
```

### Testar API Manualmente
```bash
# Health Check
curl http://localhost:3001/api/health

# Login
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"emailOrDocument":"teste@teste.com","senha":"123456"}'
```

## 📚 Recursos

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [Material Design](https://m3.material.io/)
- [Provider Package](https://pub.dev/packages/provider)
