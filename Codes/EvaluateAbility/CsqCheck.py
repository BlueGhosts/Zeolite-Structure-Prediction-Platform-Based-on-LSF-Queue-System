import re
import sys
import time
import operator
from CoordinateSequenceIF import CoordinateSequenceIF

# python CsqCheck v2.0
# by wangjiaze on 2022-Mar-24

def CompareCsq(csq1, csq2):
    if csq1.atomnum != csq2.atomnum:
        return False
    else:
        if csq1.csqnum == csq2.csqnum:
            for lastcsq in csq1.lastcsqs:
                if lastcsq not in csq2.lastcsqs:
                    return False

            for atomcsq in csq1.atomcsqs:
                if atomcsq not in csq2.atomcsqs:
                    return False
        else:
            mincsqnum = min(csq1.csqnum, csq2.csqnum)
            atomcsqs1 = csq1.GetAtomcsqs(mincsqnum)
            atomcsqs2 = csq2.GetAtomcsqs(mincsqnum)
            for atomcsq in atomcsqs1:
                if atomcsq not in atomcsqs2:
                    return False
    return True


def WriteCsq(outcsq_filename, csqs):
    file = open(outcsq_filename, 'w')
    for csq in csqs:
        file.write('#############################################\n')
        file.write(csq.name + '\n')
        file.write('\t' + str(csq.atomnum) + '\t' + str(csq.csqnum) + '\n')
        i = 1
        for atomcsq in csq.atomcsqs:
            file.write('Si' + str(i))
            for a in atomcsq:
                file.write(' ' + str(a))
            file.write('\n')
            i = i + 1

    file.close()


def WriteOutfile(outfilename, allCsqs, structures):

    sortparameter = operator.attrgetter('cost')
    allCsqs.sort(key = sortparameter)

    file = open(outfilename, 'w')
    file.write("#########################################################################################################\n"
               "Unique Frameworks\n"
               "  FilePath        FI_Name     Frequency    Frameworks\n"
               "#########################################################################################################\n")

    form1 = "{0:<15}\t{1:^10}\t{2:^10}\t{3:<25}\n"
    for csq in allCsqs:
        # print(csq.id)
        # print(form1.format(csq.id, csq.reference, csq.frequency, csq.name))
        file.write(form1.format(csq.filename, csq.reference, csq.frequency, csq.name))


    file.write("\n\n########################################################################################\n"
                      "All Structures:\n"
                      "  FilePath        FT_Name      Structures\n"
                      "########################################################################################\n")
    form2= "{0:<15}\t{1:^10}\t{2:<25}\n"
    for structure in structures:
        # print(form2.format(structure.id, structure.reference, structure.name))
        file.write(form2.format(structure.filename, structure.reference, structure.name))
    file.close()


def DealAllCsqs(csqs):
    allCsqs = []
    for csq in csqs:
        if csq.isAllowed:
            allCsqs = UpdateCsqs(csq, allCsqs)
    return allCsqs


def UpdateCsqs(csq1, csqs):
    global idNumber
    flag = True
    for i in range(len(csqs)):
        csq2 = csqs[i]
        if CompareCsq(csq1, csq2):
            flag = False
            if csq1.cost < csq2.cost:
                csq1.UpdateCsq(csq2)
                csqs[i] = csq1
            else:
                csq2.FrequencyAddOne()
    if flag:
        csqs.append(csq1)
    return csqs


def ReadCsqFile(filename, csqRequirement = {}, csqStd_requirement = {}, selfcheck = False, referenceCsqs = []):
    def ReadOneCsq(file, filename, csqRequirement = {}, referenceCsqs = []):
        atomcsqs = []

        line = file.readline()
        name = line.strip()
        line = file.readline()
        atomnum = int(line.split()[0])
        csqnum = int(line.split()[1])
        for i in range(atomnum):
            line = file.readline()
            atomcsqStr = line.split()[1:csqnum + 1]
            atomcsq = [int(csq) for csq in atomcsqStr]
            atomcsqs.append(atomcsq)
        structure = CoordinateSequenceIF(name, atomcsqs, referenceCsqs, filename, csqRequirement, csqStd_requirement)
        return structure
    # print(filename)
    structures = []
    allStructures = []
    file = open(filename, 'r')
    line = file.readline()

    while line and line[0] != "#":
        line = file.readline()
    while True:
        if not line:
            break
        structure = ReadOneCsq(file, filename, csqRequirement, referenceCsqs)
        allStructures.append(structure)
        if selfcheck:
            structures = UpdateCsqs(structure, structures)
        else:
            structures.append(structure)
        line = file.readline()
    return structures


