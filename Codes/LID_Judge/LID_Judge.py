import sys
import os
import shutil
import ExtractInformation

# python LID_Judge -v1.0
# by wangjiaze on 2019-Aug-25

def LID_Judge(Si_O, O_Si_O, Si_O_Si):
    # paramater remove RWY, AHT, VFI, MVY
    maxTOStd = 0.019575
    maxOOStd = 0.059779
    maxTTStd = 0.088922
    maxRTO = 0.063453
    maxROO = 0.275582
    maxRTT = 0.333253

    KTO_OO = 1.6310673632
    BTO_OO = 0.0027805611
    maxOOoffset = 0.001025425

    KTO_TT = -4.9448452543
    BTO_TT = 10.9967799179
    maxTToffset = 0.005475

    # paramater remove RWY
    # maxTOStd = 0.019575
    # maxOOStd = 0.063813
    # maxTTStd = 0.103676
    # maxRTO = 0.071472
    # maxROO = 0.275582
    # maxRTT = 0.333253
    # 
    # KTO_OO = 1.6307751273
    # BTO_OO = 0.0032431069
    # maxOOoffset = 0.001013
    # 
    # KTO_TT = -4.9469754
    # BTO_TT = 11.0001978
    # maxTToffset = 0.005477
    
    # before
    # maxTOStd = 0.0196
    # maxOOStd = 0.0638
    # maxTTStd = 0.1037
    # maxRTO = 0.0715
    # maxROO = 0.2756
    # maxRTT = 0.2618
    # 
    # KTO_OO = 1.63280
    # BTO_OO = 8.63480e-6
    # maxOOoffset = 0.001
    # 
    # KTO_TT = -4.94342
    # BTO_TT = 10.9945
    # maxTToffset = 0.0056

    # print(Si_O)
    # print(O_Si_O)
    # print(Si_O_Si)

    TOMean = Si_O[2]
    OOMean = O_Si_O[2]
    TTMean = Si_O_Si[2]
    TOStd = Si_O[3]
    OOStd = O_Si_O[3]
    TTStd = Si_O_Si[3]
    RTO = Si_O[1] - Si_O[0]
    ROO = O_Si_O[1] - O_Si_O[0]
    RTT = Si_O_Si[1] - Si_O_Si[0]

    OOoffset = abs(KTO_OO * TOMean + BTO_OO - OOMean)
    TToffset = abs(KTO_TT * TOMean + BTO_TT - TTMean)

    if TOStd <= maxTOStd and OOStd <= maxOOStd and TTStd <= maxTTStd and RTO <= maxRTO and ROO <= maxROO and RTT <= maxRTT and OOoffset <= maxOOoffset and TToffset <= maxTToffset:
        return True
    return False


