#!/usr/bin/python3#!/usr/bin/python3
import sys, time, re, curses, pygame
from random import randint

scancodes_lc = [0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0B,0x60,0x0,
        0x0,0x0,0x0,0x0,0x0,0x71,0x31,0x0,0x0,0x0,0x7A,0x73,0x61,0x77,0x32,0x0,
        0x0,0x63,0x78,0x64,0x65,0x34,0x33,0x0,0x0,0x20,0x76,0x66,0x74,0x72,0x35,0x0,
        0x0,0x6E,0x62,0x68,0x67,0x79,0x36,0x0,0x0,0x0,0x6D,0x6A,0x75,0x37,0x38,0x0,
        0x0,0x2C,0x6B,0x69,0x6F,0x30,0x39,0x0,0x0,0x2E,0x2F,0x6C,0x3B,0x70,0x2D,0x0,
        0x0,0x0,0x27,0x0,0x5B,0x3D,0x0,0x0,0x0,0x0,0x0A,0x5D,0x0,0x5C,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0,0x8,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,
        0x0,0x0,0x0,0x0,0x0,0x0,0x1B,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0]

screen = pygame.display.set_mode((100, 100))

def initval(bits):
    return randint(0, 2 ** bits)

ram = []

if len(sys.argv) > 1:
    raw = ""
    with open(sys.argv[1], "r") as f:
        raw = f.read()
    lines = raw.split("\n")
    for line in lines:
        if re.match("^  \d+,$", line):
            ram.append(int(line[2:-1]))
        elif re.match("^  \d+$", line):
            ram.append(int(line[2:]))

debugLN = []
with open("__DEBUG__.txt", "r") as f:
    debugLN = f.read().split("\n")

breakpoints = []

for i in range((2 ** 16) - len(ram)):
    ram.append(initval(16))

#---BEGIN---
fe = 0

pch = 0
pcl = 0
iph = initval(8)
ipl = initval(8)

rh = initval(8)
rl = initval(8)

flags = 0

def ramAddr():
    if fe == 0:
        return (pch << 8) | pcl
    elif fe == 1:
        if ih() == 3 or ih() == 4 or il() == 3 or il() == 4:
            if ih() == 4 or il() == 4:
                return (rh << 8) | d
            else:
                return (rh << 8) | rl
        else:   return 0 #FIXME
def ramData():
    return ram[ramAddr() % (2 ** 16)] & 65535
def ramWE():
    if il() == 3 or il() == 4:
        return True
    return False

i = initval(8)
def ih():
    return (i >> 4) & 15
def il():
    return i & 15
d = initval(8)

a = initval(8)
b = initval(8)

has_scancode = False
scancode_1 = 0
scancode_2 = 0

def send_scancode(data):
    global has_scancode
    global scancode_1
    global scancode_2
    scancode_2 = scancode_1
    scancode_1 = data
    has_scancode = True

def in_IO():
    return int(has_scancode) << 7
def in_IO2():
    global has_scancode
    has_scancode = 0
    return scancode_1
def in_IO3():
    return scancode_2

out_IO = initval(8)
out_IO2 = initval(8)
out_IO3 = initval(8)
out_IO4 = initval(8)
out_IO5 = initval(8)

def bus():
    global flags
    if ih() == 0:
        return d
    elif ih() == 1:
        return a
    elif ih() == 2:
        return b
    elif ih() == 3:
        return ramData() & 255
    elif ih() == 4:
        return ramData() & 255
    elif ih() == 5:
        if d & 1 == 1:
            return in_IO()
        else:
            if d & 2 == 2:
                return in_IO2()
            else:
                return in_IO3()
    elif ih() == 6:
        pass
    elif ih() == 7:
        return flags
    elif ih() == 8:
        return a & b
    elif ih() == 9:
        return a | b
    elif ih() == 10:
        return a ^ b
    elif ih() == 11:
        res = (a + b + flags)
        flags = res > 255
        return res & 255
    elif ih() == 12:
        return b >> 1
    elif ih() == 13:
        return int(a < b)
    elif ih() == 14:
        return int(a == b)
    elif ih() == 15:
        return int(a > b)
    return 0

