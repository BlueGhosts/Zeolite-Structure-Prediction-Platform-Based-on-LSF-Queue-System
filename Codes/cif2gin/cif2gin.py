import sys

import ExtractInformation

# cif2gin v1.0
# by wangjiaze on 2019-Apr-17
def cif2gin(ciffilename, ginfilename, newciffilename):
    def ReadCiffile(filename):
        Atom_Coordinate = {}
        Atom_AtomElement = {}
        groupname = ExtractInformation.GetInformation(ciffilename, "_symmetry_space_group_name_H-M\s*(.*)", 1)
        groupnum = int(ExtractInformation.GetInformation(ciffilename, "_symmetry_Int_Tables_number\s*(.*)", 1))
        a = float(ExtractInformation.GetInformation(ciffilename, "_cell_length_a\s+(.*)", 1))
        b = float(ExtractInformation.GetInformation(ciffilename, "_cell_length_b\s+(.*)", 1))
        c = float(ExtractInformation.GetInformation(ciffilename, "_cell_length_c\s+(.*)", 1))
        A = float(ExtractInformation.GetInformation(ciffilename, "_cell_angle_alpha\s+(.*)", 1))
        B = float(ExtractInformation.GetInformation(ciffilename, "_cell_angle_beta\s+(.*)", 1))
        C = float(ExtractInformation.GetInformation(ciffilename, "_cell_angle_gamma\s+(.*)", 1))
        CellParameter = [a, b, c, A, B, C]
        AtomInformations = ExtractInformation.GetInformations(ciffilename, "(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+)", 1)
        for AtomInformation in AtomInformations:
            Atom = AtomInformation.split()
            AtomName = Atom[0]
            AtomElement = Atom[1]
            AtomCoordinate = [float(Atom[2]), float(Atom[3]), float(Atom[4])]
            Atom_AtomElement[AtomName] = AtomElement
            Atom_Coordinate[AtomName] = AtomCoordinate
        return groupname, groupnum, CellParameter, Atom_AtomElement, Atom_Coordinate

    def WriteGinfile(filename, newciffilename, groupname, groupnum, CellParameter, Atom_AtomElement, Atom_Coordinate):
        file = open(filename, 'w')
        file.write('opti conp nodens\n')
        file.write('pressure 0\n')
        file.write('cell\n')
        for a in CellParameter:
            file.write('\t' + str(a))
        file.write('\n')
        file.write('fractional\n')
        form = "{0:<5}{1:<1}\t{2:.6f} {3:.6f} {4:.6f}\n"
        for Atom in Atom_AtomElement:
            coordinate = Atom_Coordinate[Atom]
            if Atom_AtomElement[Atom] == 'Si':
                file.write(form.format(Atom, 'c', coordinate[0], coordinate[1], coordinate[2]))
            if Atom_AtomElement[Atom] == 'O':
                file.write(form.format(Atom, 'c', coordinate[0], coordinate[1], coordinate[2]))
                file.write(form.format(Atom, 's', coordinate[0], coordinate[1], coordinate[2]))
        file.write('species\n')
        file.write('O core O_O2-\n')
        file.write('O shel O_O2-\n')
        file.write('Si core Si\n')
        file.write('spacegroup\n')
        file.write(str(groupnum) + '\n')
        file.write('Origin 2\n')
        file.write('library catlow\n')
        file.write('output cif  '+ newciffilename +'\n')
        file.write('\n')

        return

    groupname, groupnum, CellParameter, Atom_AtomElement, Atom_Coordinate = ReadCiffile(ciffilename)
    WriteGinfile(ginfilename, newciffilename, groupname, groupnum, CellParameter, Atom_AtomElement, Atom_Coordinate)


if __name__ == '__main__':
    print()
    print("####################")
    print("        cif2gin v1.0")
    print("         2019-Apr-17")
    print("        by wangjiaze")
    print("####################")
    print()

    ciffilename = sys.argv[1]
    ginfilename = sys.argv[2]
    newciffilename = sys.argv[3]
    newciffilename = newciffilename.split('.')[0]

    cif2gin(ciffilename, ginfilename, newciffilename)