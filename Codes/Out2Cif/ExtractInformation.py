import os
import re


# ExtractInformation v1.1.1
# by wangjiaze on 2019-Apr-10
# V1.1.1 ExtensionName = False


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


if __name__ == '__main__':
    pass