def main(stdscr):
    global fe
    global pch
    global pcl
    global iph
    global ipl
    global rh
    global rl
    global flags
    global i
    global d
    global a
    global b
    global out_IO
    global out_IO2
    global out_IO3
    global out_IO4
    global out_IO5
    
    curses.cbreak()
    #stdscr.keypad(True)
    stdscr.nodelay(True)
    #curses.noecho()
    
    lcdMem = []
    for n in range(0x80):
        lcdMem.append('\0')    
    lcdData = 0
    lcdCycle = 1
    lcdCurs = 0
    lastLCDE = 0
    
    lastKey = -1
    
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                sys.exit()
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LSHIFT:
                    send_scancode(0x12)
                else:
                    letter = pygame.key.name(event.key)
                    if event.key == pygame.K_RETURN:
                        letter = '\n'
                    if event.key == pygame.K_SPACE:
                        letter = ' '
                    if len(letter) == 1:
                        letter = ord(letter)
                        scancode = 0
                        for i in range(len(scancodes_lc)):
                            if scancodes_lc[i] == letter:
                                send_scancode(i)
                                break
            elif event.type == pygame.KEYUP:
                if event.key == pygame.K_LSHIFT:
                    send_scancode(0xF0)
                    send_scancode(0x12)
                else:
                    letter = pygame.key.name(event.key)
                    if event.key == pygame.K_RETURN:
                        letter = '\n'
                    if event.key == pygame.K_SPACE:
                        letter = ' '
                    if len(letter) == 1:
                        letter = ord(letter)
                        scancode = 0
                        for i in range(len(scancodes_lc)):
                            if scancodes_lc[i] == letter:
                                send_scancode(0xF0)
                                send_scancode(i)
                                break
        #---MAIN SIM---
        
        #fetch setup
        fe = 0
        #fetch latch
        i = (ramData() >> 8) & 255
        d = ramData() & 255
        
        pcl += 1
        if pcl >= 256:
            pch += 1
            pcl = 0
            if pch >= 256:
                pch = 0
        
        #execute setup
        fe = 1
        #execute latch
        if il() == 0:
            a = bus()
        elif il() == 1:
            b = bus()
        elif il() == 2:
            rh = bus()
        elif il() == 3:
            if ramWE():
                ram[ramAddr() % (2 ** 16)] = (ramData() & 0xFF00) | (bus() & 255)
        elif il() == 4:
            if ramWE():
                ram[ramAddr() % (2 ** 16)] = (ramData() & 0xFF00) | (bus() & 255)
        elif il() == 5:
            rl = bus()
        elif il() == 6:
            out_IO = bus()
        elif il() == 7:
            flags = bus()
        elif il() == 8:
            if bus() & 1:
                pch = iph
                pcl = ipl
        elif il() == 9:
            ipl = bus()
        elif il() == 10:
            iph = bus()
        elif il() == 11:
            pass
        elif il() == 12:
            out_IO2 = bus()
        elif il() == 13:
            out_IO3 = bus()
        elif il() == 14:
            out_IO4 = bus()
        elif il() == 15:
            out_IO5 = bus()
        
        #lcd
        data = out_IO
        lcdE = (data >> 1) & 1
        lcdRS = data & 1
        if not lastLCDE and lcdE:
            if lcdCycle == 0:
                lcdData = data & 0xF0
                lcdCycle = 1
            elif lcdCycle == 1:
                lcdData |= (data >> 4) & 0x0F
                
                if lcdRS:
                    lcdMem[lcdCurs] = chr(lcdData)
                    lcdCurs += 1
                    #FIXME
                    if lcdCurs == 28:
                        lcdCurs = 40
                    elif lcdCurs == 68:
                        lcdCurs = 0
                    elif lcdCurs == 0x80:
                        lcdCurs = 0
                else:
                    if lcdData & 0x80 == 0x80:
                        lcdCurs = lcdData & 0x7F
                    elif lcdData == 0x01:
                        for n in range(len(lcdMem)):
                            lcdMem[n] = '\0'
                        lcdCurs = 0
                    elif lcdData == 0x02 or lcdData == 0x03:
                        lcdCurs = 0
                    #TODO: other commands
                
                lcdCycle = 0
        lastLCDE = lcdE
        #---RENDER---
        stdscr.clear()
        
        #---KEYBOARD---
        #key = stdscr.getch()
        #if key != -1:
        #    lastKey = key
        stdscr.addstr(0, 0, str(lastKey))
        
        #---LCD---
        lcdX = 40
        lcdY = 1
        
        lcdW = 20
        lcdH = 4
        
        stdscr.addstr(lcdY, lcdX, "-" * (lcdW + 2))
        for n in range(lcdH):
            stdscr.addstr(lcdY + 1 + n, lcdX, "|" + " " * lcdW + "|")
        stdscr.addstr(lcdY + 1 + lcdH, lcdX, "-" * (lcdW + 2))
        
        lcdMemAddr = [0x00, 0x40, 0x14, 0x54]
        for y in range(lcdH):
            for x in range(lcdW):
                val = lcdMem[lcdMemAddr[y] + x]
                if val == 0:
                    val = ' '
                stdscr.addstr(lcdY + 1 + y, lcdX + 1 + x, val)
        
        #---DEBUG---
        debugX = 1
        debugY = 1
        debugN = -1
        if ((pch << 8) | pcl) < len(debugLN):
            debugN = int(debugLN[((pch << 8) | pcl)])
        if debugN in breakpoints:
            time.sleep(1)
        stdscr.addstr(debugY, debugX, "pch: %3d  pcl: %3d  line: %5d" % (pch, pcl, debugN))
        stdscr.addstr(debugY + 1, debugX, "iph: %3d  ipl: %3d" % (iph, ipl))
        stdscr.addstr(debugY + 3, debugX, "rh: %3d   rl: %3d" % (rh, rl))
        stdscr.addstr(debugY + 5, debugX, "addr: %3d %3d" % ((ramAddr() >> 8) & 255, ramAddr() & 255))
        stdscr.addstr(debugY + 6, debugX, "data: %3d %3d" % ((ramData() >> 8) & 255, ramData() & 255))
        
        stdscr.addstr(debugY + 8, debugX, "i: %3d    d: %3d" % (i, d))
        
        stdscr.addstr(debugY + 10, debugX, "a: %3d    b: %3d flags: %3d" % (a, b, flags))

        stdscr.refresh()
        time.sleep(0.0001)

curses.wrapper(main)
