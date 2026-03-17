import os
import re


# ExtractInformation v1.5
# by wangjiaze on 2019-Aug-31
# V1.1.1 ExtensionName = False
# V1.2 AddFuntion WriteCif ReadCif
# V1.3 AddFuntion GetAfterInformation
# V1.4 ReadCif(filename, software = 'MS') support  GULP cif
# V1.5 AddFuntion GetLinesInformation(lines, MatchPattern, GroupNumber)


def GetFilenames(FolderName, ExtensionName = False):
    filenames = []
    for filename in os.listdir(FolderName):
        if ExtensionName:
            if filename.split('.')[-1] == ExtensionName:
                filenames.append(FolderName + '/' +filename)
        else:
            filenames.append(FolderName + '/' + filename)
    return filenames


def GetInformation(Filename, MatchPattern, GroupNumber):
    file = open(Filename, 'r')
    information = False
    while True:
        line = file.readline()
        if not line:
            if information == False:
                information = 'error'
                return information
        match = re.search(MatchPattern, line)
        if match:
            information = re.search(MatchPattern, line).group(GroupNumber)
            return information


def GetAfterInformation(file, MatchPattern, GroupNumber):
    position = file.tell()
    information = False
    while True:
        line = file.readline()
        if not line:
            if information == False:
                information = 'error'
                file.seek(position)
                return information
        match = re.search(MatchPattern, line)
        if match:
            information = re.search(MatchPattern, line).group(GroupNumber)
            file.seek(position)
            return information


def GetInformations(Filename, MatchPattern, GroupNumber):
    file = open(Filename, 'r')
    informations = []

    while True:
        line = file.readline()
        if not line:
            return informations
        match = re.search(MatchPattern, line)
        if match:
            informations.append(re.search(MatchPattern, line).group(GroupNumber))


def GetLinesInformation(lines, MatchPattern, GroupNumber):
    for line in lines:
        match = re.search(MatchPattern, line)
        if match:
            information = re.search(MatchPattern, line).group(GroupNumber)
            return information
    return False


def WriteCif(cifFilename, spaceGroup, groupNumber, cellParameter, atom_atomElement, atom_coordinate):
    import CoordinateTransformation as CoorTrans

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
    for atom in atom_atomElement:
        # print(atom)
        atomElement = atom_atomElement[atom]
        coordinate = atom_coordinate[atom]
        file.write(formAtom.format(atom, atomElement, coordinate[0], coordinate[1], coordinate[2]))
    file.close()


def ReadCif(filename, software = 'MS'):
    if software == 'MS':
        atom_coordinate = {}
        atom_atomElement = {}
        spaceGroup = GetInformation(filename, "_symmetry_space_group_name_H-M\s*(\S*)", 1).strip()
        groupNumber = int(GetInformation(filename, "_symmetry_Int_Tables_number\s*(\S*)", 1))
        a = float(GetInformation(filename, "_cell_length_a\s+(\S*)", 1))
        b = float(GetInformation(filename, "_cell_length_b\s+(\S*)", 1))
        c = float(GetInformation(filename, "_cell_length_c\s+(\S*)", 1))
        A = float(GetInformation(filename, "_cell_angle_alpha\s+(\S*)", 1))
        B = float(GetInformation(filename, "_cell_angle_beta\s+(\S*)", 1))
        C = float(GetInformation(filename, "_cell_angle_gamma\s+(\S*)", 1))
        cellParameter = [a, b, c, A, B, C]
        AtomInformations = GetInformations(filename, "(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+)", 1)
        for AtomInformation in AtomInformations:
            Atom = AtomInformation.split()
            AtomName = Atom[0]
            AtomElement = Atom[1]
            AtomCoordinate = [float(Atom[2]), float(Atom[3]), float(Atom[4])]
            atom_atomElement[AtomName] = AtomElement
            atom_coordinate[AtomName] = AtomCoordinate
        return spaceGroup, groupNumber, cellParameter, atom_atomElement, atom_coordinate
    elif software.upper() == 'GULP':
        import CoordinateTransformation as CoorTrans
        atom_coordinate = {}
        atom_atomElement = {}
        groupNumber = int(GetInformation(filename, "_symmetry_Int_Tables_number\s*(\S*)", 1))
        spaceGroup = CoorTrans.Groupnum2Groupname(groupNumber)
        a = float(GetInformation(filename, "_cell_length_a\s+(\S*)", 1))
        b = float(GetInformation(filename, "_cell_length_b\s+(\S*)", 1))
        c = float(GetInformation(filename, "_cell_length_c\s+(\S*)", 1))
        A = float(GetInformation(filename, "_cell_angle_alpha\s+(\S*)", 1))
        B = float(GetInformation(filename, "_cell_angle_beta\s+(\S*)", 1))
        C = float(GetInformation(filename, "_cell_angle_gamma\s+(\S*)", 1))
        cellParameter = [a, b, c, A, B, C]
        AtomInformations = GetInformations(filename, "(\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+)", 1)

        element_num = {}
        for AtomInformation in AtomInformations:
            Atom = AtomInformation.split()
            AtomElement = re.match('(\w+)(\d+)', Atom[0]).group(1)
            if AtomElement not in element_num:
                element_num[AtomElement] = 1
            else:
                element_num[AtomElement] = element_num[AtomElement] + 1
            AtomName = AtomElement + str(element_num[AtomElement])
            AtomCoordinate = [float(Atom[1]), float(Atom[2]), float(Atom[3])]
            atom_atomElement[AtomName] = AtomElement
            atom_coordinate[AtomName] = AtomCoordinate
        return spaceGroup, groupNumber, cellParameter, atom_atomElement, atom_coordinate


if __name__ == '__main__':
    pass