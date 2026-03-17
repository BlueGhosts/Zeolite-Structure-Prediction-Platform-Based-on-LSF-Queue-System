def createinp(OutInpName, WycName, ReferenceInpName, maxnum, cyclenum):
    # print()
    # print(OutInpName)
    # print(WycName)
    # print(ReferenceInpName)
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
        if 'Si' in line and '?' in line:
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
            for i in range(1, int(tnum)+1):
                inp_file.write('Si' + str(i) + '    1  ?'+ '\n')
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
    OutInpName = input('Please input the path for inp file:\n')
    WycName = input('Please input the name of wyc file:\n')
    ReferenceInpName= input('Please input the path for the reference of inp file:\n')
    maxnum = int(input('Please enter the number of wyc combination:\n'))
    cyclenum = int(input('Please enter the quantity of cycle for each wyc combination:\n'))
    createinp(OutInpName, WycName, ReferenceInpName, maxnum, cyclenum)