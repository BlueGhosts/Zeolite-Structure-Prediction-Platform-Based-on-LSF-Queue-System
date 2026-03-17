import datetime

import CoordinateTransformation as CoorTrans

from AddOxygen import ExtractInformation


# CalculateWyc v1.4
# by wangjiaze on 2019-Apr-9
# V1.3 improve output part
# V1.4 calculate all general coordinate and return now atom coordinate


def CalculateAtomWyc(coordinate, wyckoffs, wyckoff_matrices):
    def CalculateAllGeneralCoordintaes(coordinate, matrices):

        def GetDifferenceCoordinates(AllCoordinates, NewCoordinates):
            DifferenceCoordinates = []
            for coor in NewCoordinates:
                if not CoorTrans.CoordinateInCoordinates(coor, AllCoordinates):
                    DifferenceCoordinates.append(coor)
            return DifferenceCoordinates

        AllCoordinates = [coordinate]
        NewCoordinates = CoorTrans.SymmetricOperation(coordinate, matrices)
        DifferenceCoordinates = GetDifferenceCoordinates(AllCoordinates, NewCoordinates)
        AllCoordinates = AllCoordinates + DifferenceCoordinates
        while len(DifferenceCoordinates) != 0:
            NewCoordinates = []
            for coor in DifferenceCoordinates:
                Coordinates = CoorTrans.SymmetricOperation(coor, matrices)
                for c in Coordinates:
                    if not CoorTrans.CoordinateInCoordinates(c, NewCoordinates):
                        NewCoordinates.append(c)
            DifferenceCoordinates = GetDifferenceCoordinates(AllCoordinates, NewCoordinates)
            AllCoordinates = AllCoordinates + DifferenceCoordinates
        return AllCoordinates


    def CalculateCoordinateWyc(coordinate, wyckoffs, wyckoff_matrices):
        AllCoordinates = CoorTrans.SymmetricOperation(coordinate, wyckoff_matrices[wyckoffs[0]])
        for i in range(len(wyckoffs), 0, -1):
            wyc = wyckoffs[i - 1]
            if len(AllCoordinates) > len(wyckoff_matrices[wyc]):
                continue
            else:
                wycCoordinates = CoorTrans.SymmetricOperation(coordinate, wyckoff_matrices[wyc])
                if CoorTrans.Compare2Coordinates(AllCoordinates, wycCoordinates, True):
                    return wyc, coordinate


    AllCoordinates = CalculateAllGeneralCoordintaes(coordinate, wyckoff_matrices[wyckoffs[0]])
    finalwyc = wyckoffs[0]
    finalcoordinate = coordinate
    for coor in AllCoordinates:
        wyc, newcoordinate = CalculateCoordinateWyc(coor, wyckoffs, wyckoff_matrices)
        if wyc == 'A':
            wyc = chr(ord("z") + 1)
        if wyc < finalwyc:
            finalwyc = wyc
            finalcoordinate = newcoordinate
    return finalwyc, finalcoordinate


def CalculateFileWyc(ciffilename):
    AtomName_AtomCoordinate = {}
    groupname = ExtractInformation.GetInformation(ciffilename, "_symmetry_space_group_name_H-M\s*\'(.*)\'", 1)
    AtomInformations = ExtractInformation.GetInformations(ciffilename, "(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+)", 1)

    for AtomInformation in AtomInformations:
        Atom = AtomInformation.split()
        AtomElement = Atom[1]
        if AtomElement == 'Si' or AtomElement == 'Al' or AtomElement == 'C':
            AtomName = Atom[0]
            AtomCoordinate = [float(Atom[2]), float(Atom[3]), float(Atom[4])]
            AtomName_AtomCoordinate[AtomName] = AtomCoordinate

    groupname = "".join(groupname.split()).upper()
    wyckoffs, wyckoff_matrices = CoorTrans.GetMatrix(groupname)
    AtomName_Wyckoff = {}
    AtomName_NewCoordinate = {}
    for AtomName in AtomName_AtomCoordinate:
        wyc, coordinate = CalculateAtomWyc(AtomName_AtomCoordinate[AtomName], wyckoffs, wyckoff_matrices)
        AtomName_Wyckoff[AtomName] = wyc
        AtomName_NewCoordinate[AtomName] = coordinate
    return AtomName_Wyckoff, AtomName_NewCoordinate


def CalculateWyc(cifdic, outfilename):
    def WriteWyc2File(file, cifname, AtomName_Wyckoff, AtomName_NewCoordinate):
        # file.write("#########\n")
        file.write(cifname)
        wyckoffs = []
        for wyc in AtomName_Wyckoff.values():
            wyckoffs.append(wyc)
        wyckoffs.sort()
        file.write("  " + "".join(wyckoffs))
        # for atomname in AtomName_Wyckoff:
        #     file.write('\n' + atomname + '  ' + str(AtomName_NewCoordinate[atomname]) + '  '+ AtomName_Wyckoff[atomname])
        file.write('\n')


    outfile = open(outfilename, 'w')
    outfile.write("\n")
    outfile.write("########################################\n")
    outfile.write("#                      CalculateWyc v1.4\n")
    outfile.write("#                             2019-Apr-9\n")
    outfile.write("#                           by wangjiaze\n")
    outfile.write("########################################\n")
    outfile.write("\n")

    starttime = datetime.datetime.now()
    outfile.write("# Starttime:  "+ str(starttime) + '\n\n')

    ciffilenames = ExtractInformation.GetFilenames(cifdic, 'cif')
    cifname_atomname_wyckoffs = {}
    cifname_atomname_newcoordinate = {}
    for ciffilename in ciffilenames:
        cifname = ciffilename.split('/')[-1]
        AtomName_Wyckoff, AtomName_NewCoordinate = CalculateFileWyc(ciffilename)
        cifname_atomname_wyckoffs[cifname] = AtomName_Wyckoff
        cifname_atomname_newcoordinate[cifname] = AtomName_NewCoordinate
        WriteWyc2File(outfile, cifname, AtomName_Wyckoff, AtomName_NewCoordinate)
        print('CalculateWyc ' + ciffilename + ' done!')

    endtime = datetime.datetime.now()
    outfile.write("\n# Starttime:  " + str(starttime) + '\n')
    outfile.write("# Endtime:  "+ str(endtime) + '\n')

    outfile.close()
    print("\nAll DONE!")
    return cifname_atomname_wyckoffs, cifname_atomname_newcoordinate


if __name__ == '__main__':
    print("\n####################")
    print("   CalculateWyc v1.4")
    print("          2019-Apr-9")
    print("        by wangjiaze")
    print("####################")
    print()

    # cifdic = input('Please input the cif folder path:\n')
    # outfilename = input('Please input the output file name:\n')

    cifdic = 'E:\work\deem-233-compare\deem-cif\REDEFINELATTICE-findsym'
    outfilename = '58-CBA-wyc-findsym.txt'

    cifname_atomname_wyckoffs = CalculateWyc(cifdic, outfilename)
    # WriteWyc2File(outfilename, cifname_atomname_wyckoffs)
    # print(cifname_atomname_wyckoffs)

    input("Press any key to finish.\n")