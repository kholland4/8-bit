#!/usr/bin/python3
import sys, re

labelRegex = "(:(:|)[a-zA-Z0-9_\-]+|(0b[0-1]+|0x[0-9A-Fa-f]+|\d+)|'.')"

ihLookup = [
  labelRegex,
  "a",
  "b",
  "rh,rl",
  "rh," + labelRegex,
  "io",
  "rh,rl(i)",
  "flags",
  
  "and",
  "or",
  "xor",
  "add",
  "bsr",
  "a<b",
  "a=b",
  "a>b"
]

ilLookup = [
  "a",
  "b",
  "rh",
  "rh,rl",
  "rh," + labelRegex,
  "rl",
  "io",
  "flags",
  
  "branch",
  "ipl",
  "iph",
  "rh,rl(i)",
  "io2",
  "io3",
  "io4",
  "io5"
]

macros = [
  {
    "pattern": "branch %s .+" % labelRegex,
    "res": lambda s: ([
      str((ref(s.split(" ")[1]) >> 8) & 255) + " iph",
      str(ref(s.split(" ")[1]) & 255) + " ipl",
      s.split(" ")[2] + " branch"
    ]),
    "len": lambda s: 3,
    "help": "branch <target> <condition>"
  },
  {
    "pattern": "dw %s" % labelRegex,
    "res": lambda s: ([
      str(ref(tokenSplit(s)[1]) & 255) + " a"
    ]),
    "len": lambda s: 1,
    "help": "dw <data byte>"
  },
  {
    "pattern": "ds \".+\"",
    "res": lambda s: ([(str(ord(char)) + " a") for char in list(s[4:-1])]),
    "len": lambda s: len(s) - 5,
    "help": "ds \"<string>\""
  },
  {
    "pattern": "lcd %s" % labelRegex,
    "res": lambda s: ([
      str((ref(tokenSplit(s)[1]) & 240) | 3) + " io",
      str((ref(tokenSplit(s)[1]) & 240) | 1) + " io",
      str(((ref(tokenSplit(s)[1]) << 4) & 240) | 3) + " io",
      str(((ref(tokenSplit(s)[1]) << 4) & 240) | 1) + " io"
    ]),
    "len": lambda s: 4,
    "help": "lcd <data byte>"
  },
  {
    "pattern": "wait %s" % labelRegex,
    "res": lambda s: ([
      "0 flags",
      "0 a",
      "1 b",
      "add a",
      str(ref(tokenSplit(s)[1])) + " b",
      "::-3 iph",
      ":-4 ipl",
      "a<b branch"
    ]),
    "len": lambda s: 8,
    "help": "wait <time>"
  },
  {
    "pattern": "call %s" % labelRegex,
    "res": lambda s: ([
      "0 flags",
      "254 rh",
      "rh,0 a",
      "2 b",
      "add rh,0",
      "add rl",
      "::7 rh,rl",
      "3 b",
      "add rl",
      ":4 rh,rl",
      
      str((ref(s.split(" ")[1]) >> 8) & 255) + " iph",
      str(ref(s.split(" ")[1]) & 255) + " ipl",
      "1 branch"
    ]),
    "len": lambda s: 13,
    "help": "call <target>"
  },
  {
    "pattern": "ret",
    "res": lambda s: ([
      "0 flags",
      "254 rh",
      "rh,0 a",
      "a rl",
      "rh,rl iph",
      "1 b",
      "add rl",
      "rh,rl ipl",
      
      "0 flags",
      "254 b",
      "add a",
      "0 rl",
      "a rh,rl",
      
      "1 branch"
    ]),
    "len": lambda s: 14,
    "help": "ret"
  }
]

labels = {}
def ref(s, line=None):
    #base 10 numbers
    try:
        d = int(s)
        return d & 255
    except ValueError:
        pass
    
    #base 2 numbers (0b)
    if s.startswith("0b"):
        try:
            d = int(s[2:], 2)
            return d & 255
        except ValueError:
            pass
    
    #base 16 numbers (0x)
    if s.startswith("0x"):
        try:
            d = int(s[2:], 16)
            return d & 255
        except ValueError:
            pass
    
    #chars
    if len(s) == 3:
        if s[0] == "'" and s[2] == "'":
            return ord(s[1])
    
    #labels
    if s.startswith(":"):
        if s.startswith("::"):
            if s[2:] in labels:
                d = labels[s[2:]]
                return d >> 8
            elif line != None:
                try:
                    o = int(s[2:])
                    return (line + o) >> 8
                except ValueError:
                    raise Exception("label \"%s\" not found" % s[2:])
            else:
                raise Exception("label \"%s\" not found" % s[2:])
        else:
            if s[1:] in labels:
                d = labels[s[1:]]
                return d
            elif line != None:
                try:
                    o = int(s[1:])
                    return (line + o)
                except ValueError:
                    raise Exception("label \"%s\" not found" % s[2:])
            else:
                raise Exception("label \"%s\" not found" % s[1:])
    
    raise Exception("invalid literal or label \"%s\"" % s)

