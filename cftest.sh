#/bin/bash

. ~/.bash_profile

RESULT_PATH=./output/result.csv
TMP_RESULT_PATH=./output/result.tmp.csv
TMP_PATH=./output/best.tmp.txt
FINAL_PATH=./output/best.txt
PORT=2053
MAX_ITEM=5

init() {
  clean_tmp_file
  rm -f $RESULT_PATH
}

clean_tmp_file() {
  rm -f $TMP_PATH
  rm -f $TMP_RESULT_PATH
}

speedtest() {
  file=$1
  port=$2
  info=$3
	CloudflareST \
		-url 'https://speed.fatkun.cloudns.ch/50m' \
		-f $file \
		-tp $port \
		-n 100 \
		-o $TMP_RESULT_PATH \
		-sl 5 -dn $MAX_ITEM -tl 300 -tlr 0.2

	cat $TMP_RESULT_PATH >> $RESULT_PATH

	count=`cat $TMP_RESULT_PATH|awk -F',' 'NR>1 && $6>5 {print $1}'|wc -l`
	if [ "x0" = "x$count" ]; then
		echo "no result"
		return
	fi
	cat $TMP_RESULT_PATH|awk -F',' 'NR>1 && $6>5 {print $1":'$port'#'$info'"}'|head -5 >> $TMP_PATH
}

final_release() {
  mv $TMP_PATH $FINAL_PATH
  clean_tmp_file
}

upload() {
  git pull
	git add *.txt *.csv
	git commit -m 'update'
	git push
}

init
speedtest './input/ip.txt' $PORT "IPA"
speedtest './input/ip2.txt' $PORT "IPB"
final_release
upload
