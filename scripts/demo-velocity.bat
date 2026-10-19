@echo off
chcp 65001 >nul
cd /d "%~dp0..\docker"
set OUTDIR=%~dp0..\reports\velocity
set OUT=%OUTDIR%\io_benchmark.csv
if not exist "%OUTDIR%" mkdir "%OUTDIR%"
if not exist "%OUT%" echo thoi_diem,phep_do,nhan,replication,bytes,giay,MB_per_s> "%OUT%"
echo ==========================================================
echo  VELOCITY - DO TOC DO GHI / DOC CUA HDFS
echo  Ket qua luu vao: reports\velocity\io_benchmark.csv
echo ==========================================================
echo.
echo [BUOC 0] Dam bao cum du 3 DataNode...
docker compose up -d namenode datanode1 datanode2 datanode3
docker exec namenode hdfs dfsadmin -safemode wait
docker cp "%~dp0bench-io.sh" namenode:/tmp/bench-io.sh
if errorlevel 1 (
  echo LOI: Khong ket noi duoc namenode. Hay chay start-cluster.bat truoc.
  pause
  exit /b 1
)
echo.
echo [BUOC 1] TOC DO GHI: 1 GB, so sanh replication 1 va 3
echo    Replication 3 phai ghi gap 3 lan du lieu qua pipeline 3 node, nen se cham hon.
docker exec namenode bash /tmp/bench-io.sh write 1024 1 "ghi 1GB" >> "%OUT%"
docker exec namenode bash /tmp/bench-io.sh write 1024 3 "ghi 1GB" >> "%OUT%"
echo.
pause
echo.
echo [BUOC 2] TOC DO DOC: doc toan bo 5.6 GB khi du 3 node (mat 1-3 phut)
docker exec namenode bash /tmp/bench-io.sh read "doc 5.6GB - 3 node" >> "%OUT%"
echo.
pause
echo.
echo [BUOC 3] TOC DO DOC KHI MAT 1 NODE: tat datanode3 roi doc lai
docker stop datanode3
docker exec namenode bash /tmp/bench-io.sh read "doc 5.6GB - 2 node" >> "%OUT%"
echo    Bat lai datanode3...
docker start datanode3
echo.
echo [BUOC 4] Don dep file tam
docker exec namenode bash /tmp/bench-io.sh cleanup
echo.
echo ==================== KET QUA ====================
type "%OUT%"
echo.
echo Chup man hinh bang ket qua nay cho bao cao.
echo (Chay lai file nay nhieu lan thi ket qua duoc noi them vao cuoi file CSV.)
pause
