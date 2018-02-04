# Custom Myo HAL parser from MVTA
# Ruisen (Eric) Liu
# Feb, 2018


import sys
import os
import csv
import itertools as it

def main():

    readDir = "MVTA_Labels"
    writeDir = "CSVs"
    
    for file in os.listdir(readDir):
        if file.endswith(".MDF3"):
            parse(file,readDir,writeDir)    

def parse(filename,readDir,writeDir):

    try:
        readfile=open(readDir + '/' + filename,'r')
    except IOError:
        print(filename + " file not found!")
        sys.exit(1)

    #CSV writer
    file,ext = filename.split('.')
    filename2 = file + 'par.txt'
    writefile=open(writeDir + '/' + filename2,'w+')
    writer = csv.writer(writefile)


    # Get rid of whitespace
    content = readfile.readlines();
    content = [x.strip() for x in content]

    numLabel = int(content[7]);

    # collecting starting and end labels
    starts = []
    ends = []
    calis = []
    #should have 20 motions, so 21 labels
    if numLabel != 21:
        print("incorrect number of labels for " + filename)
    else:
        for i in range(8,28):
            rec = content[i]
            a,b = rec.split(" ", 1) # split by  space
            if i % 2 != int(b):
                print("incorrect classification found for " + filename)
            else:
                starts.append(int(a))
        for j in range(9,29):
            rec = content[j]
            a,b = rec.split(" ", 1) # split by  space
            ends.append(int(a))  # already checked label sequence

    numCali = int(content[31])

    if numCali-1 != 3:
        print("incorrect number of calibration gestures for " + filename)
    else:
        for i in range(32,35):
            rec = content[i]
            a,b = rec.split(" ", 1) # split by  space
            calis.append(int(a))

    # now write starts/ends/calis to writer
    writer.writerow(["Start", "End", "Calibration"])
    writer.writerows( it.izip_longest(starts,ends,calis, fillvalue =' '))


    
# ----------

main()
