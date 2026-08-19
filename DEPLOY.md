# 🚀 Guia de Implantação e Deploy em Produção — Via Audit

Este documento é o guia definitivo para realizar o deploy em produção da infraestrutura backend via **Docker Compose** e publicar o aplicativo mobile **Flutter** nas lojas de aplicativos (**Google Play Store** e **Apple App Store**).

---

## 🏗️ Arquitetura de Produção

```
┌────────────────────────────────────────────────────────┐
│               CLARO / SERVIDOR VPS (Linux)             │
│                                                        │
│   ┌──────────────────┐          ┌──────────────────┐   │
│   │   Docker API     │ ───────> │   Docker MySQL   │   │
│   │   (Node.js:3000) │ <─────── │   (MySQL:3306)   │   │
│   └──────────────────┘          └──────────────────┘   │
└─────────────▲──────────────────────────────────────────┘
              │ SSL HTTPS (Nginx / Domain)
              │
    ┌─────────┴─────────┐
    │  APLICATIVO MOBILE│
    │ (Android & iOS)   │
    └───────────────────┘
```

---

## 🐋 PARTE 1: Deploy do Backend e Banco de Dados via Docker

### Requisitos no Servidor VPS (Ubuntu/Debian)
- Docker & Docker Compose instalados.
- Domínio ou IP público apontado para a VPS (ex: `api.viaaudit.com.br`).

### Passo a Passo de Execução

1. **Clonar o Repositório no Servidor**:
   ```bash
   git clone https://github.com/seu-usuario/app-ag.git /var/www/app-ag
   cd /var/www/app-ag
   ```

2. **Configurar as Variáveis de Ambiente**:
   ```bash
   cp via-audit-api/.env.example .env
   # Editar as credenciais seguras no arquivo .env se necessário
   nano .env
   ```

3. **Gerar a Carga Inicial de Dados (Seed Data)**:
   ```bash
   node scripts/build_data.js
   ```

4. **Subir os Containers em Background**:
   ```bash
   docker-compose up -d --build
   ```

5. **Verificar o Status da API e Logs**:
   ```bash
   docker-compose ps
   docker-compose logs -f api
   ```
   *Healthcheck de teste*: `curl http://localhost:3000/api/health`

---

## 🔒 PARTE 2: Configurar HTTPS com Nginx e SSL (Let's Encrypt)

Para que o iOS e o Android aceitem conexões seguras de produção, configure o Nginx como Proxy Reverso:

1. **Instalar Nginx e Certbot**:
   ```bash
   sudo apt update && sudo apt install -y nginx certbot python3-certbot-nginx
   ```

2. **Criar arquivo de configuração em `/etc/nginx/sites-available/via-audit`**:
   ```nginx
   server {
       server_name api.viaaudit.com.br;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           client_max_body_size 50M;
       }
   }
   ```

3. **Ativar o site e Gerar Certificado SSL**:
   ```bash
   sudo ln -s /etc/nginx/sites-available/via-audit /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   sudo certbot --nginx -d api.viaaudit.com.br
   ```

---

## 📲 PARTE 3: Publicação do Aplicativo Mobile nas Lojas

### 🤖 1. Android (Google Play Store)

1. Ajustar a URL base da API em `lib/core/api/api_client.dart`:
   ```dart
   static const String baseUrl = 'https://api.viaaudit.com.br/api';
   ```

2. Gerar a Chave de Assinatura (Keystore):
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```

3. Gerar o arquivo App Bundle (`.aab`):
   ```bash
   cd via_audit
   flutter build appbundle --release
   ```
   *Arquivo gerado*: `build/app/outputs/bundle/release/app-release.aab`
4. Fazer upload do arquivo `.aab` no **Google Play Console**.

---

### 🍎 2. iOS (Apple App Store)

1. Abrir o projeto iOS no Xcode (em um macOS):
   ```bash
   cd via_audit/ios
   open Runner.xcworkspace
   ```
2. Configurar a **Signing & Capabilities** com a sua conta de Desenvolvedor Apple (`Team` e `Bundle Identifier`).
3. Gerar o arquivo de distribuição (`.ipa`):
   ```bash
   cd via_audit
   flutter build ipa --release
   ```
4. Fazer o upload via **Transporter** ou **Xcode Organizer** para o **App Store Connect**.

---

## 🔑 Resumo das Credenciais Padrão do Sistema

- **Administrador**: PIN `873914` (Acesso completo ao Dashboard e exportação de PDF/Excel).
- **Orientadores**: PINs numéricos de 6 dígitos contidos no arquivo `orientadores_credenciais.json`.
