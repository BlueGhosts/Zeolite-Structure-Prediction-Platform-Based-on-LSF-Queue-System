import datetime
import sys

import CoordinateTransformation as CoorTrans
import ExtractInformation
import CalculateWyc


# AddOxygen For One file vST-1.1 for ST
# by wangjiaze on 2019-Jul-9
# v-1.0 For One file, For 166 not success
# v-1.1 CoordinateTransformation_v1.4 GetSymmetryEquivPosAsXyz;
#       Read ciffile instead of sfile

def CalulateUniqueAtom(SpaceGroupName, coordinates):
    def CalculateAllGeneralCoordintaes(coordinate, matrices):

        def GetDifferenceCoordinates(AllCoordinates, NewCoordinates):
            DifferenceCoordinates = []
            for coor in NewCoordinates:
                if not CoorTrans.CoordinateInCoordinates(coor, AllCoordinates):
                    DifferenceCoordinates.append(coor)
            return DifferenceCoordinates

        AllCoordinates = [coordinate]
        NewCoordinates = CoorTrans.SymmetricOperation(coordinate, matrices, 6)
        DifferenceCoordinates = GetDifferenceCoordinates(AllCoordinates, NewCoordinates)
        AllCoordinates = AllCoordinates + DifferenceCoordinates
        while len(DifferenceCoordinates) != 0:
            NewCoordinates = []
            for coor in DifferenceCoordinates:
                Coordinates = CoorTrans.SymmetricOperation(coor, matrices, 6)
                for c in Coordinates:
                    if not CoorTrans.CoordinateInCoordinates(c, NewCoordinates):
                        NewCoordinates.append(c)
            DifferenceCoordinates = GetDifferenceCoordinates(AllCoordinates, NewCoordinates)
            AllCoordinates = AllCoordinates + DifferenceCoordinates
        return AllCoordinates

    UniqueAtom = []
    wyckoffs, wyckoff_matrices = CoorTrans.GetMatrix(SpaceGroupName)
    matrices = wyckoff_matrices[wyckoffs[0]]


    while coordinates:
        coordinate = coordinates[0]
        UniqueOneAtom = []
        allcoordinates = CalculateAllGeneralCoordintaes(coordinate, matrices)
        for allcoordinate in allcoordinates:
            for coordinate2 in coordinates:
                if CoorTrans.Compare2Coordinate(allcoordinate, coordinate2, 3):
                    UniqueOneAtom.append(coordinate2)
                    coordinates.remove(coordinate2)
        UniqueAtom.append(UniqueOneAtom)

    return UniqueAtom


