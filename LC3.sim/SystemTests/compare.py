# Open the file in read mode
import sys


PENNSIM_TRACE = "pennsim_trace.hex"
VERILOG_TRACE = "verilog_trace.hex"
PENNSIM_MEMDUMP = "pennsim_memDump.hex"
VERILOG_MEMDUMP = "verilog_memDump.hex"

def compare(path_a, path_b, log):
    a = open(path_a, "r")
    b = open(path_b, "r")
    l = open(log, "a")
    mismatches = []
    aName = a.name.split('\\')[-1]
    bName = b.name.split('\\')[-1]
    temp = b.name.split('\\')[-2]
    print(f"Mismatches between {aName} and {bName} in {temp}:",file=l)
    print("")
    for i in range(1,100):
        lineA = a.readline().strip().upper().replace('X','0')
        lineB = b.readline().strip().upper().replace('X','0')

        doPrint = False;
        if(lineA != lineB):
            if(lineA and not lineB):
                #print(lineA, "\t", lineB)
                #print(lineA[0],lineA.count(lineA[0]),len(lineA),lineA.count(' '))
                if(lineA.count('0') !=  len(lineA) - lineA.count(' ')):
                    doPrint = True;
            elif(lineB and not lineA):
                #print(lineA, "\t", lineB)
                #print(lineB[0], lineB.count(lineB[0]), len(lineB), lineB.count(' '))
                if(lineB.count('0') !=  len(lineB)- lineB.count(' ')):
                    doPrint = True
            elif(lineA and lineB):
                doPrint = True

        if(doPrint):
            print(f"{i}\t{aName}\t{lineA}",file=l)
            print(f"{i}\t{bName}\t{lineB}",file=l)
            print("",file=l)

    a.close()
    b.close()
    l.close()
    return

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python compare.py PATH")
        sys.exit(1)

    dir = f"{sys.argv[1]}\\"
    logPath = f"{dir}sim.log"
    log = open(logPath,"w")
    log.close()

    compare(f"{dir}{PENNSIM_TRACE}",f"{dir}{VERILOG_TRACE}",logPath)
    compare(f"{dir}{PENNSIM_MEMDUMP}", f"{dir}{VERILOG_MEMDUMP}", logPath)
    

    