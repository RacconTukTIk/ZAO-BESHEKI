# nba_players_metrics

Гем для анализа эффективности спортсменов/команд на основе статистических данных.

## Команда
- Василец Игорь Игоревич
- Галдин Иван Денисович
- Латышев Владислав Никитич
- Синельников Даниил Георгиевич

## Описание проекта
Гем предоставляет инструменты для:
- Загрузки спортивной статистики из датасетов/API
- Расчёта продвинутых метрик эффективности
- Визуализации результатов анализа

## Как пользователь будет взаимодействовать с гемом
```ruby
# Считывание логов бросков игроков
nba_data = read_file_nba('example.csv')

# Определение количества бросков у игрока
player = nba_data.find_player('Rush, Brandon')
shots_count = player.count_shots()

# Определение количества попаданий у игрока
player = nba_data.find_player('Robinson, Nate')
good_shots_count = player.count_success_shots()

# Определение вероятности попадания игрока из заданной позиции с известным защитником
player = nba_data.find_player('Anderson, Alan')
chance = player.scoring_chance(position: 'A', defender: 'Young, James')

# Определение количества раз, когда защитник был ближайшим к месту, откуда в кольцо был брошен мяч
player = nba_data.find_player('Bogdanovic, Bojan')
defends = player.count_all_defences()

# Определение количества отбитых защитником мячей
player = nba_data.find_player('Lin, Jeremy')
success_defends = player.count_success_defences()

# Определение эффективности защитника под кольцом / на расстоянии от кольца
player = nba_data.find_player('Williams, Deron')
efficiency = player.defender_efficiency(distance_from_basket: 5.0, atacker: 'Plumlee, Mason')
```

## Выбранный датасет
NBA shot logs

Пример данных:
```csv
GAME_ID,MATCHUP,LOCATION,W,FINAL_MARGIN,SHOT_NUMBER,PERIOD,GAME_CLOCK,SHOT_CLOCK,DRIBBLES,TOUCH_TIME,SHOT_DIST,PTS_TYPE,SHOT_RESULT,CLOSEST_DEFENDER,CLOSEST_DEFENDER_PLAYER_ID,CLOSE_DEF_DIST,FGM,PTS,player_name,player_id
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,1,1,1:09,10.8,2,1.9,7.7,2,made,"Anderson, Alan",101187,1.3,1,2,brian roberts,203148
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,2,1,0:14,3.4,0,0.8,28.2,3,missed,"Bogdanovic, Bojan",202711,6.1,0,0,brian roberts,203148
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,3,1,0:00,,3,2.7,10.1,2,missed,"Bogdanovic, Bojan",202711,0.9,0,0,brian roberts,203148
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,4,2,11:47,10.3,2,1.9,17.2,2,missed,"Brown, Markel",203900,3.4,0,0,brian roberts,203148
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,5,2,10:34,10.9,2,2.7,3.7,2,missed,"Young, Thaddeus",201152,1.1,0,0,brian roberts,203148
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,6,2,8:15,9.1,2,4.4,18.4,2,missed,"Williams, Deron",101114,2.6,0,0,brian roberts,203148
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,7,4,10:15,14.5,11,9.0,20.7,2,missed,"Jack, Jarrett",101127,6.1,0,0,brian roberts,203148
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,8,4,8:00,3.4,3,2.5,3.5,2,made,"Plumlee, Mason",203486,2.1,1,2,brian roberts,203148
21400899,"MAR 04, 2015 - CHA @ BKN",A,W,24,9,4,5:14,12.4,0,0.8,24.6,3,missed,"Morris, Darius",202721,7.3,0,0,brian roberts,203148
21400890,"MAR 03, 2015 - CHA vs. LAL",H,W,1,1,2,11:32,17.4,0,1.1,22.4,3,missed,"Ellington, Wayne",201961,19.8,0,0,brian roberts,203148
21400890,"MAR 03, 2015 - CHA vs. LAL",H,W,1,2,2,6:30,16.0,8,7.5,24.5,3,missed,"Lin, Jeremy",202391,4.7,0,0,brian roberts,203148
21400890,"MAR 03, 2015 - CHA vs. LAL",H,W,1,3,4,11:32,12.1,14,11.9,14.6,2,made,"Lin, Jeremy",202391,1.8,1,2,brian roberts,203148
21400890,"MAR 03, 2015 - CHA vs. LAL",H,W,1,4,4,8:55,4.3,2,2.9,5.9,2,made,"Hill, Jordan",201941,5.4,1,2,brian roberts,203148
21400882,"MAR 01, 2015 - CHA @ ORL",A,W,15,1,4,9:10,4.4,0,0.8,26.4,3,missed,"Green, Willie",2584,4.4,0,0,brian roberts,203148
21400859,"FEB 27, 2015 - CHA @ BOS",A,L,-8,1,1,0:48,6.8,0,0.5,22.8,3,missed,"Smart, Marcus",203935,5.3,0,0,brian roberts,203148
```
