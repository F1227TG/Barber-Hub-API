@echo off
setlocal
cd /d "%~dp0"

set "PYTHON=%CD%\.venv\Scripts\python.exe"

if not exist "%PYTHON%" (
  echo [ERRO] Nao encontrei .venv\Scripts\python.exe neste repositorio.
  echo Crie a venv com Python 3.13: py -3.13 -m venv .venv
  exit /b 1
)

"%PYTHON%" -c "import sys; print('Python da venv:', sys.version.split()[0]); sys.exit(0 if (3, 13) <= sys.version_info[:2] < (3, 15) else 1)"
if errorlevel 1 (
  echo [ERRO] A API exige Python 3.13 ou 3.14.
  echo Nao alterei sua venv. Crie outra com Python 3.13.
  exit /b 1
)

"%PYTHON%" -c "import fastapi, uvicorn, httpx, pydantic, pywebpush" >nul 2>&1
if errorlevel 1 goto install_dependencies
goto verify_imports

:install_dependencies
echo [INFO] Dependencias ausentes. Tentando instalar na venv existente...
where uv >nul 2>&1
if not errorlevel 1 (
  uv pip install --python "%PYTHON%" -r requirements.txt
  if not errorlevel 1 goto verify_imports
  echo [AVISO] A instalacao pelo uv falhou. Tentando pip...
)

"%PYTHON%" -m pip --version >nul 2>&1
if errorlevel 1 (
  echo [INFO] pip nao encontrado na venv. Tentando ensurepip...
  "%PYTHON%" -m ensurepip --upgrade
  if errorlevel 1 goto ensurepip_failed
)
"%PYTHON%" -m pip install -r requirements.txt
if errorlevel 1 goto install_failed

:verify_imports
"%PYTHON%" -c "from api.index import app; import uvicorn; print('Aplicacao carregada:', app.title)"
if errorlevel 1 (
  echo [ERRO] A API nao pode ser importada. Verifique o traceback acima.
  exit /b 1
)

echo [OK] Iniciando Barber Hub API em http://127.0.0.1:8000/api/docs
if exist ".env" (
  "%PYTHON%" -m uvicorn api.index:app --reload --host 127.0.0.1 --port 8000 --env-file ".env"
) else (
  echo [AVISO] Arquivo .env nao encontrado. Endpoints Supabase exigem configuracao.
  "%PYTHON%" -m uvicorn api.index:app --reload --host 127.0.0.1 --port 8000
)
exit /b %errorlevel%

:ensurepip_failed
echo [ERRO] Nao foi possivel instalar pip nesta venv.
echo Instale uv e execute: uv pip install --python ".venv\Scripts\python.exe" -r requirements.txt
exit /b 1

:install_failed
echo [ERRO] Falha ao instalar as dependencias. Leia a mensagem acima.
echo Verifique sua conexao, Python da venv e configuracao de proxy/SSL.
exit /b 1