def ReadInputFile(filename):
    csq_requirement = {}
    csqStd_requirement = {}
    ncsqFilenames = []
    ycsqFilenames = []
    referenceCsqFilenames = []
    outtxtFilename = ''
    outAllCsqFilename = ''
    file = open(filename, 'r')
    line = file.readline()

    if re.match("REQU:", line):
        line = file.readline()
        while not re.match("CSQF:", line):
            # 1: 4 - 4
            if "STD" not in line:
                match = re.match("\s*(\d+)\s*:\s*(\d+)\s*-\s*(\d+)\s*", line)
                num = int(match.group(1)) - 1
                requirement1 = int(match.group(2))
                requirement2 = int(match.group(3))
                csq_requirement[num] = [requirement1, requirement2]
            else:
                match = re.match("\s*STD(\d+)\s*:\s*([\d|\.]+)\s*-\s*([\d|\.]+)\s*", line)
                num = int(match.group(1)) - 1
                requirement1 = float(match.group(2))
                requirement2 = float(match.group(3))
                csqStd_requirement[num] = [requirement1, requirement2]
            line = file.readline()


    if re.match("CSQF:", line):
        line = file.readline()
        while not re.match("REFE:", line):
            if line.split()[1] == 'N' or line.split()[1] == 'n':
                ncsqFilenames.append(line.split()[0])
            if line.split()[1] == 'Y' or line.split()[1] == 'y':
                ycsqFilenames.append(line.split()[0])
            line = file.readline()

    if re.match("REFE:", line):
        line = file.readline()
        while not re.match("OUTF:", line):
            referenceCsqFilenames.append(line.strip())
            line = file.readline()

    if re.match("OUTF:", line):
        line = file.readline()
        outtxtFilename = line.strip()
        while not re.match("OUTC:", line):
            line = file.readline()

    if re.match("OUTC:", line):
        line = file.readline()
        outAllCsqFilename = line.strip()

    file.close()
    # print()
    # print(csq_requirement)
    # print(ycsqFilenames)
    # print(ncsqFilenames)
    # print(referenceCsqFilenames)
    # print(outtxtFilename)
    # print(outAllCsqFilename)
    # print()
    return csq_requirement, csqStd_requirement, ycsqFilenames, ncsqFilenames, referenceCsqFilenames, outtxtFilename, outAllCsqFilename


def CsqCheck(filename):
    csq_requirement, csqStd_requirement, ycsqFilenames, ncsqFilenames, referenceCsqFilenames, outtxtFilename, outAllCsqFilename = ReadInputFile(filename)
    Allstructures = []

    referenceCsqs = []
    for referenceCsqFilename in referenceCsqFilenames:
        referenceStructures = ReadCsqFile(referenceCsqFilename)
        referenceCsqs = referenceCsqs + referenceStructures

    for csqFile in ycsqFilenames:
        structures = ReadCsqFile(csqFile, csq_requirement, csqStd_requirement, True, referenceCsqs)
        Allstructures = Allstructures + structures
    for csqFile in ncsqFilenames:
        structures = ReadCsqFile(csqFile, csq_requirement, csqStd_requirement, False, referenceCsqs)
        Allstructures = Allstructures + structures

    allCsqs = DealAllCsqs(Allstructures)

    WriteOutfile(outtxtFilename, allCsqs, Allstructures)
    WriteCsq(outAllCsqFilename, allCsqs)

    return allCsqs, Allstructures



if __name__ == '__main__':
    #print()
    #print("####################")
    #print("       CsqCheck v1.0")
    #print("         2022-Mar-24")
    #print("        by wangjiaze")
    #print("####################")
    #print()

    starttime = time.perf_counter()

    # filename = input('Please input the parameter file name:\n')
    # filename = 'para.txt'
    filename = sys.argv[1]

    allCsqs, structures = CsqCheck(filename)

    endtime = time.perf_counter()
    #print('Total CPU time: ' + str(round(endtime - starttime, 4)) + 's')