def CalculateOxygens(mindistance, maxdistance, GroupName, CellParameter, Atom_Coordinate):
    def Combinations(L, k):
        n = len(L)
        result = []
        # To Place Combination result
        for i in range(n - k + 1):
            if k > 1:
                newL = L[i + 1:]
                Comb = Combinations(newL, k - 1)
                for item in Comb:
                    item.insert(0, L[i])
                    result.append(item)
            else:
                result.append([L[i]])
        return result


    def Calculate27Cell(AllCoordinates):

        All27CellCoordinates = []
        for coordinate in AllCoordinates:
            x = coordinate[0]
            y = coordinate[1]
            z = coordinate[2]
            All27CellCoordinates.append([x, y, z])

            All27CellCoordinates.append([x + 1, y, z])
            All27CellCoordinates.append([x, y + 1, z])
            All27CellCoordinates.append([x, y, z + 1])
            All27CellCoordinates.append([x + 1, y + 1, z])
            All27CellCoordinates.append([x + 1, y, z + 1])
            All27CellCoordinates.append([x, y + 1, z + 1])
            All27CellCoordinates.append([x + 1, y + 1, z + 1])

            All27CellCoordinates.append([x - 1, y, z])
            All27CellCoordinates.append([x, y - 1, z])
            All27CellCoordinates.append([x, y, z - 1])
            All27CellCoordinates.append([x - 1, y - 1, z])
            All27CellCoordinates.append([x - 1, y, z - 1])
            All27CellCoordinates.append([x, y - 1, z - 1])
            All27CellCoordinates.append([x - 1, y - 1, z - 1])

            All27CellCoordinates.append([x + 1, y - 1, z])
            All27CellCoordinates.append([x, y, z - 1])
            All27CellCoordinates.append([x, y + 1, z - 1])

            All27CellCoordinates.append([x - 1, y + 1, z])
            All27CellCoordinates.append([x - 1, y, z + 1])
            All27CellCoordinates.append([x, y - 1, z + 1])

            All27CellCoordinates.append([x + 1, y + 1, z - 1])
            All27CellCoordinates.append([x + 1, y - 1, z + 1])
            All27CellCoordinates.append([x + 1, y - 1, z - 1])
            All27CellCoordinates.append([x - 1, y + 1, z + 1])
            All27CellCoordinates.append([x - 1, y + 1, z - 1])
            All27CellCoordinates.append([x - 1, y - 1, z + 1])
        return All27CellCoordinates


    def Deal27CellCoordinate(maxdistance, All27CellCoordinates):
        Limit27CellCoordinate = []
        for Coordinate in All27CellCoordinates:
            if (Coordinate[0] >= 1 + maxdistance or Coordinate[0] <= -1 - maxdistance) or (
                    Coordinate[1] >= 1 + maxdistance or Coordinate[1] <= -1 - maxdistance) or (
                    Coordinate[2] >= 1 + maxdistance or Coordinate[2] <= -1 - maxdistance):
                continue
            Limit27CellCoordinate.append(Coordinate)
        return Limit27CellCoordinate


    def Add0xygenAtom(mindistance2, maxdistance2, Limit27CellCoordinate):
        def CalculateMidpoint(coordinate1, coordinate2, retain = 6):
            x1 = coordinate1[0]
            y1 = coordinate1[1]
            z1 = coordinate1[2]

            x2 = coordinate2[0]
            y2 = coordinate2[1]
            z2 = coordinate2[2]

            x = round((x1 + x2) / 2, retain)
            y = round((y1 + y2) / 2, retain)
            z = round((z1 + z2) / 2, retain)
            return [x, y, z]


        def JudgeCoorInCell(coordinate):
            x = coordinate[0]
            y = coordinate[1]
            z = coordinate[2]
            if x < 0 or x >= 1 or y < 0 or y >= 1 or z < 0 or z >= 1:
                return False
            return True


        OxygenCoordinate = []
        for i in range(len(Limit27CellCoordinate)):
            for j in range(i + 1, len(Limit27CellCoordinate)):
                coordinate1 = Limit27CellCoordinate[i]
                coordinate2 = Limit27CellCoordinate[j]
                distance = CoorTrans.CalculateDistance2(CoorTrans.Fractional2Cartesian(coordinate1, CellParameter), CoorTrans.Fractional2Cartesian(coordinate2, CellParameter, 6))
                if mindistance2 <= distance <= maxdistance2:
                    Oxygen = CalculateMidpoint(coordinate1, coordinate2)
                    if JudgeCoorInCell(Oxygen):
                        if not CoorTrans.CoordinateInCoordinates(Oxygen, OxygenCoordinate):
                            OxygenCoordinate.append(Oxygen)
        return OxygenCoordinate


    AllCoordinates = []
    Atom_SiCoordinates = {}
    mindistance2 = mindistance**2
    maxdistance2 = maxdistance**2

    wyckoffs, wyckoff_matrices = CoorTrans.GetMatrix(GroupName)
    for Atom, coordinate in Atom_Coordinate.items():
        finalwyc, finalcoordinate = CalculateWyc.CalculateAtomWyc(coordinate, wyckoffs, wyckoff_matrices)
        Coordinates = CoorTrans.SymmetricOperation(coordinate, wyckoff_matrices[finalwyc], 6)
        Atom_SiCoordinates[Atom] = Coordinates
        for coordinate in Coordinates:
            AllCoordinates.append(coordinate)
    All27CellCoordinates = Calculate27Cell(AllCoordinates)
    Limit27CellCoordinate = Deal27CellCoordinate(maxdistance/ min(CellParameter[0], CellParameter[1], CellParameter[2]), All27CellCoordinates)
    OxygenCoordinate = Add0xygenAtom(mindistance2, maxdistance2, Limit27CellCoordinate)
    UniqueOxygenAtoms = CalulateUniqueAtom(GroupName, OxygenCoordinate)

    Atom_OxygenCoordinates = {}
    i = 1
    for UniqueOxygen in  UniqueOxygenAtoms:
        Atom_OxygenCoordinates['O'+str(i)] = UniqueOxygen
        i = i + 1
    return Atom_SiCoordinates, Atom_OxygenCoordinates


