# Troubleshooting - Login

## 🔍 Checklist de Diagnóstico

### 1. Backend está rodando?
```bash
curl http://localhost:3001/api/health
```
**Esperado:** `{"status":"OK",...}`

### 2. Usuário de teste existe?
```bash
# Criar usuário
curl -X POST http://localhost:3001/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Usuario Teste","email":"teste@teste.com","cpf":"12345678901","senha":"123456","telefone":"11999999999","tipo":"turista"}'
```

### 3. Login funciona via API?
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"emailOrDocument":"teste@teste.com","senha":"123456"}'
```
**Esperado:** `{"token":"...","usuario":{...}}`

### 4. App está usando a URL correta?
- **Emulador Android:** `http://10.0.2.2:3001/api`
- **Dispositivo Físico:** `http://SEU_IP:3001/api`

Verificar em: `lib/core/config/app_config.dart`

### 5. Permissão de Internet?
Verificar em `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## 🐛 Problemas Comuns

### "Failed to connect" / "SocketException"
**Causa:** App não consegue conectar ao backend

**Soluções:**
1. Verificar se backend está rodando
2. Usar `10.0.2.2` para emulador (não `localhost`)
3. Para dispositivo físico, usar IP do computador
4. Garantir que estão na mesma rede WiFi

### "Erro 401: Unauthorized"
**Causa:** Credenciais incorretas ou usuário não existe

**Solução:**
```bash
# Criar usuário de teste
curl -X POST http://localhost:3001/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nome":"Usuario Teste","email":"teste@teste.com","cpf":"12345678901","senha":"123456","telefone":"11999999999","tipo":"turista"}'
```

### "Erro 404: Not Found"
**Causa:** Endpoint incorreto

**Solução:** Verificar `baseUrl` em `app_config.dart`

### App trava no loading
**Causa:** Timeout na requisição

**Soluções:**
1. Verificar logs do Flutter: `flutter logs`
2. Verificar se backend está respondendo
3. Aumentar timeout (se necessário)

## 📱 Debug no App

### Ver logs do Flutter
```bash
flutter logs
```

### Logs adicionados no código
O código agora tem logs de debug:
- 🔐 Tentando login
- 📡 URL da requisição
- ✅ Resposta recebida
- 💾 Salvando dados
- ❌ Erros

### Executar teste de conexão
```bash
dart test_connection.dart
```

## 🔧 Resetar App

Se nada funcionar:
```bash
flutter clean
flutter pub get
flutter run
```

## 🗺️ Avisos do Google Maps

### "Cannot enable MyLocation layer"
**Aviso:** `E/GoogleMapController: Cannot enable MyLocation layer as location permissions are not granted`

**Causa:** Permissões de localização não concedidas

**Solução:** 
- ✅ Não é um erro! O app funciona normalmente
- ✅ Permissões são opcionais
- ✅ Veja: `LOCATION_PERMISSIONS.md`

### "No TextureView found"
**Aviso:** `I/GoogleMapController: No TextureView found. Likely using the LEGACY renderer.`

**Causa:** Renderizador legado do Google Maps

**Solução:**
- ✅ Apenas informativo, não afeta funcionamento
- ✅ Pode ser ignorado

## 📞 Ainda com problemas?

1. Verificar logs: `flutter logs`
2. Verificar backend: logs do servidor
3. Testar API manualmente (curl/Postman)
4. Verificar firewall/antivírus
5. Ver: `LOCATION_PERMISSIONS.md` para avisos de localização
