import re
import sys
import time


# python Cycle2Wycs v1.0
# by wangjiaze on 2019-Sep-02

def Cycles2Wycs(filename, cycleList = True):
    def ReadCycle(file):
        atoms = []
        Wycks = []
        num_elementSymbol = ReadAtomTypeRestraints(filename)
        file.readline()
        for i in range(atomNum):
            line = file.readline().split()
            atomName = line[0]
            atomType = num_elementSymbol[line[1]]
            atomWyck = line[2]
            Wycks.append(atomWyck)
            atomCoordinate = [line[4], line[5], line[6]]
            atom = [atomName, atomType, atomWyck, atomCoordinate]
            atoms.append(atom)
        return atoms

    def ReadAtomTypeRestraints(filename):
        file = open(filename, 'r')
        num_elementSymbol = {}
        while True:
            line = file.readline()
            if not line:
                break
            if 'Atom type restraints' in line:
                line = file.readline()
                # print(line)
                while True:
                    line = file.readline()
                    if not line.strip():
                        break

                    # print(line)
                    num = line.split()[1]
                    elementSymbol = line.split()[0]
                    num_elementSymbol[num] = elementSymbol
                    # print(line)
                break
        file.close()
        return num_elementSymbol

        cifFilename = filename.split('/')[-1].split('\\')[-1].split('.')[0] + '_' + cycle + '.cif'
        print("{0:<10}\t{1:<10}".format(filename + ':' + cycle, ' DONE!'))
        return cifFilename, atoms

    cycle_wycs = {}
    file = open(filename, 'r')
    while True:
        line = file.readline()
        if not line:
            break
        if 'Cycle'in line and 'Cost' in line:
            match = re.search('Cycle (\d+), (\d+)/ \d+ atoms, Cost= .*', line)
            cycle = int(match.group(1))
            atomNum = int(match.group(2))
            if cycleList  == True or cycle in cycleList:
            # if not cycleList:
                atoms = ReadCycle(file)
            # elif cycle in cycleList:
                wycs = [atom[2] for atom in atoms]
                wycs.sort()
                cycle_wycs[cycle] = ''.join(wycs)
    return cycle_wycs


if __name__ == '__main__':
    print()
    print("####################")
    print("     Cycle2Wycs v1.0")
    print("         2019-Sep-02")
    print("        by wangjiaze")
    print("####################")
    print()

    starttime = time.perf_counter()

    filename = input('Please input the parameter file name:\n')
    # filename = sys.argv[1]
    # filename = '2.out'
    cycle_wycs = Cycles2Wycs(filename)


    endtime = time.perf_counter()
    print('Total CPU time: ' +str(round(endtime - starttime, 4)) +'s')