def CalculateOxygenCoordinate(mindistance, maxdistance, Atom_Rectangulars):
    OxygenCoordinates = []
    number_rectangulars = {}
    i = 0
    for Atom, Rectangulars in Atom_Rectangulars.items():
        for Rectangular in Rectangulars:
            number_rectangulars[i] = Rectangular
            i = i + 1
    return OxygenCoordinates


def CalculateRectangulars(GroupName, CellParameter, Atom_Coordinate, retain = 6):
    Atom_Rectangulars = {}
    wyckoffs, wyckoff_matrices = CoorTrans.GetMatrix(GroupName)
    for Atom, coordinate in Atom_Coordinate.items():
        finalwyc, finalcoordinate = CalculateWyc.CalculateAtomWyc(coordinate, wyckoffs, wyckoff_matrices)
        rectangulars = []
        Coordinates = CoorTrans.SymmetricOperation(coordinate, wyckoff_matrices[finalwyc], retain)

        for coordinate in Coordinates:
            rectangulars.append(CoorTrans.Fractional2Cartesian(coordinate, CellParameter, retain))
        Atom_Rectangulars[Atom] = rectangulars
    return Atom_Rectangulars


def AddFileOxygen(filename, outpath, mindistance, maxdistance):
    def ReadCifFile(filename):

        # filename = 'cifinput/1_198.cif'
        Name = ExtractInformation.GetInformation(filename, 'data_FraGen\((\d+)_(\d+)_(\d+)', 3)
        Lit = ExtractInformation.GetInformation(filename, 'data_FraGen\((\d+)_(\d+)_(\d+)', 2)
        GroupName = ExtractInformation.GetInformation(filename, '_symmetry_space_group_name_H-M\s+[\'|\"]?(\S+)[\'|\"]?', 1)
        a = float(ExtractInformation.GetInformation(filename, '_cell_length_a\s*(-?[\d|.]+)', 1))
        b = float(ExtractInformation.GetInformation(filename, '_cell_length_b\s*(-?[\d|.]+)', 1))
        c = float(ExtractInformation.GetInformation(filename, '_cell_length_c\s*(-?[\d|.]+)', 1))
        A = float(ExtractInformation.GetInformation(filename, '_cell_angle_alpha\s*(-?[\d|.]+)', 1))
        B = float(ExtractInformation.GetInformation(filename, '_cell_angle_beta\s*(-?[\d|.]+)', 1))
        C = float(ExtractInformation.GetInformation(filename, '_cell_angle_gamma\s*(-?[\d|.]+)', 1))
        CellParameter = [a, b, c, A, B, C]

        Atom_Coordinate = {}
        file = open(filename, 'r')
        while True:
            line = file.readline()
            if not line:
                break
            if '_atom_site_fract_z' in line:
                while True:
                    line = file.readline()
                    if (not line.strip()) and ('#' not in line):
                        break
                    Atom = line.split()[0]
                    Coordinate = [float(line.split()[2]), float(line.split()[3]), float(line.split()[4])]
                    Atom_Coordinate[Atom] = Coordinate

        # print(Name)
        # print(Lit)
        # print(GroupName)
        # print(CellParameter)
        # print(Atom_Coordinate)
        return Name, Lit, GroupName, CellParameter, Atom_Coordinate

    def Write2ciffile(filename, groupname, cellparameter, Atom_SiCoordinates, Atom_OxygenCoordinates):
        file = open(filename, 'w')
        form1 = "{0:<35}{1:<20}\n"
        formpara = "{0:<35}{1:.4f}\n"
        file.write('data_FraGen(' + str(CoorTrans.Groupname2Groupnum(groupname)) + '_' + filename.split('/')[-1].split('\\')[-1].split('.')[0] + ')\n')

        file.write(form1.format('_audit_creation_method', 'FraGen-AddOxygen'))
        file.write(form1.format('_symmetry_space_group_name_H-M',groupname))
        file.write(form1.format('_symmetry_Int_Tables_number', CoorTrans.Groupname2Groupnum(groupname)))
        file.write(formpara.format('_cell_length_a', cellparameter[0]))
        file.write(formpara.format('_cell_length_b', cellparameter[1]))
        file.write(formpara.format('_cell_length_c', cellparameter[2]))
        file.write(formpara.format('_cell_angle_alpha', cellparameter[3]))
        file.write(formpara.format('_cell_angle_beta', cellparameter[4]))
        file.write(formpara.format('_cell_angle_gamma', cellparameter[5]))

        symmetryEquivPosAsXyzs = CoorTrans.GetSymmetryEquivPosAsXyz(groupname)
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
        form2 = "{0:<8}{1:12}{2:.6f}  {3:.6f}  {4:.6f}\n"
        for Atom, Coordinates in Atom_SiCoordinates.items():
            Coordinate = Coordinates[0]
            file.write(form2.format(Atom, 'Si', Coordinate[0], Coordinate[1], Coordinate[2]))
        for Atom, Coordinates in Atom_OxygenCoordinates.items():
            Coordinate = Coordinates[0]
            file.write(form2.format(Atom, 'O', Coordinate[0], Coordinate[1], Coordinate[2]))
        file.close()


    StrName, Lit, GroupName, CellParameter, Atom_Coordinate = ReadCifFile(filename)



    Atom_SiCoordinates, Atom_OxygenCoordinates = CalculateOxygens(mindistance, maxdistance, GroupName, CellParameter, Atom_Coordinate)
    Write2ciffile(outpath + '/' +filename.split('/')[-1].split('.')[0] + '.cif', GroupName, CellParameter, Atom_SiCoordinates, Atom_OxygenCoordinates)
    print('AddOxygen ' + filename + ' > ' + outpath + '/' + filename.split('/')[-1].split('.')[0] + '.cif' + ' done!')


