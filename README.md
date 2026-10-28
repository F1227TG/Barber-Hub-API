# Barber Hub API

Backend independente do Barber Hub: FastAPI, regras de negócio, integração Supabase, migrations e testes. Extraído de `F1227TG/Barber-Hub-Oficial` em 27/10/2026. Não contém interface web nem credenciais.

## Desenvolvimento

Python 3.13 e uv:

```sh
uv sync --locked
uv run fastapi dev api/index.py
uv run python -m unittest discover -s tests -v
npm ci
npm run check:database
```

Configure as variáveis de `.env.example` no ambiente do processo ou em `.env` local e inicie com `uv run uvicorn api.index:app --env-file .env`. Nunca versionar o arquivo preenchido. `/api/v1/health` informa prontidão de configuração; não prova sozinho acesso ao banco nem aplicação das migrations.

## Contrato e publicação

As rotas permanecem em `/api/v1`, documentação em `/api/docs` e `/api/openapi.json`. `tests/contracts/openapi-baseline.json` protege os contratos existentes. `vercel.json` configura o servidor Python e o job diário de manutenção.

1. Importe este repositório em um projeto Vercel exclusivo da API.
2. Configure os segredos no projeto backend, mantendo o mesmo Supabase do Barber Hub. Não crie um banco vazio para substituir o atual.
3. Confira o estado das migrations e particularmente `20261022155131_modernizacao_contas_administrativas`: autenticação privada depende de `sessao_conta_ativa`. O arquivo existir não comprova aplicação remota.
4. Valide health, public-config, login, perfil autenticado, permissões e operações antes de trocar o tráfego.
5. No frontend, use um proxy de mesma origem para o domínio real desta API (preserva CAPTCHA, CSP e URLs PWA). Se optar por acesso direto, configure CORS, CSP e `BARBER_HUB_API_BASE_URL` juntos.
6. Transfira o cron para este deploy e desative o antigo na mesma troca, evitando dois agendadores.

Até a publicação e validação desta API, a cópia no repositório web permanece como compatibilidade do deploy existente. Este repositório é o destino independente preparado; a troca de tráfego ainda não ocorreu.

Migrations históricas foram preservadas, não reaplicadas. Execute apenas as pendentes identificadas pelo histórico do projeto, com backup e validação. Google OAuth continua dependente da configuração no painel, conforme a preparação anterior.
