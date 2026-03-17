import re
import sys

import ExtractInformation
import CoordinateTransformation as CoorTrans


# python Out2Cif -1.1
# by wangjiaze on 2019-Jul-6
# v-1.1 outfilename : outfilename_cycle; output ciffile - 'data_FraGen(' + 'groupnum' + outfilename + cycle + ')'



def ReadPara_Out2Cif(filename):
    file = open(filename, 'r')
    csqoutFilename = file.readline().strip()
    outFilename = file.readline().strip()
    return csqoutFilename, outFilename


def GetCycleFromCsqoutFile(csqoutFilename, outFilename):
    file = open(csqoutFilename, 'r')
    sign = outFilename.split('/')[-1].split('\\')[-1]
    cycleList = ['None']
    while True:
        line = file.readline()
        if not line.strip():
            break
        if sign in line:
            cycle = re.search('Cycle (\d+),', line).group(1)
            cycleList.append(cycle)
    return cycleList


def GetGroupInformation(filename):
    outfilename = filename.split('/')[-1].split('.')[0]
    inpinformation = ExtractInformation.GetInformation(filename, 'Instruction file:\s+(.*)', 1)
    inpfilename = inpinformation.split('/')[-1]
    SpaceGroup = ExtractInformation.GetInformation(filename, 'Space group:\s+(.*)', 1).strip()
    a = ExtractInformation.GetInformation(filename, 'Unit cell:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 1)
    b = ExtractInformation.GetInformation(filename, 'Unit cell:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 2)
    c = ExtractInformation.GetInformation(filename, 'Unit cell:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 3)
    A = ExtractInformation.GetInformation(filename, 'Unit cell:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 4)
    B = ExtractInformation.GetInformation(filename, 'Unit cell:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 5)
    C = ExtractInformation.GetInformation(filename, 'Unit cell:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', 6)
    CellParameter = [a, b, c, A, B, C]
    # print(inpinformation)
    # print(inpfilename)
    return outfilename, inpfilename, SpaceGroup, CellParameter


def Out2Cif(outFilename, Cifpath, cycleList = []):
    def Write2cif(cifFilename, spaceGroup, groupNumber, cellParameter, atoms):
        file = open(cifFilename, 'w')
        form = "{0:<35}\t{1:<20}\n"
        file.write('data_FraGen(' + str(groupNumber) + '_' + cifFilename.split('/')[-1].split('\\')[-1].split('.')[0] + ')\n')
        file.write(form.format('_audit_creation_method','FraGen-Out2Cif'))
        file.write(form.format('_symmetry_space_group_name_H-M', spaceGroup))
        file.write(form.format('_symmetry_Int_Tables_number', str(groupNumber)))
        file.write(form.format('_symmetry_cell_setting', CoorTrans.Groupnum2CrystalSystem(groupNumber)))
        file.write(form.format('_cell_length_a', cellParameter[0]))
        file.write(form.format('_cell_length_b', cellParameter[1]))
        file.write(form.format('_cell_length_c', cellParameter[2]))
        file.write(form.format('_cell_angle_alpha', cellParameter[3]))
        file.write(form.format('_cell_angle_beta', cellParameter[4]))
        file.write(form.format('_cell_angle_gamma', cellParameter[5]))

        symmetryEquivPosAsXyzs = CoorTrans.GetSymmetryEquivPosAsXyz(spaceGroup)
        file.write('loop_\n')
        file.write('_symmetry_equiv_pos_as_xyz\n')
        for symmetryEquivPosAsXyz in symmetryEquivPosAsXyzs:
            file.write(symmetryEquivPosAsXyz + '\n')

        file.write('loop_\n')
        file.write('_atom_site_label\n')
        file.write('_atom_site_type_symbol\n')
        file.write('_atom_site_fract_x\n')
        file.write('_atom_site_fract_y\n')
        file.write('_atom_site_fract_z\n')

        formAtom = "{0:<10}\t{1:<10}\t{2:<10}\t{3:<10}\t{4:<10}\n"
        for atom in atoms:
            # print(atom)
            file.write(formAtom.format(atom[0], atom[1], atom[3][0], atom[3][1], atom[3][2]))
        file.close()

    def ReadCycle():
        atoms = []
        Wycks = []
        outFile.readline()
        for i in range(atomNum):
            line = outFile.readline().split()
            atomName = line[0]
            atomType = num_elementSymbol[line[1]]
            atomWyck = line[2]
            Wycks.append(atomWyck)
            atomCoordinate = [line[4], line[5], line[6]]
            atom = [atomName, atomType, atomWyck, atomCoordinate]
            atoms.append(atom)

        # if groupNumber <= 9:
        #     groupNumber_3 = '00' + str(groupNumber)
        # elif groupNumber <= 99:
        #     groupNumber_3 = '0' + str(groupNumber)
        # else:
        #     groupNumber_3 = str(groupNumber)
        # Wycks.sort()
        # cifFilename = Cifpath + '/' + groupNumber_3 + ''.join(Wycks) + '_' + outfilename + '_' + cycle + '.cif'

        cifFilename = outFilename.split('/')[-1].split('\\')[-1].split('.')[0] + '_' + cycle + '.cif'
        print("{0:<10}\t{1:<10}".format(outFilename + ':' + cycle, ' DONE!'))
        return cifFilename, atoms

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


    outfilename, inpfilename, spaceGroup, cellParameter = GetGroupInformation(outFilename)
    groupNumber = CoorTrans.Groupname2Groupnum(spaceGroup)
    num_elementSymbol = ReadAtomTypeRestraints(outFilename)
    outFile = open(outFilename, 'r')
    while True:
        line = outFile.readline()
        if not line:
            break
        if 'Cycle'in line and 'Cost' in line:
            match = re.search('Cycle (\d+), (\d+)/ \d+ atoms, Cost= .*', line)
            cycle = match.group(1)
            atomNum = int(match.group(2))
            if not cycleList:
                cifFilename, atoms = ReadCycle()
                Write2cif(Cifpath + '/' + cifFilename, spaceGroup, groupNumber, cellParameter, atoms)
            elif cycle in cycleList:
                cifFilename, atoms = ReadCycle()
                Write2cif(Cifpath + '/' + cifFilename, spaceGroup, groupNumber, cellParameter, atoms)


if __name__ == '__main__':
    print()
    print('####################')
    print('       Out2Cif v-1.0')
    print('          2019-Jul-7')
    print('        by wangjiaze')
    print('####################')
    print()

    # paraFileName = input('Please input the parameter file name:\n')
    # Outcifpath = input('Please input the Output folder of cif:\n')

    # paraFileName = 'para.txt'
    # Outcifpath = 'cif'

    # csqoutFilename, outFilename = ReadPara_Out2Cif(paraFileName)
    csqoutFilename = sys.argv[1]
    outFilename = sys.argv[2]
    Outcifpath = sys.argv[3]

    cycleList = GetCycleFromCsqoutFile(csqoutFilename, outFilename)

    Out2Cif(outFilename, Outcifpath, cycleList)

    # input('Press any key to finish.\n')