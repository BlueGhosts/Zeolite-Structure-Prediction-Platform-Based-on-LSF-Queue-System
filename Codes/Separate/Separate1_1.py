import os
import shutil
import sys

import Createinp

# python Separate V1.1
# by wangjiaze on 2019-Mar-18

def dealfile(outname, referenceinp, n, cyclenum):
    file = open(outname, 'r')
    max = 0
    lines = []
    while True:
        line = file.readline()
        if not line:
            break
        line = line.split()
        while '*' in line:
            line.remove('*')
        lines.append(line)
        if len(line) > max:
            max = len(line)
    file.close()

    wycname = outname + "_" + str(max) + '.wyc'
    file = open(wycname, 'w')

    wycnum = 0
    for line in lines:
        cha = max - len(line)
        l = ''
        for a in line:
            l = l + " " + a
        l = l + " *"* cha + '\n'
        file.write(l)
        wycnum = wycnum + 1
    os.remove(outname)
    Createinp.createinp(outname + '.inp', wycname.split('/')[-1], referenceinp, wycnum, cyclenum)
    file.close()


def set(wycfilename, outpath, label, referenceinp, n, cyclenum):
    infile = open(wycfilename, 'r')
    j = 1
    if '/' in outpath:
        dirname = outpath.split('/')[-1]
    elif '\\' in outpath:
        dirname = outpath.split('\\')[-1]
    else:
        dirname = outpath
    dirname = label
    outnames = []
    order = 1
    while True:
        if j < 10:
            outdirname = dirname + "0" + str(j)
        else:
            outdirname = dirname + str(j)

        # outdirpath = outpath + '/' + outdirname
        outdirpath = outpath + '/' + str(order)
        if os.path.exists(outdirpath):
            shutil.rmtree(outdirpath)
        os.makedirs(outdirpath)
        # outname = outpath + '/' + outdirname + '/' + outdirname
        outname = outpath + '/' + str(order) + '/' + outdirname
        outnames.append(outname)
        outfile = open(outname, 'w')
        for i in range(n):
            line = infile.readline()
            if not line.strip():
                outfile.close()
                dealfile(outname, referenceinp, n, cyclenum)
                return
            outfile.write(line)
        outfile.close()
        dealfile(outname, referenceinp, n, cyclenum)
        j = j + 1
        order = order + 1


def getinput(filename):
    file = open(filename, 'r')

    line = file.readline()
    wycfilename = line.split()[1]

    line = file.readline()
    outpath = line.split()[1]

    line = file.readline()
    label = line.split()[1]

    line = file.readline()
    referenceinp = line.split()[1]

    line = file.readline()
    maxnum = int(line.split()[1])

    line = file.readline()
    cyclenum = int(line.split()[1])

    return wycfilename, outpath, label, referenceinp, maxnum, cyclenum


if __name__ == '__main__':
    filename = sys.argv[1]
    # filename = 'separate_wyc.txt'
    wycfilename, outpath, label, referenceinp, maxnum, cyclenum = getinput(filename)
    set(wycfilename, outpath, label, referenceinp, maxnum, cyclenum)
