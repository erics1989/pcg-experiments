
f1 = open("japanese_cities")
f2 = open("japanese_cities_first_word", "w")

for line in f1:
    words = string.split(line, " ")
    f2.write(words[0] + "\n")


