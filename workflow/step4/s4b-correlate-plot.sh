grep "Task " correlation.txt | sort -k 8 -n | awk '{ print $8 " " $4 }' > correlation.data
