@echo off
cd /d "%~dp0"
"C:\Users\Vikas Diwaker\AppData\Local\Programs\Python\Python310\python.exe" "%~dp0refresh.py" >> "%~dp0refresh.log" 2>&1
echo [exit %ERRORLEVEL%] %DATE% %TIME% >> "%~dp0refresh.log"
