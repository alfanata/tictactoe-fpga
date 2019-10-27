# MIT License
# 
# Copyright (c) 2019 J. Tetteroo
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#!/usr/bin/python

from PyQt5.QtWidgets import QApplication, QWidget, QPushButton, QVBoxLayout, QHBoxLayout

# 0 = empty
# 1 = X
# 2 = O

board = [0,0,0,0,0,0,0,0,0]

app = QApplication([])
window = QWidget()

layout1 = QHBoxLayout()
layout2 = QHBoxLayout()
layout3 = QHBoxLayout()

layoutMain = QVBoxLayout()

buttons = [QPushButton(' '), QPushButton(' '), QPushButton(' '), QPushButton(' '), QPushButton(' '), QPushButton(' '),QPushButton(' '), QPushButton(' '), QPushButton(' ')]

layout1.addWidget(buttons[0])
layout1.addWidget(buttons[1])
layout1.addWidget(buttons[2])

layout2.addWidget(buttons[3])
layout2.addWidget(buttons[4])
layout2.addWidget(buttons[5])

layout3.addWidget(buttons[6])
layout3.addWidget(buttons[7])
layout3.addWidget(buttons[8])

layoutMain.addLayout(layout1)
layoutMain.addLayout(layout2)
layoutMain.addLayout(layout3)

window.setLayout(layoutMain)

bestMoveCache = {}

# Event handlers
def button0_click():
  global board
  makeMove(0, board)
  
def button1_click():
  global board
  makeMove(1, board)
  
def button2_click():
  global board
  makeMove(2, board)
  
def button3_click():
  global board
  makeMove(3, board)
  
def button4_click():
  global board
  makeMove(4, board)
  
def button5_click():
  global board
  makeMove(5, board)
  
def button6_click():
  global board
  makeMove(6, board)
  
def button7_click():
  global board
  makeMove(7, board)
  
def button8_click():
  global board
  makeMove(8, board)
  
# Main algorithm
def minimax(p, b, depth=0):
  # check if terminal state
  # player 2 = AI = maximizing player

  #print(depth,b)
  check1 = boardWin(b, 1)
  check2 = boardWin(b, 2)
  
  if check1 == True:
    return (-10, -1, depth)
  elif check2 == True:
    return (10, -1, depth)
  elif 0 not in b:
    return (0, -1, depth)
  
  # find empty spots
  spots = []
  for i in range(len(b)):
    if b[i] == 0:
      spots.append(i)
  
  bestmove = -1
  bestscore = 0
  bestdepth = 0
  
  # init scores
  if (p == 2):
    bestscore = -10000
  else:
    bestscore = 10000
    
  # for each spot get score
  for i in spots:
    board = b
    board[i] = p
    if (p == 2):  # maximize
      score, move, d = minimax(1, board, depth+1)
      if score > bestscore:
        bestscore = score
        bestmove = i
        
    else: # minimize
      score, move, d = minimax(2, board, depth+1)
      if score < bestscore:
        bestscore = score
        bestmove = i

    board[i] = 0

  return (bestscore, bestmove, bestdepth)
  
# Check if player p has a winning condition
def boardWin(b, p):
  if b[0] == p and b[1] == p and b[2] == p:
    return True
  if b[3] == p and b[4] == p and b[5] == p:
    return True
  if b[6] == p and b[7] == p and b[8] == p:
    return True
  if b[0] == p and b[3] == p and b[6] == p:
    return True
  if b[1] == p and b[4] == p and b[7] == p:
    return True
  if b[2] == p and b[5] == p and b[8] == p:
    return True
  if b[0] == p and b[4] == p and b[8] == p:
    return True
  if b[6] == p and b[4] == p and b[2] == p:
    return True
  return False
  
# Check if the board is in a valid state
def boardValid(b):
  global bestMoveCache
  countX = 0
  countO = 0

  for i in b:
    if i == 1:
      countX += 1
    elif i == 2:
      countO += 1
  
  if (countX != countO) and (countX != countO + 1):
    return False
    
  if boardWin(b, 2):
    if boardWin(b,1):
      return False
    return countX == countO # for O win, counts need to be equal
    
  if boardWin(b, 1):
    if countX != countO + 1:  # for X win, counts need to be unequal
      return False
  
  # no winner, but valid board
  print(b)
  
  if boardWin(b, 1) or boardWin(b, 2):
    return False
    
  if 0 not in b:
    # board is not counted because we cannot make more moves
    return False
  
  # Calculate best moves
  if countX == countO + 1:
    bestmove = minimax(2, b)
    print("2:", tuple(b), bestmove[1])
    bestMoveCache[tuple(b)] = bestmove[1]
  else:
    bestmove = minimax(1,b)
    print("2:", tuple(b), bestmove[1])
    bestMoveCache[tuple(b)] = bestmove[1]
  return True
  