def AddOxygen(inpath, outpath, logfilename, mindistance, maxdistance):
    # read cif file

    logfile = open(logfilename, 'w')
    logfile.write("#\n")
    logfile.write("########################################\n")
    logfile.write("#                         AddOxygen v1.0\n")
    logfile.write("#                            2019-Apr-15\n")
    logfile.write("#                           by wangjiaze\n")
    logfile.write("########################################\n")
    logfile.write("#\n")

    starttime = datetime.datetime.now()
    logfile.write("# Starttime:  "+ str(starttime) + '\n\n')

    sfilenames = ExtractInformation.GetFilenames(inpath, 'cif')
    for sfilename in sfilenames:
        AddFileOxygen(sfilename, outpath, mindistance, maxdistance)
        logfile.write('AddOxygen ' + sfilename + ' > ' + outpath + '/' + sfilename.split('/')[-1].split('.')[
            0] + 'cif' + ' done!\n')


    endtime = datetime.datetime.now()
    logfile.write("\n# Starttime:  " + str(starttime) + '\n')
    logfile.write("# Endtime:  "+ str(endtime) + '\n')

    logfile.close()
    print("\nAll DONE!")
    return


def ReadParameterFile(filename):
    file = open(filename, 'r')
    line = file.readline()
    sfilename = line.strip()

    line = file.readline()
    outpath = line.strip()

    line = file.readline()
    mindistance = float(line.strip())

    line = file.readline()
    maxdistance = float(line.strip())

    file.close()
    return sfilename, outpath, mindistance, maxdistance


if __name__ == '__main__':
    print()
    print("####################")
    print("      AddOxygen v1.1")
    print("          2019-Jul-8")
    print("        by wangjiaze")
    print("####################")
    print()
    '''
    mindistance = 0
    maxdistance = 3.700
    logfilename = 'AddOxygen.log'
    inpath = 'cifinput'
    outpath = 'output'

    AddOxygen(inpath, outpath, logfilename, mindistance, maxdistance)

    # parafilename = sys.argv[1]
    # sfilename, outpath, mindistance, maxdistance = ReadParameterFile(parafilename)
    '''

    # AddFileOxygen(sfilename, outpath, mindistance, maxdistance)

    #parafilename = sys.argv[1]
    #ciffilename, outpath, mindistance, maxdistance = ReadParameterFile(parafilename)
    ciffilename = sys.argv[1]
    outpath = sys.argv[2]
    logfilename = 'AddOxygen.log'
    mindistance = float(sys.argv[3])
    maxdistance = float(sys.argv[4])
    
    #AddOxygen(ciffilepath, outpath, logfilename, mindistance, maxdistance)
    AddFileOxygen(ciffilename, outpath, mindistance, maxdistance)
