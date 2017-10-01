//----------各種設定はここからお願いします----------//
int ai_mode = 2;  //ここでAIモードを選んでください
int game_mode = 0;  //ここでゲームモードを選んでください

//CSV用
Table table;

int MASS_SIZE = 50;
int MASS_NUMBER = 8;
int STONE_SIZE = int(MASS_SIZE*0.8);
int WHITE = 1;
int BLACK = -1;
int NONE = 0;
int[][] now_mass_state;
int[][] pre_mass_state;
int[][] hide_mass_state;
int total_white_number;
int total_black_number;
int pass_count = 0;
int your_stone_color;
int number_of_times = 0;
boolean black_turn = true;
boolean game_setting = true;

void setup() {
  size(MASS_SIZE*MASS_NUMBER+150, MASS_SIZE*MASS_NUMBER);
  textAlign(CENTER);

  table = new Table();
  table.addColumn("Number");
  table.addColumn("turn");
  table.addColumn("pos_x");
  table.addColumn("pos_y");
  table.addColumn("the_number_of_BLACK");
  table.addColumn("the_number_of_WHITE");
  
  //ゲームモード１の初期設定
  if (game_mode==1) {
    hide_mass_state = new int[MASS_NUMBER][MASS_NUMBER];
    for (int i=0; i<20; i++) {
      int temp_x = (int)random(0, MASS_NUMBER);
      int temp_y = (int)random(0, MASS_NUMBER);
      hide_mass_state[temp_x][temp_y] = 1;
    }
  }

  initStones();
}

void draw() {
  background(50, 100, 50);

  if (game_setting) {
    setting();
  } else {
    drawLines();
    drawStones();
    drawCanPut();
    countStones();
    drawInfo();
    checkEnd();
    
    //ゲームモード１の処理
    if (game_mode==1) {
      for (int i=0; i<MASS_NUMBER; i++) {
        for (int j=0; j<MASS_NUMBER; j++) {
          if(hide_mass_state[i][j]==1){
            fill(0);
            rect(i*MASS_SIZE,j*MASS_SIZE,MASS_SIZE,MASS_SIZE);
          }
        }
      }
    }
  }
}

void mousePressed() {
  //ゲーム設定の選択
  if (game_setting) {
    if (dist(mouseX, mouseY, width/4, height/2)<50) {
      println("select BLACK");
      println("--------------------");
      println("BLACK TURN");
      your_stone_color = BLACK;
      game_setting = false;
      return;
    } else if (dist(mouseX, mouseY, width*3/4, height/2)<50) {
      println("select WHITE");
      println("--------------------");
      println("BLACK TURN");
      your_stone_color = WHITE;
      game_setting = false;
      return;
    } else {
      return;
    }
  }
  //ターンの処理
  if (black_turn) {
    if (your_stone_color==BLACK) {
      playerTurn();
    } else {
      if (ai_mode==0) {
        playerTurn();
      } else if (ai_mode==1) {
        com01Turn();
      } else if (ai_mode==2) {
        com02Turn();
      } else if (ai_mode==3) {
        com03Turn();
      }
    }
  } else {
    if (your_stone_color==WHITE) {
      playerTurn();
    } else {
      if (ai_mode==0) {
        playerTurn();
      } else if (ai_mode==1) {
        com01Turn();
      } else if (ai_mode==2) {
        com02Turn();
      } else if (ai_mode==3) {
        com03Turn();
      }
    }
  }

  //コンソールにターン表示
  if (black_turn) {
    println("--------------------");
    println("BLACK TURN");
  } else {
    println("--------------------");
    println("WHITE TURN");
  }
}

void keyPressed() {
  if (game_setting) {
    return;
  }
  //パスの処理
  if (key=='p') {
    println("Pass");
    pass_count++;
    outputCSV(0, 0, 1);
    black_turn = !black_turn;

    //コンソールにターン表示
    if (black_turn) {
      println("--------------------");
      println("BLACK TURN");
    } else {
      println("--------------------");
      println("WHITE TURN");
    }
  }
  //アンドゥ処理
  if (key=='u') {
    //初手でアンドゥはしない
    if (number_of_times<1) {
      return;
    }
    //相手のターンで処理
    if (your_stone_color==BLACK && black_turn==false) {
      undoStones();
    } else if (your_stone_color==WHITE && black_turn==true) {
      undoStones();
    }
  }
}

