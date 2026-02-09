# Setup TourGuides

## ✅ Checklist de Configuração

### 1. Backend
- [ ] Backend rodando em `http://localhost:3001`
- [ ] Testar: `curl http://localhost:3001/api/health`

### 2. Flutter
- [ ] Flutter SDK instalado
- [ ] Executar: `flutter doctor`
- [ ] Instalar dependências: `flutter pub get`

### 3. Configuração do App

#### Android Emulator
```dart
// lib/core/config/app_config.dart
static const String baseUrl = 'http://10.0.2.2:3001/api';
```

#### Dispositivo Físico
1. Descobrir IP do computador: `ipconfig` (Windows)
2. Atualizar baseUrl:
```dart
static const String baseUrl = 'http://SEU_IP:3001/api';
```
3. Garantir que dispositivo e PC estão na mesma rede WiFi

### 4. Executar App
```bash
flutter run
```

### 5. Login
```
Email: teste@teste.com
Senha: 123456
```

## 🔧 Correções Aplicadas

### Modelos
- ✅ `Atrativo`: Corrigido parsing de latitude/longitude/rating (string → double)
- ✅ `Roteiro`: Corrigido parsing de distancia_total (string → double)

### Providers
- ✅ `AuthProvider`: Corrigido parsing da resposta de login

### Limpeza
- ✅ Removidos 19 arquivos .md desnecessários
- ✅ Removidos 3 widgets não utilizados
- ✅ README simplificado

## 📊 Status das APIs

| Endpoint | Status | Dados |
|----------|--------|-------|
| `/health` | ✅ OK | API funcionando |
| `/auth/login` | ✅ OK | Autenticação funcionando |
| `/atrativos` | ✅ OK | 2.097 atrativos |
| `/roteiros` | ✅ OK | 1 roteiro |
| `/tipos-atrativos` | ✅ OK | 95 tipos |

## 🐛 Problemas Resolvidos

1. **SocketException**: Alterado `localhost` para `10.0.2.2` (emulador Android)
2. **Erro 401 no login**: Criado usuário de teste
3. **Parsing de dados**: Corrigidos modelos para aceitar strings da API
4. **Nenhum atrativo/roteiro encontrado**: Corrigido parsing dos modelos
