import sys
import time
import os
import shutil

# python EvaluateAbility v1.2
# by wangjiaze on 2019-Sep-10

import Cycle2Wyc
import CsqCheck
import ExtractInformation


def GetNcyc(path):
    inpfilename = ExtractInformation.GetFilenames(path, 'inp')[0]
    ncyc = int(ExtractInformation.GetInformation(inpfilename, 'NCYC\s+(\d+)', 1))
    return ncyc


def GetWycNumber(path):
    inpfilename = ExtractInformation.GetFilenames(path, 'inp')[0]
    wycfilename = ExtractInformation.GetInformation(inpfilename, 'read\s+(\S+)', 1)
    file = open(path + '/' + wycfilename, 'r')
    lines = file.readlines()
    linesNumber = len(lines)
    return linesNumber


def EvaluateAbility(csqParaFilename, outFilename):
    csq_requirement, csqStd_requirement, ycsqFilenames, ncsqFilenames, referenceCsqFilenames, outtxtFilename, outAllCsqFilename = CsqCheck.ReadInputFile(csqParaFilename)
    allCsqs, Allstructures = CsqCheck.CsqCheck(csqParaFilename)

    cycles = []
    outfilename = outFilename.split('/')[-1].split('\\')[-1]

    for csq in allCsqs:
        outname = csq.name.split(':')[0].split('/')[-1].split('\\')[-1]
        if outfilename == outname:
            if csq.reference == '?':
                cycles.append(csq.cycle)
    # print(cycles)
    cycle_wycs = Cycle2Wyc.Cycles2Wycs(outFilename, cycles)

    wycs_StruNumber = {}
    for wycs in cycle_wycs.values():
        if wycs not in wycs_StruNumber:
            wycs_StruNumber[wycs] = 1
        else:
            wycs_StruNumber[wycs] = wycs_StruNumber[wycs] + 1
    return wycs_StruNumber, outAllCsqFilename


def CreateParaFile0(path):
    #path = os.getcwd()
    filename = path + '/' + 'para.txt'
    file = open(filename, 'w')
    file.write('REQU:\n')
    file.write('    1:4-4\n')
    file.write('    12:120-1000\n')
    file.write('    STD2:0-2.404746\n')
    file.write('    STD3:0-4.6475805\n')
    file.write('    STD4:0-5.752803\n')
    file.write('    STD5:0-7.293891\n')
    file.write('    STD6:0-8.81091\n')
    file.write('    STD7:0-12.8108415\n')
    file.write('    STD8:0-14.586945\n')
    file.write('    STD9:0-15.389676\n')
    file.write('    STD10:0-17.754867\n')
    file.write('    STD11:0-18.645567\n')
    file.write('    STD12:0-28.1811375\n')   
    
    csqfiles = ExtractInformation.GetFilenames(path, 'csq')
    file.write('CSQF:\n')
    for csqfile in csqfiles:
        file.write('    ')
        file.write(csqfile)
        file.write('  Y\n')
    file.write('REFE:\n')
    file.write('OUTF:\n')
    file.write('    EvaluateAbility.csqout\n')
    file.write('OUTC:\n')
    file.write('    ' + csqfile + 'w')
    file.close()
    return filename


def CreateParaFile(path, oldcsqwfilenames = False):
    #path = os.getcwd()
    csqfiles = ExtractInformation.GetFilenames(path, 'csq')

    filename = path + '/' + 'para.txt'
    file = open(filename, 'w')
    file.write('REQU:\n')
    file.write('    1:4-4\n')
    file.write('    12:120-1000\n')
    file.write('    STD2:0-2.404746\n')
    file.write('    STD3:0-4.6475805\n')
    file.write('    STD4:0-5.752803\n')
    file.write('    STD5:0-7.293891\n')
    file.write('    STD6:0-8.81091\n')
    file.write('    STD7:0-12.8108415\n')
    file.write('    STD8:0-14.586945\n')
    file.write('    STD9:0-15.389676\n')
    file.write('    STD10:0-17.754867\n')
    file.write('    STD11:0-18.645567\n')
    file.write('    STD12:0-28.1811375\n') 
    file.write('CSQF:\n')
    for csqfile in csqfiles:
        file.write('    ')
        file.write(csqfile)
        file.write('  Y\n')
    file.write('REFE:\n')
    if oldcsqwfilenames:
        #csqfiles.append(oldcsqwfilename)
        for oldcsqwfilename in oldcsqwfilenames:
            file.write('    ' + oldcsqwfilename + '\n')
    file.write('OUTF:\n')
    file.write('    ' + path + '/' + 'EvaluateAbility.csqout\n')
    file.write('OUTC:\n')
    file.write('    ' + csqfile + 'w')
    file.close()

    csqtemfile = path + '/' + 'EvaluateAbility.csqout'
    # newcsqwfilename
    return filename, csqtemfile,


def Set(wycfilename, outpath, label, referenceinp, n, cyclenum, oldwycfilename):
    def dealfile(outname, referenceinp, n, cyclenum, oldwycfilename):

        file = open(oldwycfilename, 'r')
        # file = open(outname, 'r')
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

        os.remove(oldwycfilename)
        inpfilename = False
        if lines:
            wycname = outname + "_" + str(max) + '.wyc'
            file = open(wycname, 'w')

            wycnum = 0
            for line in lines:
                cha = max - len(line)
                l = ''
                for a in line:
                    l = l + " " + a
                l = l + " *" * cha + '\n'
                file.write(l)
                wycnum = wycnum + 1

            Createinp.createinp(outname + '.inp', wycname.split('/')[-1], referenceinp, wycnum, cyclenum)
            file.close()
            inpfilename = outname + '.inp'
        return inpfilename

    import Createinp
    inpfilenames = []

    dirname = label
    outnames = []
    order = 1
    outdirname = dirname + "+"
    outdirpath = outpath

    # outname = outpath + '/'+ outdirname
    outname = outpath + '/' + dirname
    outnames.append(outname)

    inpfilename = dealfile(outname, referenceinp, n, cyclenum, oldwycfilename)
    inpfilenames.append(inpfilename)
    return inpfilenames