//セッティング
void setting() {
  //drawButton
  fill(0);
  ellipse(width/4, height/2, 100, 100);
  fill(255);
  ellipse(width*3/4, height/2, 100, 100);
  //drawText
  textSize(20);
  fill(255);
  text("Select your turn", width/2, 100);
  fill(255);
  text("push", width/4, height/2);
  fill(0);
  text("push", width*3/4, height/2);
}

//石の初期化と初期配置
void initStones() {
  //全てのマスを初期状態に
  now_mass_state = new int[MASS_NUMBER][MASS_NUMBER];
  pre_mass_state = new int[MASS_NUMBER][MASS_NUMBER];
  for (int i=0; i<MASS_NUMBER; i++) {
    for (int j=0; j<MASS_NUMBER; j++) {
      now_mass_state[i][j] = 0;
      pre_mass_state[i][j] = 0;
    }
  }
  //偶数マスの場合の初期石設置
  if (MASS_NUMBER%2==0) {
    now_mass_state[MASS_NUMBER/2-1][MASS_NUMBER/2-1] = -1;
    now_mass_state[MASS_NUMBER/2-1][MASS_NUMBER/2] = 1;
    now_mass_state[MASS_NUMBER/2][MASS_NUMBER/2-1] = 1;
    now_mass_state[MASS_NUMBER/2][MASS_NUMBER/2] = -1;
  }
}

//アンドゥ処理
void undoStones() {
  for (int i=0; i<MASS_NUMBER; i++) {
    for (int j=0; j<MASS_NUMBER; j++) {
      now_mass_state[i][j] = pre_mass_state[i][j];
    }
  }
  println("Undo");
  number_of_times--;
  outputCSV(0, 0, 2);
  black_turn = !black_turn;

  //コンソールにターン表示
  if (black_turn) {
    println("--------------------");
    println("BLACK TURN");
  } else {
    println("--------------------");
    println("WHITE TURN");
  }
}

//区切り線の描画
void drawLines() {
  for (int i=0; i<=MASS_NUMBER; i++) {
    line(i*MASS_SIZE, 0, i*MASS_SIZE, MASS_SIZE*MASS_NUMBER);
    line(0, i*MASS_SIZE, MASS_SIZE*MASS_NUMBER, i*MASS_SIZE);
  }
}

//石の描画
void drawStones() {
  for (int i=0; i<MASS_NUMBER; i++) {
    for (int j=0; j<MASS_NUMBER; j++) {
      if (now_mass_state[i][j]==WHITE) {
        fill(255);
        ellipse(i*MASS_SIZE+0.5*MASS_SIZE, j*MASS_SIZE+0.5*MASS_SIZE, STONE_SIZE, STONE_SIZE);
      } else if (now_mass_state[i][j]==BLACK) {
        fill(0);
        ellipse(i*MASS_SIZE+0.5*MASS_SIZE, j*MASS_SIZE+0.5*MASS_SIZE, STONE_SIZE, STONE_SIZE);
      }
    }
  }
}

//置ける場所を描画
void drawCanPut() {
  for (int mx=0; mx<MASS_NUMBER; mx++) {
    for (int my=0; my<MASS_NUMBER; my++) {
      if (now_mass_state[mx][my]==NONE) {
        int total_turn_number = 0;
        //周囲８マスをチェック
        for (int i=-1; i<2; i++) {
          for (int j=-1; j<2; j++) {
            if (i==0 && j==0) {
              continue;
            }
            if (canTurn(mx, my, i, j, 0)>0) {
              total_turn_number += canTurn(mx, my, i, j, 0);
            }
          }
        }
        if (total_turn_number>0) {
          fill(50, 100, 50);
          ellipse((mx+0.5)*MASS_SIZE, (my+0.5)*MASS_SIZE, STONE_SIZE*0.5, STONE_SIZE*0.5);
        }
      }
    }
  }
}

//石数カウント
void countStones() {
  total_white_number = 0;
  total_black_number = 0;
  for (int i=0; i<MASS_NUMBER; i++) {
    for (int j=0; j<MASS_NUMBER; j++) {
      if (now_mass_state[i][j]==BLACK) {
        total_black_number++;
      } else if (now_mass_state[i][j]==WHITE) { 
        total_white_number++;
      }
    }
  }
}

