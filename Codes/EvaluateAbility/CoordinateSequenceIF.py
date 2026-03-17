import re
import statistics

# python CoordinateSequenceIF v2.0
# by wangjiaze on 2022-Mar-24  Add  csqStd_requirement Judge

def CompareCsq(csq1, csq2):
    if csq1.atomnum != csq2.atomnum:
        return False
    else:
        if csq1.csqnum == csq2.csqnum:
            for lastcsq in csq1.lastcsqs:
                if lastcsq not in csq2.lastcsqs:
                    return False

            for atomcsq in csq1.atomcsqs:
                if atomcsq not in csq2.atomcsqs:
                    return False
        else:
            mincsqnum = min(csq1.csqnum, csq2.csqnum)
            atomcsqs1 = csq1.GetAtomcsqs(mincsqnum)
            atomcsqs2 = csq2.GetAtomcsqs(mincsqnum)
            for atomcsq in atomcsqs1:
                if atomcsq not in atomcsqs2:
                    return False
    return True


class CoordinateSequenceIF():
    def __init__(self, name, atomcsqs, referenceCsqs, filename, csqRequirements = {}, csqStd_requirement = {}):
        self.name = name

        self.atomcsqs = []
        for atomcsq in atomcsqs:
            if atomcsq not in self.atomcsqs:
                self.atomcsqs.append(atomcsq)

        self.lastcsqs = [ atomcsq[-1] for atomcsq in atomcsqs]
        self.atomnum = len(self.atomcsqs)
        self.csqnum = len(self.atomcsqs[0])
        self.isAllowed = self.Judge(csqRequirements, csqStd_requirement)

        self.reference = self.CompareReference(referenceCsqs)
        self.frequency = 1
        self.filename = filename

        if 'Cost' in name:
            self.cost = float(name.split()[-1])
        else:
            self.cost = 0

        if 'Cycle'in name:
            self.cycle = int(re.search('Cycle\s(\d+),', name).group(1))

    def CompareReference(self, referenceCsqs):
        for referenceCsq in referenceCsqs:
            if CompareCsq(self, referenceCsq):
                return referenceCsq.name
        return '?'


    def FrequencyAddOne(self):
        self.frequency = self.frequency + 1


    def Judge(self, csqRequirements = {}, csqStd_requirement = {}):
        # check 3 - dimension
        if csqRequirements:
            for csqOrder in csqRequirements:
                if csqOrder > self.csqnum - 1:
                    continue
                for atomcsq in self.atomcsqs:
                    if int(atomcsq[csqOrder]) < csqRequirements[csqOrder][0] or int(atomcsq[csqOrder]) > csqRequirements[csqOrder][1]:
                        return False
        if csqStd_requirement:
            for csqOrder in csqStd_requirement:
                if csqOrder > self.csqnum - 1:
                    continue
                csqlist = [ self.atomcsqs[i][csqOrder] for i in range(len(self.atomcsqs))]
                std = statistics.stdev(csqlist)
                if std < csqStd_requirement[csqOrder][0] or std > csqStd_requirement[csqOrder][1]:
                    print(self.name)
                    print(csqOrder)
                    print(std)
                    return False
        return True


    def GetAtomcsqs(self, number):
        atomcsqs = []
        for atomcsq in self.atomcsqs:
            atomcsqs.append(atomcsq[:number])
        return atomcsqs


    def UpdateCsq(self, csq2):
        self.frequency = csq2.frequency + 1

