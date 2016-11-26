fi = open("corpus/india.txt", "r")
fo = open("corpus/india_clean.txt", "w")

for s in fi:
    j = s.find("[")
    if j != -1:
        fo.write(s[:j] + "\n")
    else:
        fo.write(s)

fi.close()
fo.close()