//ゲーム内情報を表示
void drawInfo() {
  //石数の数値描画
  textSize(20);
  fill(150, 150, 100);
  text("WHITE "+total_white_number, MASS_SIZE*MASS_NUMBER+75, 100);
  text("BLACK "+total_black_number, MASS_SIZE*MASS_NUMBER+75, 150);

  //手番描画
  textSize(20);
  if (black_turn) {
    fill(0);
    if (mouseX<MASS_SIZE*MASS_NUMBER) {
      if (your_stone_color==BLACK) {
        ellipse(mouseX, mouseY, STONE_SIZE, STONE_SIZE);
      } else {
        text("Click", mouseX, mouseY);
      }
    }
    text("BLACK TURN ", MASS_SIZE*MASS_NUMBER+75, 50);
  } else {
    fill(255);
    if (mouseX<MASS_SIZE*MASS_NUMBER) {
      if (your_stone_color==WHITE) {
        ellipse(mouseX, mouseY, STONE_SIZE, STONE_SIZE);
      } else {
        text("Click", mouseX, mouseY);
      }
    }  
    text("WHITE TURN ", MASS_SIZE*MASS_NUMBER+75, 50);
  }
}

//終了チェック
void checkEnd() {
  //片方の石がなくなった時の終了処理
  textSize(25);
  fill(150, 150, 150);
  if (total_white_number<1) {
    println("Finish!");
    text("Win BLACK", MASS_SIZE*MASS_NUMBER+75, 250);
    stop();
    return;
  } else if (total_black_number<1) {
    println("Finish!");
    text("Win WHITE", MASS_SIZE*MASS_NUMBER+75, 250);
    stop();
    return;
  }

  //パスが２回連続した場合の終了処理
  if (pass_count>=2) {
    println("Finish!");
    textSize(25);
    fill(150, 150, 150);
    if (total_black_number>total_white_number) {
      text("Win BLACK", MASS_SIZE*MASS_NUMBER+75, 250);
    } else if (total_white_number>total_black_number) {
      text("Win WHITE", MASS_SIZE*MASS_NUMBER+75, 250);
    } else {
      text("DRAW", MASS_SIZE*MASS_NUMBER+75, 250);
    }
    stop();
    return;
  }

  //全てのマスが埋まった時の終了処理
  int none_number = 0;
  for (int i=0; i<MASS_NUMBER; i++) {
    for (int j=0; j<MASS_NUMBER; j++) {
      if (now_mass_state[i][j]==NONE) {
        none_number++;
      }
    }
  }
  if (none_number==0) {
    println("Finish!");
    textSize(25);
    fill(150, 150, 150);
    if (total_black_number>total_white_number) {
      text("Win BLACK", MASS_SIZE*MASS_NUMBER+75, 250);
    } else if (total_white_number>total_black_number) {
      text("Win WHITE", MASS_SIZE*MASS_NUMBER+75, 250);
    } else {
      text("DRAW", MASS_SIZE*MASS_NUMBER+75, 250);
    }
    stop();
    return;
  }
}

//返せる石を数える（一方向のみ）
int canTurn(int ax, int ay, int ai, int aj, int cnt) {
  if (ax+ai<0 || ax+ai>=MASS_NUMBER || ay+aj<0 || ay+aj>=MASS_NUMBER) {
    return 0;
  }

  int my_color;
  if (black_turn) {
    my_color = BLACK;
  } else {
    my_color = WHITE;
  }

  if (now_mass_state[ax+ai][ay+aj]==NONE) {
    return 0;
  } else if (now_mass_state[ax+ai][ay+aj]==my_color) {
    if (cnt==0) {
      return 0;
    } else {
      return cnt;
    }
  } else {
    return canTurn(ax+ai, ay+aj, ai, aj, cnt+1);
  }
}

//csvに書き込み(at->Put=0:Pass=1:Undo=2)
void outputCSV(int ax, int ay, int at) {
  TableRow newRow = table.addRow();
  if (at==0) {
    newRow.setInt("Number", number_of_times);
    newRow.setInt("the_number_of_BLACK", total_black_number);
    newRow.setInt("the_number_of_WHITE", total_white_number);
    newRow.setInt("pos_x", ax);
    newRow.setInt("pos_y", ay);
    if (black_turn) {
      newRow.setString("turn", "BLACK");
    } else {
      newRow.setString("turn", "WHITE");
    }
  } else if (at==1) {
    newRow.setString("turn", "Pass");
  } else if (at==2) {
    newRow.setString("turn", "Undo");
  }
  saveTable(table, "data/history.csv");
}

