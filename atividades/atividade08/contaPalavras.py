import sys
import re

words={}

with open(sys.argv[1], 'r') as f:
    for line in f:
        for word in re.findall('\w+[-\w+]*', line):
            word = word.lower()
            if word in words:
                words[word] += 1
            else:
                words[word] = 1

words = dict(sorted(words.items(), key=lambda item: item[1]))

for word in words:
    print(f"{word}: {words[word]}")
