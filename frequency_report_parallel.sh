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

# Stop executing on error. Optional if you're running this line by line.
set -e

# Normalize the input texts:
# Step 1: Convert to ascii from utf-8.
# Step 2: Lowercase all the characters.
# Step 3: Replace all periods and newlines with a space, squeezing adjacent spaces.
# Step 4: Delete all the special characters.
# Step 5: Replace all spaces by newlines, making the text 1 word per line.
#         Output the contents to a temp file.
iconv -c -f utf-8 -t ascii JaneEyre.txt | tr 'A-Z' 'a-z' | tr -s "\n\r." " " |  tr -d "#%\$^@*_;?:.,\'\"/-\!()&[]{}" | tr -s ' ' '\n' > JaneEyre.normalized.tmp &
iconv -c -f utf-8 -t ascii WutheringHeights.txt | tr 'A-Z' 'a-z' | tr -s "\n\r." " " |  tr -d "#%\$^@*_;?:.,\'\"/-\!()&[]{}" | tr -s ' ' '\n' > WutheringHeights.normalized.tmp &
wait

# Concatenate the two normalized texts into a single CombinedWork.
cat JaneEyre.normalized.tmp WutheringHeights.normalized.tmp > CombinedWorks.normalized.tmp &

# Gather statistics from each normalized work in the following format:
# word,word_frequency,relative_frequency
# Step 1: Sort the wordlist from each text.
# Step 2: Uniquify the wordlist into |count <space> word| format (one per line).
# Step 3a: Using wc, calculate the total number of words in the normalized text and insert it into the awk script.
# Step 3b: awk generates a CSV file in the format: |word,freq,relative_freq|.
# Step 4: Sort each line alphabetically and save it to a temp file. This generates a temp file sorted by words.
sort < JaneEyre.normalized.tmp | uniq -c | awk -F' ' "{ freq = \$1; word = \$2; total_words = $(wc -w < JaneEyre.normalized.tmp); relative_freq = freq / total_words; print word \",\" freq \",\" relative_freq; }" | sort -t,  > JaneEyre.report.tmp &
sort < WutheringHeights.normalized.tmp | uniq -c | awk -F' ' "{ freq = \$1; word = \$2; total_words = $(wc -w < WutheringHeights.normalized.tmp); relative_freq = freq / total_words; print word \",\" freq \",\" relative_freq; }" | sort -t, > WutheringHeights.report.tmp &
wait

# Generate top 1000 words by absolute frequency
# Step 1: Use awk to print in |absolute_frequency<space>word,freq,relative_freq|.
# Step 2: Sort in descending order numerically.
# Step 3: Pick the top 1000.
# Step 4: Select just the CSV part of the line and output to a report file.
awk -F, '{ print $2 " " $0; }' < JaneEyre.report.tmp | sort -rn | head -1000 | awk '{ print $2 }' > JaneEyre.csv &
awk -F, '{ print $2 " " $0; }' < WutheringHeights.report.tmp | sort -rn | head -1000 | awk '{ print $2 }' > WutheringHeights.csv &

# Gather statistics for the combined work (top 1000 words):
# Step 1: Sort the bag of words.
# Step 2: Uniquify the bag of words into the |count word| format.
# Step 3: Sort numerically in descending order (by frequency count).
# Step 4: Pick the first 1000 entries.
# Step 5: Reformat the entries into |word,frequency| format.
sort < CombinedWorks.normalized.tmp | uniq -c | sort -rn | head -1000 | awk -F' ' "{ print \$2 \",\" \$1 }" | sort -t, > CombinedWorks.csv &
wait

# Join statistics for the top 1000 words for the words from the combined work and JaneEyre.
# The first command joins words that are common to the top 1000 of the CombinedWork and JaneEyre.
# The second command prints words that are present only in the CombinedWork (replacing missing values with 0).
# The third command sorts the entire joined dataset again by words.
join -t, CombinedWorks.csv JaneEyre.report.tmp  > JoinedFrequencies.partial.tmp
join -t, -v1 CombinedWorks.csv JaneEyre.report.tmp | sed -e 's/$/,0,0/' >> JoinedFrequencies.partial.tmp
sort -t, < JoinedFrequencies.partial.tmp > JoinedFrequencies.partial_sorted.tmp

# Repeat the dataset join (by word) with the WutheringHeights dataset.
join -t, JoinedFrequencies.partial_sorted.tmp WutheringHeights.report.tmp > JoinedFrequencies.all.tmp
join -t, -v1 JoinedFrequencies.partial_sorted.tmp WutheringHeights.report.tmp | sed -e 's/$/,0,0/' >> JoinedFrequencies.all.tmp
sort -t, < JoinedFrequencies.all.tmp > JoinedFrequencies.all_sorted.tmp

# Step 1: Take the difference between the relative_frequencies between the JaneEyre dataset and the WutheringHeights
# for each of the top 1000 words.
# Step 2: Sort numerically according to the difference. Words with a positive
# score are more distinctive for JaneEyre. Words with a negative score are more
# so for WutheringHeights. Save to a temp file.
awk -F, '{ printf "%.8f %s\n", $4 - $6, $1 }' < JoinedFrequencies.all_sorted.tmp | sort -n > DistinctiveWords.report.txt

echo "Top 10 words by frequency for JaneEyre"
echo "======================================"
head -10 JaneEyre.csv
echo
echo "Top 10 words by frequency for WutheringHeights"
echo "=============================================="
head -10 WutheringHeights.csv
echo
echo "DistinctiveWords for JaneEyre"
echo "============================="
tail -10 DistinctiveWords.report.txt | awk '{ print $2 }'
echo
echo "Distinctive words for WutheringHeights"
echo "======================================"
head -10 DistinctiveWords.report.txt | awk '{ print $2 }'

# Clean up temp files.
# rm *.tmp
