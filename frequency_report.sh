#!/bin/bash
# Author: Divye Kapoor (divyekapoor@gmail.com)
#
# This work is being released under the MIT Licence.
#
# Copyright (c) 2016 Divye Kapoor (divyekapoor@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

iconv -c -f utf-8 -t ascii JaneEyre.txt | tr 'A-Z' 'a-z' | tr -s "\n\r." " " |  tr -d "#%\$^@*_;?:.,\'\"/-\!()&[]{}" | tr -s ' ' '\n' > JaneEyre.normalized.txt &
iconv -c -f utf-8 -t ascii WutheringHeights.txt | tr 'A-Z' 'a-z' | tr -s "\n\r." " " |  tr -d "#%\$^@*_;?:.,\'\"/-\!()&[]{}" | tr -s ' ' '\n' > WutheringHeights.normalized.txt &
wait
cat JaneEyre.normalized.txt WutheringHeights.normalized.txt > CombinedWorks.normalized.txt

cat JaneEyre.normalized.txt | sort | uniq -c | awk -F' ' "{ freq = \$1; word = \$2; total_words = $(wc -w < JaneEyre.normalized.txt); relative_freq = freq / total_words; print word \",\" freq \",\" relative_freq; }" | sort  > JaneEyre.report.txt &

cat WutheringHeights.normalized.txt | sort | uniq -c | awk -F' ' "{ freq = \$1; word = \$2; total_words = $(wc -w < WutheringHeights.normalized.txt); relative_freq = freq / total_words; print word \",\" freq \",\" relative_freq; }" | sort > WutheringHeights.report.txt &

cat CombinedWorks.normalized.txt | sort | uniq -c | sort -rn | head -1000 | awk -F' ' "{ print \$2 \",\" \$1 }" | sort > CombinedWorks.report.txt &
wait

join -t, CombinedWorks.report.txt JaneEyre.report.txt  > JoinedFrequencies.partial.txt
join -t, -v1 CombinedWorks.report.txt JaneEyre.report.txt | sed -e 's/$/,0,0/' >> JoinedFrequencies.partial.txt
sort < JoinedFrequencies.partial.txt > JoinedFrequencies.partial_sorted.txt

join -t, JoinedFrequencies.partial_sorted.txt WutheringHeights.report.txt > JoinedFrequencies.all.txt
join -t, -v1 JoinedFrequencies.partial_sorted.txt WutheringHeights.report.txt | sed -e 's/$/,0,0/' >> JoinedFrequencies.all.txt
sort < JoinedFrequencies.all.txt > JoinedFrequencies.all_sorted.txt

awk -F, '{ print $4 - $6 " " $1 }' < JoinedFrequencies.all_sorted.txt | sort -n > DistinctiveWords.txt

echo "DistinctiveWords for JaneEyre"
echo "============================="
tail -10 DistinctiveWords.txt | awk '{ print $2 }'
echo
echo "Distinctive words for WutheringHeights"
echo "======================================"
head -10 DistinctiveWords.txt | awk '{ print $2 }'