def ReadFoutFIle(filename):
    # min max mean std
    file = open(filename, 'r')
    while True:
        line = file.readline()
        if not line:
            break
        if 'Statistics:' in line:
            Si_O_Dmin = float(ExtractInformation.GetAfterInformation(file, 'Si\s+O\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 1))
            Si_O_Dmax = float(ExtractInformation.GetAfterInformation(file, 'Si\s+O\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 2))
            Si_O_Dmean = float(ExtractInformation.GetAfterInformation(file, 'Si\s+O\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 3))
            Si_O_Dstd = float(ExtractInformation.GetAfterInformation(file, 'Si\s+O\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 4))

            O_Si_O_Dmin = float(ExtractInformation.GetAfterInformation(file, 'O\s+Si\s+O\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 1))
            O_Si_O_Dmax = float(ExtractInformation.GetAfterInformation(file, 'O\s+Si\s+O\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 2))
            O_Si_O_Dmean = float(ExtractInformation.GetAfterInformation(file, 'O\s+Si\s+O\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 3))
            O_Si_O_Dstd = float(ExtractInformation.GetAfterInformation(file, 'O\s+Si\s+O\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 4))

            Si_O_Si_Dmin = float(ExtractInformation.GetAfterInformation(file, 'Si\s+O\s+Si\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 1))
            Si_O_Si_Dmax = float(ExtractInformation.GetAfterInformation(file, 'Si\s+O\s+Si\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 2))
            Si_O_Si_Dmean = float(ExtractInformation.GetAfterInformation(file, 'Si\s+O\s+Si\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 3))
            Si_O_Si_Dstd = float(ExtractInformation.GetAfterInformation(file, 'Si\s+O\s+Si\s+\S+\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 4))

    Si_O = [Si_O_Dmin, Si_O_Dmax, Si_O_Dmean, Si_O_Dstd]
    O_Si_O = [O_Si_O_Dmin, O_Si_O_Dmax, O_Si_O_Dmean, O_Si_O_Dstd]
    Si_O_Si = [Si_O_Si_Dmin, Si_O_Si_Dmax, Si_O_Si_Dmean, Si_O_Si_Dstd]
    return Si_O, O_Si_O, Si_O_Si


def Cif2Fin(cifFilename, finFilename, foutFilename):
    spaceGroup, groupNumber, cellParameter, atom_atomElement, atom_coordinate = ExtractInformation.ReadCif(cifFilename, 'GULP')
    # print(spaceGroup)
    # print(groupNumber)
    # print(cellParameter)
    # print(atom_atomElement)
    # print(atom_coordinate)
    title = cifFilename.split('/')[-1].split('\\')[-1].split('.')[0]
    finFile = open(finFilename, 'w')

    finFile.write('TITL ' + title + '\n')
    finFile.write('OUTF ' + foutFilename + '\n')

    finFile.write('CELL ')
    for a in cellParameter:
        finFile.write(str(a) + '  ')
    finFile.write('\n')
    finFile.write('SPGR ' + spaceGroup + '\n')
    finFile.write('ENVI 1 1 1\n')
    finFile.write('TYPE 2\n')
    finFile.write('1 Si 1 4 0 0 10\n')
    finFile.write('2 O  1 2 0 0 10\n')
    finFile.write('BOND 1\n')
    finFile.write('1 2 1.8 1 1.605 0 0 20\n')
    finFile.write('D1_3 2\n')
    finFile.write('2 1 2 1 2.6 0 0 4\n')
    finFile.write('1 2 1 1 3.1 0 0 4\n')
    finFile.write('NCYC 0\n')
    finFile.write('UNIQ ' + str(len(atom_atomElement)) + '\n')

    for atom in atom_atomElement:
        # print(atom_atomElement)
        if atom_atomElement[atom] == 'Si':
            type = '1'
        elif atom_atomElement[atom] == 'O':
            type = '2'
        coordinate = atom_coordinate[atom]
        x = str(coordinate[0])
        y = str(coordinate[1])
        z = str(coordinate[2])
        finFile.write(atom + '  ' + type + ' @   ' + x + '  ' + y + '  ' + z + '\n')
    finFile.write('END')





    #
    # filename = cifFilename.split('/')[-1].split('\\')[-1].split('.')[0]
    # finFilename = finPath + '\\' + filename
    # print('cif2fin ' + cifFilename.replace('/', '\\') + ' ' + finFilename)
    # os.system('cif2fin<' + cifFilename.replace('/', '\\') + '>' + finFilename)
    return


def Cifs2Fins(cifPath, finPath, foutPath):
    cifFilenames = ExtractInformation.GetFilenames(cifPath, 'cif')
    for cifFilename in cifFilenames:
        filename = cifFilename.split('/')[-1].split('\\')[-1].split('.')[0]
        finFilename = finPath + '\\' + filename + '.fin'
        foutFilename = foutPath + '\\' +filename + '.fout'
        Cif2Fin(cifFilename, finFilename, foutFilename)


def fin2fout(finFilename):
    print('fin2fout ' + finFilename)
    os.system('fragen_4.2 ' + finFilename)


def fins2fouts(finPath):
    finFilenames = ExtractInformation.GetFilenames(finPath, 'fin')
    for finFilename in finFilenames:
        fin2fout(finFilename)


if __name__ == '__main__':
    # print()
    # print('####################')
    # print('     LID_Judge v-1.0')
    # print('         2019-Aug-25')
    # print('        by wangjiaze')
    # print('####################')
    # print()


    foutFilename = sys.argv[1]
    cifFilename = sys.argv[2]
    #outcifPath = sys.argv[3]
    
    Si_O, O_Si_O, Si_O_Si = ReadFoutFIle(foutFilename)
    result = LID_Judge(Si_O, O_Si_O, Si_O_Si)
    print(result)
    # if result:
    #     shutil.copy(cifFilename, outcifPath)
