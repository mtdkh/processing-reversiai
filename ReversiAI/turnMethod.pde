//ここにはプレイヤー・コンピュータAIの処理メソッドがあります

//プレイヤー処理
void playerTurn() {
  int x = mouseX/MASS_SIZE;
  int y = mouseY/MASS_SIZE;

  //一時的に保存しておく
  int[][] temp_mass_state = new int[MASS_NUMBER][MASS_NUMBER];
  for (int i=0; i<MASS_NUMBER; i++) {
    for (int j=0; j<MASS_NUMBER; j++) {
      temp_mass_state[i][j] = now_mass_state[i][j];
    }
  }

  //範囲外のクリックは受け付けない
  if (mouseX>MASS_SIZE*MASS_NUMBER) {
    return;
  }
  //石が置かれていなかったら
  if (now_mass_state[x][y]==NONE) {
    int total_turn_number = 0;
    //周囲８マスをチェック
    for (int i=-1; i<2; i++) {
      for (int j=-1; j<2; j++) {
        if (i==0 && j==0) {
          continue;
        }
        if (canTurn(x, y, i, j, 0)>0) {
          total_turn_number += canTurn(x, y, i, j, 0);
          //ひっくり返す処理
          int temp = canTurn(x, y, i, j, 0);
          for (int k=0; k<=temp; k++) {
            if (black_turn) {
              now_mass_state[x+k*i][y+k*j]=BLACK;
            } else {
              now_mass_state[x+k*i][y+k*j]=WHITE;
            }
          }
        }
      }
    }
    //一つ以上返せていたら交代
    if (total_turn_number>0) {
      println("put("+x+","+y+")");
      println("Turn number="+total_turn_number);

      //ひっくり返せいるので、前情報を保存
      for (int i=0; i<MASS_NUMBER; i++) {
        for (int j=0; j<MASS_NUMBER; j++) {
          pre_mass_state[i][j] = temp_mass_state[i][j];
        }
      }

      pass_count = 0;
      number_of_times++;
      outputCSV(x, y, 0);
      black_turn = !black_turn;
    }
  }
}

//コンピュータ処理（ai_mode=1）
void com01Turn() {
  int max_x = -1;
  int max_y = -1;
  int current_max_turn = 0;
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
        //返せる最大数の場所を更新
        if (total_turn_number>current_max_turn) {
          current_max_turn = total_turn_number;
          max_x = mx;
          max_y = my;
        }
      }
    }
  }
  //一番多く返せられる場所を返す
  if (current_max_turn==0) {
    println("Pass");
    outputCSV(0, 0, 1);
    pass_count++;
    black_turn = !black_turn;
    return;
  } else {
    for (int i=-1; i<2; i++) {
      for (int j=-1; j<2; j++) {
        if (i==0 && j==0) {
          continue;
        }
        if (canTurn(max_x, max_y, i, j, 0)>0) {
          //ひっくり返す処理
          int temp = canTurn(max_x, max_y, i, j, 0);
          for (int k=0; k<=temp; k++) {
            if (your_stone_color==BLACK) {
              now_mass_state[max_x+k*i][max_y+k*j]=WHITE;
            } else {
              now_mass_state[max_x+k*i][max_y+k*j]=BLACK;
            }
          }
        }
      }
    }
    println("put("+max_x+","+max_y+")");
    println("Turn number="+current_max_turn);
    pass_count = 0;
    number_of_times++;
    outputCSV(max_x, max_y, 0);
    black_turn = !black_turn;
  }
}