def tokenSplit(s):
    out = []
    t = ""
    qd = 0
    qs = 0
    lastChar = ""
    for char in s:
        if char == " " and qd <= 0 and qs <= 0:
            if t != "":
                out.append(t)
                t = ""
        else:
            t += char
            if char == "'" and lastChar != "\\":
                qs = not qs
            if char == "\"" and lastChar != "\\":
                qd = not qd
        lastChar = char
    if t != "":
        out.append(t)
    
    return out

sect_bss = None

codeRaw = []
with open(sys.argv[1], "r") as f:
    codeRaw = f.read().split("\n")

#label handling
codeStage2 = []
index = 0
lineCount = 1
debugLineNumbers = []
for line in codeRaw:
    #blank lines
    if line == "":
        lineCount += 1
        continue
    
    #comments
    if line.startswith("//"):
        lineCount += 1
        continue
    
    #comments at end of line
    if line.find("//") != -1:
        line = line[0:line.find("//")]
        line = line.strip()
    
    #@section
    if line.startswith("@"):
        if line == "@section bss":
            sect_bss = index
        lineCount += 1
        continue
    
    #labels
    if line.startswith("."):
        align = False
        if line[1:].startswith("."):
            line = line[1:]
            align = True
        if not re.match("^" + labelRegex + "$", ":" + line[1:]):
            raise Exception("invalid label \"%s\" (line %d)" % (line[1:], lineCount))
        if align:
            while index & 255 != 0:
                codeStage2.append("0 a")
                debugLineNumbers.append(lineCount)
                index += 1
        labels[line[1:]] = index
        lineCount += 1
        continue
    
    #macros
    macroFound = False
    for m in macros:
        if re.match("^" + m["pattern"] + "$", line):
            macroFound = True
            codeStage2.append(line)
            index += m["len"](line)
            for i in range(m["len"](line)):
                debugLineNumbers.append(lineCount)
            break
    if macroFound:
        lineCount += 1
        continue
    
    #actual code
    c = line.split(" ")
    #if len(c) > 2:
    #    raise Exception("too many operands \"%s\" (line %d)" % (line, lineCount))
    
    ih = -1
    for i in range(len(ihLookup)):
        if re.match("^" + ihLookup[i] + "$", c[0].lower()):
            ih = i
            break
    if ih == -1:
        raise Exception("input operand \"%s\" is invalid (line %d)" % (c[0], lineCount))
    
    il = -1
    for i in range(len(ilLookup)):
        if re.match("^" + ilLookup[i] + "$", c[1].lower()):
            il = i
            break
    if il == -1:
        raise Exception("output operand \"%s\" is invalid (line %d)" % (c[1], lineCount))
    
    if (ih == 3 or ih == 4 or ih == 6) and (il == 3 or il == 4 or il == 11):
        raise Exception("cannot use memory for both input and output (line %d)" % lineCount)
    
    if (ih == 4 or ih == 0) and (il == 4):
        raise Exception("cannot use immediate value for both input and output (line %d)" % lineCount)
    
    c2 = ""
    if len(c) >= 3:
        c2 = " " + c[2]
    codeStage2.append(c[0] + " " + c[1] + c2)
    debugLineNumbers.append(lineCount)
    lineCount += 1
    index += 1

#macros
codeStage3 = []
for line in codeStage2:
    macroFound = False
    for m in macros:
        if re.match("^" + m["pattern"] + "$", line):
            macroFound = True
            codeStage3.extend(m["res"](line))
            break
    
    if not macroFound:
        codeStage3.append(line)

#resolve labels and convert to machine code
codeStage4 = []
index = 0
for line in codeStage3:
    c = line.split(" ")
    ih = -1
    for i in range(len(ihLookup)):
        if re.match("^" + ihLookup[i] + "$", c[0].lower()):
            ih = i
            break
    if ih == -1:
        raise Exception("input operand \"%s\" is invalid (internal error)" % c[0])
    
    il = -1
    for i in range(len(ilLookup)):
        if re.match("^" + ilLookup[i] + "$", c[1].lower()):
            il = i
            break
    if il == -1:
        raise Exception("output operand \"%s\" is invalid (internal error)" % c[1])
    
    d = 0
    if ih == 0:
        d = ref(c[0], index) & 255
    elif ih == 4:
        d = ref(c[0][3:], index) & 255
    elif il == 4:
        d = ref(c[1][3:], index) & 255
    elif ih == 5:
        d = 1
        if len(c) >= 3:
            d = int(c[2])
    
    if (ih == 3 or ih == 4 or ih == 6) and (il == 3 or il == 4 or il == 11):
        raise Exception("cannot use memory for both input and output (internal error)")
    
    #io multiplexing
    #if il == 5:
    #    d = 1
    
    #codeStage4.append([ih, il, d])
    codeStage4.append(str((ih << 12) | (il << 8) | (d & 255)))
    
    index += 1

if sect_bss != None:
    codeStage4 = codeStage4[:sect_bss]

print("uint16_t dataLen = %d;" % len(codeStage4))
print("uint16_t data[] = {")
print("  " + (",\n  ".join(codeStage4)))
print("};")

debugLN = "\n".join([str(x) for x in debugLineNumbers])
with open("__DEBUG__.txt", "w") as f:
    f.write(debugLN)
