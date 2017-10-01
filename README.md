# ReversiAI
You can play reversi with AI


## Programming language 
Processing 2.2.1


## 操作説明
基本クリックで進みます
"p"を押すとパスできます
"u"を押すとアンドゥできます（相手ターン時に連続一度のみ）


## AIモード説明
ai_mode = 0は二人プレイ用
ai_mode = 1はCPU1 より多く石を返せるマスを選ぶ
ai_mode = 2はCPU2 マスごとの重みに対して、より重いマスを選ぶ（8×8のみ）
ai_mode = 3はCPU3 開放度がより低い石を選ぶ


## ゲームモード説明
game_mode = 0は普通のオセロ
game_mode = 1はマスの数カ所が見えなくなる（AIには影響がありません）