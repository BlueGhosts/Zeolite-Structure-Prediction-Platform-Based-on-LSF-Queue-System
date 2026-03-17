import re
import sys
import time
import operator


# python CsqCheck v1.0
# by wangjiaze on 2019-Sep-03




if __name__ == '__main__':
    print()
    print("####################")
    print("       CsqCheck v1.0")
    print("         2019-Sep-02")
    print("        by wangjiaze")
    print("####################")
    print()

    starttime = time.perf_counter()

    # filename = input('Please input the parameter file name:\n')
    filename = '../para.txt'
    # filename = sys.argv[1]
    allCsqs, structures = CsqCheck(filename)


    endtime = time.perf_counter()
    print('Total CPU time: ' + str(round(endtime - starttime, 4)) + 's')