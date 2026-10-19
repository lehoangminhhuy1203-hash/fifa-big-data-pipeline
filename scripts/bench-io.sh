#!/bin/bash
# Do toc do GHI / DOC cua HDFS. Chay BEN TRONG container namenode
# (demo-velocity.bat tu copy file nay vao container roi goi).
#
#   bash bench-io.sh write <so_MB> <replication> <nhan>
#   bash bench-io.sh read  <nhan>
#
# Moi lan chay in DUNG 1 dong ket qua CSV ra stdout:
#   thoi_diem,phep_do,nhan,replication,bytes,giay,MB_per_s
# Thong bao tien trinh in ra stderr (hien tren man hinh, khong lan vao file CSV).

F=/fifa/raw/players/gender=male/male_players.csv
SRC=/data/raw/male_players.csv
TMP=/tmp/bench_sample.bin

now()  { date +%s.%N; }
secs() { awk -v a="$1" -v b="$2" 'BEGIN{printf "%.2f", b-a}'; }
mbps() { awk -v n="$1" -v s="$2" 'BEGIN{printf "%.1f", n/1048576/s}'; }
stamp(){ date '+%Y-%m-%d %H:%M:%S'; }

case "$1" in
  write)
    MB=${2:-1024}; REP=${3:-3}; LABEL=${4:-write}
    # Chuan bi du lieu mau tren o dia cua container (khong tinh gio),
    # de chi do toc do HDFS chu khong do toc do doc o D: cua Windows.
    if [ ! -f "$TMP" ] || [ "$(stat -c %s "$TMP")" -ne $((MB*1048576)) ]; then
      echo "  Chuan bi $MB MB du lieu mau..." >&2
      head -c $((MB*1048576)) "$SRC" > "$TMP"
    fi
    hdfs dfs -mkdir -p /bench
    hdfs dfs -rm -f -skipTrash /bench/write_test >/dev/null 2>&1
    echo "  Dang ghi $MB MB len HDFS voi replication=$REP ..." >&2
    t0=$(now)
    hdfs dfs -D dfs.replication="$REP" -put "$TMP" /bench/write_test
    t1=$(now)
    BYTES=$(stat -c %s "$TMP")
    hdfs dfs -rm -f -skipTrash /bench/write_test >/dev/null 2>&1
    ;;
  read)
    LABEL=${2:-read}; REP=$(hdfs dfs -stat %r "$F")
    BYTES=$(hdfs dfs -stat %b "$F")
    echo "  Dang doc toan bo male_players.csv ($((BYTES/1048576)) MB) tu HDFS ..." >&2
    t0=$(now)
    hdfs dfs -cat "$F" > /dev/null
    t1=$(now)
    ;;
  cleanup)
    rm -f "$TMP"; hdfs dfs -rm -r -f -skipTrash /bench >/dev/null 2>&1
    exit 0
    ;;
  *)
    echo "Cach dung: bench-io.sh write <MB> <replication> <nhan> | read <nhan> | cleanup" >&2
    exit 1
    ;;
esac

S=$(secs "$t0" "$t1"); R=$(mbps "$BYTES" "$S")
echo "  => $S giay, $R MB/s" >&2
echo "$(stamp),$1,$LABEL,$REP,$BYTES,$S,$R"
