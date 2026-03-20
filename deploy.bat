@echo off
echo 启动时间管理助手Web服务...

cd c:\Users\xiangtu\Desktop\TimeManager\TimeManager\zl\time_manager_client\build\web

echo 📍 本地访问地址：http://localhost:8080
echo 🌐 公网访问方案：
echo   1. 使用localtunnel: npm install -g localtunnel && lt --port 8080
echo   2. 使用serveo: ssh -R 80:localhost:8080 serveo.net
echo   3. 部署到Vercel: 推送代码到GitHub后在vercel.com导入
echo.

echo 🚀 启动本地Web服务器...
echo 📱 请在浏览器中访问：http://localhost:8080
echo ⏹️  按 Ctrl+C 停止服务器
echo.

:: 尝试使用Python服务器，如果失败使用PowerShell
python -m http.server 8080

pause