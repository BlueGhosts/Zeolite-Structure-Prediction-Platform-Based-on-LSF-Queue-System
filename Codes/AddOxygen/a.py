file = open('SpaceGroup.txt', 'r')

line = file.readline()
Groupnum_Groupname = {}
Groupname_Groupnum = {}
while line:
    strnum = int(line.split()[0])
    groupname= line.split()[1]
    Groupnum_Groupname[strnum] = groupname
    Groupname_Groupnum[groupname] = strnum
    line = file.readline()

print(Groupname_Groupnum)
print()
print(Groupnum_Groupname)