# Generate all valid possible game states
def generateValidMoves(size):
  validboards = 0
  for i in range(3**size):
    # convert to base 3
    b = []
    cur = i
    for j in range(size):
      b.insert(0, cur % 3)
      cur = cur // 3
    if boardValid(b):
      validboards += 1
  print(str(validboards) + " valid boards!")
  
  
# Make a move on the board, first human then AI
def makeMove(pos, board):
  #global bestMoveCache
  if boardWin(board,1) or boardWin(board,2) or (0 not in board):
    return

  if board[pos] != 0:
    return
  else:
    # play human move
    board[pos] = 1
    buttons[pos].setText("X")
    res = boardWin(board,1)
    
    if res == True:
      print("Player 1 wins!")
      return
    elif (0 not in board):
      print("Tie!")
      return
      
    print(board)
    
    # play AI move

    #print(tuple(board))
    #print(bestMoveCache)
    
    if tuple(board) not in bestMoveCache:
      print("AI FAIL")
      return
    else:
      aipos = bestMoveCache[tuple(board)]
    #aiscore, aipos, aidepth = minimax(2, board)
    print("AI move " + str(aipos))
    board[aipos] = 2
    buttons[aipos].setText("O")
    res = boardWin(board,2)
    
    if res == True:
      print("Player 2 wins!")
      return
    elif (0 not in board):
      print("Tie!")
      return
      

    print(board)




buttons[0].clicked.connect(button0_click)
buttons[1].clicked.connect(button1_click)
buttons[2].clicked.connect(button2_click)
buttons[3].clicked.connect(button3_click)
buttons[4].clicked.connect(button4_click)
buttons[5].clicked.connect(button5_click)
buttons[6].clicked.connect(button6_click)
buttons[7].clicked.connect(button7_click)
buttons[8].clicked.connect(button8_click)

print("Go!")

generateValidMoves(9)
print(minimax(2, [1, 2, 1, 2, 2, 1, 0, 0, 0]))


window.show()
app.exec_()

buffer = ""

counter = 0
for i in bestMoveCache:
  x = list(i)
  p1_bin = []
  p2_bin = []
  #for j in range(9):
  #  if x[j] == 1:
  #    p1_bin.insert(0,1)
  #    p2_bin.insert(0,0)
  #  elif x[j] == 2:
  #    p1_bin.insert(0,0)
  #    p2_bin.insert(0,1)
  #  else:
  #    p1_bin.insert(0,0)
  #    p2_bin.insert(0,0)
  for j in range(9):
    if x[j] == 1:
      p1_bin.append(1)
      p2_bin.append(0)
    elif x[j] == 2:
      p1_bin.append(0)
      p2_bin.append(1)
    else:
      p1_bin.append(0)
      p2_bin.append(0)
  #print("record",str(i),"board1",''.join(str(e) for e in p1_bin),"board2",''.join(str(e) for e in p2_bin),"best move",bestMoveCache[i])
  print("sync_reset;\ncheck_mem("+str(counter)+",\""+''.join(str(e) for e in p1_bin)+"\",\""+''.join(str(e) for e in p2_bin)+"\","+str(bestMoveCache[i])+",\'1\'); -- " + str(i))
  y = "00" + ''.join(str(e) for e in p1_bin) + ''.join(str(e) for e in p2_bin) + '{0:04b}'.format(bestMoveCache[i])
  #print(y, '{0:08x}'.format(int(y, 2)))
  buffer = y + buffer
  counter += 1

offset = len(buffer)
f = open("tictactoe.txt", "w")

done = False
for i in range(32):
  f.write("ram512x8_inst_" + str(i) + " : SB_RAM512X8\n")
  f.write("generic map (\n")
  if done:
    break
  for j in range(16):
    if offset <= 0:
      done = True
      break
    cur = ""

    subtract = min(offset, 256)
    
    offset -= subtract

    cur += '{0:064X}'.format(int(buffer[offset:offset+subtract], 2))
    print(cur)
    f.write("INIT_" + '{0:01X}'.format(j) + " => X\"" + cur + "\"")
    if j == 15:
      f.write("\n")
    else:
      f.write(",\n")
  f.write(")\n")
  f.write("port map (\nRDATA => RDATA_a("+str(i)+"),\nRADDR => RADDR_c,\nRCLK => RCLK_c,\nRCLKE => RCLKE_c("+str(i)+"),\nRE => RE_c("+str(i)+"),\nWADDR => (others => \'0\'),\nWCLK=> \'0\',\nWCLKE => \'0\',\nWDATA => (others => \'0\'),\nWE => \'0\'\n);\n")
  
f.close()
   
