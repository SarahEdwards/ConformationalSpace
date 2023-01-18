#! python
import os
file = open("unprocRest.txt")
count = 1
appendFile = open("unprocRest.txt","a+")
dotTxt = ".txt"
existingPath = os.path.exists("processedRests")

if not existingPath:
    os.mkdir("processedRests")

for line in file:
    thisLine = line.strip()
    spaceChar = thisLine[1]
    alphaChar = thisLine[2]
    print(spaceChar + alphaChar)
    if thisLine[1:4] == "Page" or thisLine[1:4] == "Rest":
        continue
    elif len(thisLine) == 4:
        appendFile.close()
        appendFile = open("processedRests/" + thisLine + dotTxt,"a+")
        # print("processedRests/" + thisLine + dotTxt,"a")
    elif spaceChar == " " and not alphaChar.isalpha():
        print(thisLine)
        appendFile.write(thisLine + "\n")
    else:
        continue
file.close()
appendFile.close()
