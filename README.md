# processing-reversiai

## Description
リバーシをAIと一緒にプレイできる  

## Requirement
* Processing ver3.5.4

## Usage

### 操作説明
基本クリックで進みます  
"p"を押すとパスできます  
"u"を押すとアンドゥできます（相手ターン時に連続一度のみ） 

### AIモード説明
ai_mode = 0 は二人プレイ用  
ai_mode = 1 はCPU1 より多く石を返せるマスを選ぶ  
ai_mode = 2 はCPU2 マスごとの重みに対して、より重いマスを選ぶ（8×8のみ）  
ai_mode = 3 はCPU3 開放度がより低い石を選ぶ  

### ゲームモード説明
game_mode = 0 は普通のオセロ  
game_mode = 1 はマスの数カ所が見えなくなる（AIには影響がありません）  

## License
MIT License  
