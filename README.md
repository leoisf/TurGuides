# TourGuides - App do Turista 🧳

App Flutter exclusivo para **turistas** que desejam descobrir tours incríveis e explorar destinos únicos.

## 🎯 Sobre o App

Este é o app **exclusivo para turistas** do sistema TourGuides. Aqui você pode:

- 🔍 **Buscar Guias** - Encontre guias disponíveis por data e horário
- 📅 **Agendar Tours** - Reserve tours personalizados com guias locais
- 🗺️ **Explorar Roteiros** - Descubra roteiros turísticos incríveis
- 📍 **Pontos Turísticos** - Visualize atrativos no mapa interativo
- 👤 **Gerenciar Perfil** - Edite suas informações e preferências

## 🚀 Início Rápido

### Pré-requisitos
- Flutter SDK 3.0+
- Backend TourGuides rodando em `http://localhost:3001`
- Google Maps API Key configurada

### Instalação

```bash
# 1. Instalar dependências
flutter pub get

# 2. Configurar Google Maps API Key
# Edite: android/app/src/main/AndroidManifest.xml
# Adicione sua API Key

# 3. Executar o app
flutter run
```

## 🎨 Design e Tema

- **Cor Principal**: Verde (#4CAF50) - representa aventura e natureza
- **Estilo**: Material Design 3 com foco em turismo
- **Ícone**: Mala de viagem (luggage) representando turistas
- **Interface**: Limpa, intuitiva e otimizada para descoberta

## 📱 Funcionalidades Principais

### 🔍 Buscar Guias
- Selecione data e horário desejado
- Visualize guias disponíveis
- Veja perfil, idiomas e experiência
- Agende tours diretamente

### 📅 Meus Agendamentos
- Visualize todos seus tours agendados
- Filtre por status (pendente, confirmado, concluído)
- Cancele agendamentos quando necessário
- Entre em contato com guias

### 🗺️ Roteiros Turísticos
- Explore roteiros no mapa interativo
- Veja pontos incluídos em cada roteiro
- Informações de distância e tempo
- Detalhes completos de cada roteiro

### 📍 Pontos Turísticos
- Mapa com todos os atrativos
- Busque por nome ou localização
- Veja fotos e avaliações
- Informações detalhadas de cada local

### 👤 Perfil
- Edite informações pessoais
- Altere senha com segurança
- Gerencie preferências de idioma
- Histórico de tours realizados

## 🏗️ Arquitetura

```
lib/
├── core/
│   ├── config/          # Configurações (URLs, endpoints)
│   ├── models/          # Modelos de dados
│   ├── providers/       # State management (Provider)
│   ├── routes/          # Navegação
│   ├── services/        # API e Storage
│   ├── theme/           # Tema verde para turistas
│   └── widgets/         # Widgets reutilizáveis
└── features/
    ├── auth/            # Login e registro
    ├── home/            # Tela principal
    ├── atrativos/       # Pontos turísticos
    ├── roteiros/        # Roteiros turísticos
    ├── agendamentos/    # Meus agendamentos
    ├── turista/         # Funcionalidades específicas
    │   ├── buscar_guias_page.dart
    │   ├── agendar_tour_page.dart
    │   ├── perfil_page.dart
    │   └── alterar_senha_page.dart
    └── splash/          # Tela inicial
```

## 🔧 Configuração

### Backend
```dart
// lib/core/config/app_config.dart
static const String baseUrl = 'http://localhost:3001/api';
```

### Para Emulador Android
```dart
static const String baseUrl = 'http://10.0.2.2:3001/api';
```

### Para Dispositivo Físico
```dart
static const String baseUrl = 'http://SEU_IP:3001/api';
```

## 🎯 Fluxo do Usuário

```
1. Login/Registro → 
2. Tela Principal (Menu Verde) → 
3. Escolher Funcionalidade:
   ├─ Buscar Guias → Selecionar Data → Agendar Tour
   ├─ Meus Agendamentos → Ver/Cancelar Tours
   ├─ Roteiros → Explorar no Mapa
   ├─ Pontos Turísticos → Ver Detalhes
   └─ Perfil → Editar Dados
```

## 🧪 Como Testar

### 1. Criar Conta de Turista
- Abra o app
- Toque em "Criar conta"
- Preencha os dados (sempre será tipo "turista")
- Faça login

### 2. Buscar Guias
- Na tela principal, toque em "Buscar Guias"
- Selecione uma data futura
- Escolha um horário
- Toque em "Buscar Guias"

### 3. Explorar Conteúdo
- "Roteiros Turísticos" - veja roteiros no mapa
- "Pontos Turísticos" - explore atrativos
- "Meus Agendamentos" - gerencie tours

## 🌟 Diferenciais

### Exclusivo para Turistas
- Interface otimizada para descoberta
- Foco na experiência do viajante
- Cores e ícones que remetem a aventura

### Experiência Simplificada
- Apenas funcionalidades relevantes para turistas
- Fluxo intuitivo de agendamento
- Informações claras sobre guias e tours

### Design Atrativo
- Tema verde que transmite confiança
- Cards com gradientes e ícones expressivos
- Interface moderna e responsiva

## 📊 Status do Projeto

### ✅ Implementado
- [x] Sistema de autenticação
- [x] Tela principal com menu turista
- [x] Buscar guias disponíveis
- [x] Agendar tours
- [x] Visualizar agendamentos
- [x] Explorar roteiros no mapa
- [x] Ver pontos turísticos
- [x] Editar perfil
- [x] Alterar senha
- [x] Tema verde personalizado

### 🚧 Em Desenvolvimento
- [ ] Integração com WhatsApp/telefone
- [ ] Sistema de avaliações
- [ ] Notificações push
- [ ] Histórico de tours
- [ ] Favoritos

## 🔗 Apps Relacionados

Este é parte do ecossistema TourGuides:
- **TourGuides Turista** (este app) - Para viajantes
- **TourGuides Guia** (separado) - Para guias turísticos
- **TourGuides Admin** (web) - Para administradores

## 📞 Suporte

Para dúvidas ou problemas:
- Verifique se o backend está rodando
- Confirme a configuração da API Key do Google Maps
- Teste a conectividade de rede

## 📄 Licença

MIT License - Veja o arquivo LICENSE para detalhes.

---

**Desenvolvido com ❤️ para turistas que amam explorar novos destinos!**
