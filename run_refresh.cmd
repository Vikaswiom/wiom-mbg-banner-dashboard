@echo off
cd /d "%~dp0"
python "%~dp0refresh.py" >> "%~dp0refresh.log" 2>&1
echo [exit %ERRORLEVEL%] %DATE% %TIME% >> "%~dp0refresh.log"
