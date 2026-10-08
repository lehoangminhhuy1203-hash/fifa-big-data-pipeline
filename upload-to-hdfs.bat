@echo off
echo ============================================
echo  DUA DU LIEU FIFA LEN HDFS
echo ============================================
echo.
echo [1/5] Tao cau truc thu muc tren HDFS...
docker exec namenode hdfs dfs -mkdir -p /fifa/raw/players/gender=male /fifa/raw/players/gender=female /fifa/raw/teams/gender=male /fifa/raw/teams/gender=female /fifa/raw/coaches/gender=male /fifa/raw/coaches/gender=female /fifa/clean /fifa/curated
if errorlevel 1 (
  echo LOI: Khong ket noi duoc namenode. Hay chay start-cluster.bat truoc.
  pause
  exit /b 1
)
echo [2/5] Upload teams va coaches...
docker exec namenode hdfs dfs -put -f /data/raw/male_teams.csv      /fifa/raw/teams/gender=male/
docker exec namenode hdfs dfs -put -f /data/raw/female_teams.csv    /fifa/raw/teams/gender=female/
docker exec namenode hdfs dfs -put -f /data/raw/male_coaches.csv    /fifa/raw/coaches/gender=male/
docker exec namenode hdfs dfs -put -f /data/raw/female_coaches.csv  /fifa/raw/coaches/gender=female/
echo [3/5] Upload female_players.csv (94 MB)...
docker exec namenode hdfs dfs -put -f /data/raw/female_players.csv  /fifa/raw/players/gender=female/
echo [4/5] Upload male_players.csv (5.6 GB) - mat khoang 5-20 phut, DUNG TAT CUA SO NAY...
echo       Bat dau luc: %time%
docker exec namenode hdfs dfs -put -f /data/raw/male_players.csv    /fifa/raw/players/gender=male/
echo       Xong luc:    %time%
echo.
echo [5/5] Kiem tra ket qua:
docker exec namenode hdfs dfs -ls -R -h /fifa/raw
echo.
echo Tong dung luong (truoc nhan ban):
docker exec namenode hdfs dfs -du -s -h /fifa/raw
echo.
echo HOAN TAT. Mo http://localhost:50070 -^> Datanodes de xem cot Blocks.
pause
