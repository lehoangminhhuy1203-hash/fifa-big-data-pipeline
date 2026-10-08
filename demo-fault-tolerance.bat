@echo off
chcp 65001 >nul
cd /d "%~dp0..\docker"
set F=/fifa/raw/players/gender=male/male_players.csv
echo ==========================================================
echo  DEMO CHIU LOI HDFS  (chup man hinh sau moi buoc!)
echo ==========================================================
echo.
echo [BUOC 0] Ap dung cau hinh moi va dam bao 3 DataNode dang chay...
docker compose up -d namenode datanode1 datanode2 datanode3
timeout /t 40 /nobreak >nul
docker exec namenode hdfs dfsadmin -safemode wait
echo.
echo [BUOC 1] TRANG THAI BAN DAU
docker exec namenode hdfs dfsadmin -report | findstr /C:"datanodes"
echo --- Checksum file goc (dung de so sanh sau khi mat node):
docker exec namenode hdfs dfs -checksum %F%
echo.
pause
echo.
echo [BUOC 2] GIA LAP SU CO: TAT HAN datanode3
docker stop datanode3
echo.
echo Doc TOAN BO file 5.6 GB khi chi con 2 node (mat 1-3 phut)...
docker exec namenode bash -c "time hdfs dfs -cat %F% | wc -l"
echo --- Checksum sau su co (phai GIONG HET buoc 1):
docker exec namenode hdfs dfs -checksum %F%
echo =^> Du lieu van doc duoc day du du mat 1 node.
echo.
pause
echo.
echo [BUOC 3] Cho NameNode phat hien node chet (~90 giay)...
timeout /t 100 /nobreak
docker exec namenode hdfs dfsadmin -report | findstr /C:"datanodes"
docker exec namenode hdfs fsck /fifa -files | findstr /C:"Status" /C:"Under-replicated blocks" /C:"Average block replication" /C:"Number of data-nodes"
echo =^> Cac block bi THIEU BAN SAO (under-replicated), nhung KHONG MAT du lieu.
echo    Mo http://localhost:50070 -^> Datanodes de thay node "Dead". Chup man hinh!
echo.
pause
echo.
echo [BUOC 4] MO RONG CUM: them datanode4 - HDFS se TU NHAN BAN lai block bi thieu
docker compose --profile scale up -d datanode4
echo Cho HDFS tu sao chep lai (2-4 phut)...
timeout /t 180 /nobreak
docker exec namenode hdfs fsck /fifa -files | findstr /C:"Status" /C:"Under-replicated blocks" /C:"Average block replication" /C:"Number of data-nodes"
echo =^> Neu Under-replicated van ^> 0, cho them 1-2 phut roi chay lai lenh fsck.
echo    Mo trang Datanodes: datanode4 da nhan khoang 47 block. Chup man hinh!
echo.
pause
echo.
echo [BUOC 5] KHOI PHUC: bat lai datanode3, tat datanode4
docker start datanode3
timeout /t 60 /nobreak >nul
docker compose --profile scale stop datanode4
echo Cho HDFS can bang lai (2-3 phut)...
timeout /t 150 /nobreak
docker exec namenode hdfs fsck /fifa -files | findstr /C:"Status" /C:"Under-replicated blocks" /C:"Average block replication"
echo.
echo HOAN TAT DEMO. (datanode4 se con hien "Dead" tren Web UI cho toi lan khoi dong lai NameNode - binh thuong.)
pause