def RebuildFraGen(overwycs, path, newpath, eachWycCycleNumber, referencefiles, neweachWycCycleNumber):
    if not os.path.exists(newpath):
        os.mkdir(newpath)
    inpfilename = ExtractInformation.GetFilenames(path, 'inp')[0]
    wycfilename = ExtractInformation.GetFilenames(path, 'wyc')[0]
    shutil.copy(inpfilename, newpath)

    # wycfilename = newpath + '/' + '_'.join(wycfilename.split('/')[-1].split('\\')[-1].split('wyc')[0].split('_')[:-1]) + '+'
    wycfilename = newpath + '/' + 'old.wyc'
    file = open(wycfilename, 'w')
    for overwyc in overwycs:
        file.write(" ".join(overwyc) + '\n')
    file.close()

    newinpFile = inpfilename.split('/')[-1].split('\\')[-1].split('.')[0]
    if '-' not in newinpFile:
        newinpFile = newinpFile + '-2'
    else:
        newinpFile = newinpFile.split('-')[0] + '-' + str(int(newinpFile.split('-')[1]) + 1)

    inpfilenames = Set(wycfilename, newpath, newinpFile, inpfilename, len(overwycs) + 1, eachWycCycleNumber, wycfilename)
    os.remove(newpath + '/' + inpfilename.split('/')[-1].split('\\')[-1])
    # print(inpfilenames)
    #
    file = open('/'.join(inpfilenames[0].split('/')[:-1]) + '/' + 'title.txt', 'w')
    file.write(str(neweachWycCycleNumber) + '\n')
    for referencefile in referencefiles:
        file.write(referencefile + '\n')
    file.close()


    return inpfilenames
    # for inpfilename in inpfilenames:
    #     print(inpfilename)



if __name__ == '__main__':
    # print()
    # print("######################")
    # print("  EvaluateAbility v1.0")
    # print("           2019-Sep-03")
    # print("          by wangjiaze")
    # print("######################")
    # print()

    starttime = time.perf_counter()


    # filename = 'ratio.txt'
    # path = 'wyc/11+'
    # maxradio = 0.01

    path = sys.argv[1]
    filename = sys.argv[2]
    maxradio = float(sys.argv[3])

    titlefilename = path + '/' + 'title.txt'

    oldcsqwfilenames = []
    if os.path.exists(titlefilename):
        OldNew = True
        file = open(titlefilename, 'r')
        line = file.readline()
        oldeachWycCycleNumber = int(line.strip())
        line = file.readline()
        while line:
            oldcsqwfilenames.append(line.strip())
            line = file.readline()
        file.close()
    else:
        OldNew = False
        oldoutfilename = False
        oldcsqwfilenames = []
        oldeachWycCycleNumber = False

    csqParaFilename, csqtemfile = CreateParaFile(path, oldcsqwfilenames)
    outFilename = ExtractInformation.GetFilenames(path, 'out')[0]
    ncyc = GetNcyc(path)
    wycNumber = GetWycNumber(path)
    eachWycCycleNumber = int(ncyc / wycNumber)

    outFilename = ExtractInformation.GetFilenames(path, 'out')[0]

    ncyc = GetNcyc(path)
    wycNumber = GetWycNumber(path)
    eachWycCycleNumber = int(ncyc/wycNumber)
    # pselfilename, newcsqwfilename = CreatePselFile(path, csqtemfile)
    wycs_StruNumber, newcsqwfilename = EvaluateAbility(csqParaFilename, outFilename)
    csq_requirement, csqStd_requirement, ycsqFilenames, ncsqFilenames, referenceCsqFilenames, outtxtFilename, outAllCsqFilename = CsqCheck.ReadInputFile(csqParaFilename)

    overwycs = []
    file = open(path + '/' + filename, 'w')
    file.write(str(csqParaFilename) + '\t' + outFilename+ '\t' + str(eachWycCycleNumber) + '\n')
    for wycs, StruNumber in wycs_StruNumber.items():
        file.write(wycs + '\t' + str(StruNumber) + '\t' + str(StruNumber/(eachWycCycleNumber + oldeachWycCycleNumber)) +'\n')
        if StruNumber/(eachWycCycleNumber + oldeachWycCycleNumber) > maxradio:
            overwycs.append(wycs)


    oldcsqwfilenames.append(newcsqwfilename)
    if overwycs:
        # print(True)
        # print(path)
        allpath = '/'.join(path.replace('\\', '/').split('/')[:-1])
        filename1 = path.split('/')[-1].split('\\')[-1]
        if '-' not in filename1:
            newpath = allpath  + '/'+ filename1 + '-2'
        else:
            newpath = allpath  + '/'+ filename1.split('-')[0]+ '-' + str(int(filename1.split('-')[1]) + 1)
        inpfilenames = RebuildFraGen(overwycs, path, newpath, eachWycCycleNumber, oldcsqwfilenames, eachWycCycleNumber + oldeachWycCycleNumber)
        for inpfilename in inpfilenames:
            print(inpfilename, end=' ')
    else:
        print(False)

    endtime = time.perf_counter()
    # print('Total CPU time: ' + str(round(endtime - starttime, 4)) + 's')
