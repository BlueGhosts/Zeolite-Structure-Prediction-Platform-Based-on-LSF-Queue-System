import sys
import ExtractInformation

# python ExpandCell -v1.1
# by wangjiaze on 2019-Aug-20
# Add Times




def ExpandCellParameter(cellParameter, times = 1):
    newCellParameter = []
    for a in cellParameter[0: 3]:
        newCellParameter.append(a*((1.01)**times))
    newCellParameter = newCellParameter + cellParameter[3:]
    return newCellParameter


def ExpandCell(cifFilename, outcifpath, times):
    filename = cifFilename.split('/')[-1].split('\\')[-1]
    outcifname = outcifpath + '/' +filename
    spaceGroup, groupNumber, cellParameter, atom_atomElement, atom_coordinate = ExtractInformation.ReadCif(cifFilename)
    newCellParameter = ExpandCellParameter(cellParameter, times)
    ExtractInformation.WriteCif(outcifname, spaceGroup, groupNumber, newCellParameter, atom_atomElement, atom_coordinate)
    print('ExpandCell ' + ciffilename + ' > ' + outcifname)
    # cifname = cifFilename.split('/')[-1].split('\\')[-1]




if __name__ == '__main__':
    print()
    print('####################')
    print('    ExpandCell v-1.0')
    print('         2019-Aug-18')
    print('        by wangjiaze')
    print('####################')
    print()


    # ciffilename = input('Input cif file path:\n')
    # outcifpath = input('Output cif folder path:\n')

    ciffilename = sys.argv[1]
    outcifpath = sys.argv[2]
    times = int(sys.argv[3])
    ExpandCell(ciffilename, outcifpath, times)