# 🔐 SECURITY.md - Guia de Segurança do Projeto

## ⚠️ INFORMAÇÕES SENSÍVEIS - NUNCA COMMITADAS

Este documento lista **TODOS** os arquivos e informações que **JAMAIS** devem ser commitados no repositório público.

### 📝 Arquivos Protegidos pelo .gitignore

#### 🔑 Variáveis de Ambiente
- `.env` - **PRINCIPAL**: Contém todas as chaves de API
- `.env.local`, `.env.production`, `.env.staging` - Variantes por ambiente
- `secrets/`, `keys/`, `credentials/` - Diretórios com informações sensíveis

#### 🔥 Firebase
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
- `firebase_options.dart` (Flutter gerado)
- Qualquer arquivo com `firebase` no nome

#### 💰 AdMob/AdSense
- IDs de unidades de anúncios
- Chaves de publisher
- Configurações de monetização

#### 🔐 Certificados de Assinatura
- `*.keystore` - Keystores Android
- `*.jks` - Java KeyStores
- `key.properties` - Propriedades de assinatura Android
- `*.p12` - Certificados iOS
- `*.mobileprovision` - Provisioning profiles iOS

### 🚨 CHECKLIST ANTES DE COMMITAR

Antes de cada commit, verifique:

- [ ] `.env` não está no staging area
- [ ] Nenhum arquivo com passwords/keys foi adicionado
- [ ] Logs não contêm informações sensíveis
- [ ] Screenshots não mostram dados reais
- [ ] Comentários no código não têm TODOs com informações sensíveis

### 🛡️ Boas Práticas

#### ✅ FAZER:
- Usar `AppConfig` para acessar variáveis
- Manter `.env.example` atualizado (sem valores reais)
- Documentar novas variáveis de ambiente
- Revisar PRs para vazamentos acidentais

#### ❌ NÃO FAZER:
- Hardcodar chaves de API no código
- Commitar arquivos de backup (.bak, .backup)
- Deixar TODOs com informações sensíveis
- Compartilhar screenshots com dados reais

### 🚒 VAZAMENTO ACIDENTAL - PLANO DE EMERGÊNCIA

Se acidentalmente commitou informações sensíveis:

1. **IMEDIATAMENTE**: Revogue/regenere todas as chaves expostas
2. **Firebase**: Regenere configurações no console
3. **AdMob**: Revogue e crie novas unidades de anúncio
4. **Git**: Use `git filter-branch` ou BFG para limpar histórico
5. **Notifique**: Equipe sobre o incidente

### 📞 Contatos de Emergência

- **Firebase Support**: https://firebase.google.com/support
- **Google AdMob**: https://support.google.com/admob
- **Play Console**: https://support.google.com/googleplay

---

**⚠️ LEMBRE-SE: Uma chave vazada pode comprometer todo o projeto!**