//コンピュータ処理（ai_mode=2）
void com02Turn() {
  //マスごとの重み
  int mass_val[][] = {
    {
      120, -20, 20, 5, 5, 20, -20, 120
    }
    , 
    {
      -20, -40, -5, -5, -5, -5, -40, -20
    }
    , 
    {
      20, -5, 15, 3, 3, 15, -5, 20
    }
    , 
    {
      5, -5, 3, 3, 3, 3, -5, 5
    }
    , 
    {
      5, -5, 3, 3, 3, 3, -5, 5
    }
    , 
    {
      20, -5, 15, 3, 3, 15, -5, 20
    }
    , 
    {
      -20, -40, -5, -5, -5, -5, -40, -20
    }
    , 
    {
      120, -20, 20, 5, 5, 20, -20, 120
    }
  };
  int max_x = -1;
  int max_y = -1;
  int current_max_turn = 0;
  int current_max_val = -100;
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
          if (mass_val[mx][my]>current_max_val) {
            current_max_turn = total_turn_number;
            current_max_val = mass_val[mx][my];
            max_x = mx;
            max_y = my;
          }
        }
      }
    }
  }
  //一番マスの重みが大きい方を返す
  if (current_max_val==-100) {
    println("Pass");
    outputCSV(0, 0, 1);
    pass_count++;
    black_turn = !black_turn;
    return;
  } else {
    for (int i=-1; i<2; i++) {
      for (int j=-1; j<2; j++) {
        if (i==0 && j==0) {
          continue;
        }
        if (canTurn(max_x, max_y, i, j, 0)>0) {
          //ひっくり返す処理
          int temp = canTurn(max_x, max_y, i, j, 0);
          for (int k=0; k<=temp; k++) {
            if (your_stone_color==BLACK) {
              now_mass_state[max_x+k*i][max_y+k*j]=WHITE;
            } else {
              now_mass_state[max_x+k*i][max_y+k*j]=BLACK;
            }
          }
        }
      }
    }
    println("put("+max_x+","+max_y+")");
    println("Turn number="+current_max_turn);
    pass_count = 0;
    number_of_times++;
    outputCSV(max_x, max_y, 0);
    black_turn = !black_turn;
  }
}

//コンピュータ処理（ai_mode=3）
void com03Turn() {
  int[][] check_open_state = new int[MASS_NUMBER][MASS_NUMBER];
  int max_x = -1;
  int max_y = -1;
  int current_min_open = 100;

  for (int mx=0; mx<MASS_NUMBER; mx++) {
    for (int my=0; my<MASS_NUMBER; my++) {
      //石が置かれていなかったら
      if (now_mass_state[mx][my]==NONE) {
        int total_open_number = 0;
        for (int i=0; i<MASS_NUMBER; i++) {
          for (int j=0; j<MASS_NUMBER; j++) {
            check_open_state[i][j] = 0;
          }
        }
        //周囲８マスをチェック
        for (int i=-1; i<2; i++) {
          for (int j=-1; j<2; j++) {
            if (i==0 && j==0) {
              continue;
            }
            //開放度チェック
            if (canTurn(mx, my, i, j, 0)>0) {
              int temp = canTurn(mx, my, i, j, 0);
              //返せる石の周りそれぞれの周囲８マスをチェック
              for (int k=1; k<=temp; k++) {
                for (int m=-1; m<2; m++) {
                  for (int n=-1; n<2; n++) {
                    if (m==0 && n==0) {
                      continue;
                    }
                    if (mx+k*i+m<0 ||mx+k*i+m>=MASS_NUMBER ||my+k*j+n<0 ||my+k*j+n>=MASS_NUMBER) {
                      continue;
                    } else {
                      if (now_mass_state[mx+(k*i)+m][my+(k*j)+n]==0) {
                        check_open_state[mx+(k*i)+m][my+(k*j)+n]=1;
                      }
                    }
                  }
                }
              }
            }
          }
        }
        for (int i=0; i<MASS_NUMBER; i++) {
          for (int j=0; j<MASS_NUMBER; j++) {
            if (check_open_state[i][j]==1) {
              total_open_number++;
            }
          }
        }
        if (total_open_number!=0 && total_open_number<current_min_open) {
          current_min_open = total_open_number;
          max_x = mx;
          max_y = my;
        }
      }
    }
  }
  if (current_min_open==100) {
    println("Pass");
    outputCSV(0, 0, 1);
    pass_count++;
    black_turn = !black_turn;
    return;
  } else {
    for (int i=-1; i<2; i++) {
      for (int j=-1; j<2; j++) {
        if (i==0 && j==0) {
          continue;
        }
        //ひっくり返す処理
        int temp = canTurn(max_x, max_y, i, j, 0);
        for (int k=0; k<=temp; k++) {
          if (your_stone_color==BLACK) {
            now_mass_state[max_x+k*i][max_y+k*j]=WHITE;
          } else {
            now_mass_state[max_x+k*i][max_y+k*j]=BLACK;
          }
        }
      }
    }
  }
  println("put("+max_x+","+max_y+")");
  pass_count = 0;
  number_of_times++;
  outputCSV(max_x, max_y, 0);
  black_turn = !black_turn;
}

