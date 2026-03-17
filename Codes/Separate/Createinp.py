
# python Createinp -1.1
# by wangjiaze on 2019-Jul-8
# v1.1 Make Code can get Num_elementSymbol (not only for Si)

def createinp(OutInpName, WycName, ReferenceInpName, maxnum, cyclenum):
    def ReadNum_elementSymbol(filename):
        file = open(filename, 'r')
        num_elementSymbol = {}
        while True:
            line = file.readline()
            if not line:
                break
            if ('Type' in line) or ('TYPE' in line) or ('type' in line):
                n = int(line.split()[1])
                for i in range(n):
                    line = file.readline().split()
                    num = line[0]
                    elementSymbol = line[1]
                    num_elementSymbol[num] = elementSymbol
                break
        return num_elementSymbol


    # print()
    # print(OutInpName)
    # print(WycName)
    # print(ReferenceInpName)
    num_elementSymbol = ReadNum_elementSymbol(ReferenceInpName)
    reference_file = open(ReferenceInpName, 'r')
    inp_file = open(OutInpName, 'w')

    listWycName = WycName.split('_')
    listWycName.pop(-1)
    title = ''.join(listWycName)
    # print(title)
    while True:
        line = reference_file.readline()
        if not line:
            break
        tf = False
        for elementSymbol in num_elementSymbol.values():
            if elementSymbol in line and '?' in line:
                tf = True
                break
        if tf:
            continue
        if 'TITL' in line:
            inp_file.write('TITL ' + title + '\n')
        elif 'OUTF' in line:
            inp_file.write('OUTF ' + title + '.out\n')
        elif 'LSTF' in line:
            inp_file.write('LSTF ' + title + '.lst\n')
        elif 'CSQF' in line:
            inp_file.write('CSQF ' + title + '.csq\n')
        elif 'wycf' in line:
            inp_file.write('wycf ' + title + 'wyc.wyc\n')
        elif 'logf' in line:
            inp_file.write('logf ' + title + '.log\n')
        elif 'read' in line:
            inp_file.write('read '+ WycName + '\n')
        elif 'UNIQ' in line:
            tnum = WycName.split('_')[-1].split('.')[0]
            inp_file.write('UNIQ '+ tnum + '\n')

            element = num_elementSymbol['1']
            for i in range(1, int(tnum)+1):
                inp_file.write(element + str(i) + '    1  ?'+ '\n')


        elif 'mwyc' in line:
            inp_file.write('mwyc 1\n')
            line = reference_file.readline()
            inp_file.write(line.split()[0] + ' ' + line.split()[1])
            for i in range(1, int(tnum)+1):
                inp_file.write(' ' + str(i) + ' 1')
            inp_file.write('\n')
        elif 'NCYC' in line:
            inp_file.write('NCYC '+ str(maxnum*cyclenum) + '\n')
        else:
            inp_file.write(line)


if __name__ == '__main__':
    print()
    print('####################')
    print('     Createinp v-1.1')
    print('          2019-Jul-8')
    print('        by wangjiaze')
    print('####################')
    print()

    OutInpName = input('Please input the path for inp file:\n')
    WycName = input('Please input the name of wyc file:\n')
    ReferenceInpName= input('Please input the path for the reference of inp file:\n')
    maxnum = int(input('Please enter the number of wyc combination:\n'))
    cyclenum = int(input('Please enter the quantity of cycle for each wyc combination:\n'))
    createinp(OutInpName, WycName, ReferenceInpName, maxnum, cyclenum)
