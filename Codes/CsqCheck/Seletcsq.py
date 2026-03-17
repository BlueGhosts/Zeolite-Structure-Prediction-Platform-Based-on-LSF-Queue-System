import sys
import re


def seletecsq(InfileTxtName, sign, OutfileTxtName):
    infile = open(InfileTxtName, "r")
    outfile = open(OutfileTxtName, "w")
    for i in range(4):
        inline = infile.readline()
        outfile.write(inline)
    inline = infile.readline()

    while inline.strip():
        line = inline.split()[3].split('/')[-1].split('.')[0]
        # match = re.search(sign, line)
        if sign == line:
            outfile.write(inline)
        inline = infile.readline()


    while inline[0] != '#':
        outfile.write(inline)
        inline = infile.readline()
    outfile.write(inline)

    for i in range(3):
        inline = infile.readline()
        outfile.write(inline)
    inline = infile.readline()

    while inline.strip():
        line = inline.split()[2].split('/')[-1].split('.')[0]
        # match = re.search(sign, line)
        if sign == line:
            outfile.write(inline)
        inline = infile.readline()
    infile.close()
    outfile.close()

def ReadInput(ParameterFileName):
    paramaterfile = open(ParameterFileName, "r")
    line = paramaterfile.readline()
    while line:
        if re.search('IN (.*)', line):
            InfileTxtName = sign = re.search('IN (.*)', line).group(1)
        elif re.search('SIGN (.*)', line):
            sign = re.search('SIGN (.*)', line).group(1)
        elif re.search('OUT (.*)', line):
            OutfileTxtName = re.search('OUT (.*)', line).group(1)
        line = paramaterfile.readline()

    #print(InfileTxtName)
    #print(sign)
    #print(OutfileTxtName)
    return InfileTxtName, sign, OutfileTxtName
    
    
ParameterFileName = sys.argv[1]
InfileTxtName, sign, OutfileTxtName = ReadInput(ParameterFileName)
seletecsq(InfileTxtName, sign, OutfileTxtName)	