@echo off
cd /d "%~dp0..\docker"
echo ============================================
echo  KHOI DONG CUM HDFS (3 DataNode) + JUPYTER
echo ============================================
docker compose up -d namenode datanode1 datanode2 datanode3 jupyter
if errorlevel 1 (
  echo.
  echo LOI: Docker chua chay? Hay mo Docker Desktop, cho "Engine running" roi chay lai file nay.
  pause
  exit /b 1
)
echo.
echo Cho NameNode khoi dong (30 giay)...
timeout /t 30 /nobreak >nul
docker exec namenode hdfs dfsadmin -safemode wait
echo.
docker ps --format "table {{.Names}}\t{{.Status}}"
echo.
echo  HDFS Web UI : http://localhost:50070
echo  Jupyter     : http://localhost:8889/?token=bigdata
echo.
pause
