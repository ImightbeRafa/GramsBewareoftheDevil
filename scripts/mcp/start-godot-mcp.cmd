@echo off
setlocal
cd /d "%~dp0..\.."
if not exist "node_modules\@satelliteoflove\godot-mcp\dist\cli.js" (
  echo [godot-mcp] node_modules missing. Run: npm install
  exit /b 1
)
node "node_modules\@satelliteoflove\godot-mcp\dist\cli.js"
