import '../engine/level.dart';
import '../engine/models.dart';

const GameAction _u = GameAction.up;
const GameAction _d = GameAction.down;
const GameAction _l = GameAction.left;
const GameAction _r = GameAction.right;
const GameAction _w = GameAction.wait;

/// Seviyeler bilerek ASCII veri olarak tutulur: yeni bir seviye ~10 satir.
///
/// Her seviye kendi ornek cozumunu tasir; test/levels_test.dart bu cozumu
/// motordan gecirir, boylece cozulemez bir seviye yayinlamak imkansizdir.
final List<Level> kLevels = <Level>[
  Level.parse(
    id: 1,
    par: 0,
    titleTr: 'Uyanış',
    titleEn: 'Waking',
    hintTr: 'Çıkışa ulaş.',
    hintEn: 'Reach the exit.',
    maxTurns: 8,
    maxClones: 0,
    map: '''
#########
#.......#
#.P...E.#
#.......#
#########
''',
    solution: <List<GameAction>>[
      <GameAction>[_r, _r, _r, _r],
    ],
  ),
  Level.parse(
    id: 2,
    par: 1,
    titleTr: 'İlk Yankı',
    titleEn: 'First Echo',
    hintTr: 'Plakaya biri basmalı. Sen çekilirsen kapı kapanır — '
        'geçmişini oraya bırak.',
    hintEn: 'Someone must stand on the plate. Leave your past self there.',
    maxTurns: 7,
    maxClones: 1,
    map: '''
###########
#.1.P.#####
#.....A..E#
#.....#####
###########
''',
    solution: <List<GameAction>>[
      <GameAction>[_l, _l],
      <GameAction>[_d, _r, _r, _r, _r, _r],
    ],
  ),
  Level.parse(
    id: 3,
    par: 1,
    titleTr: 'Çifte Kapı',
    titleEn: 'Double Gate',
    hintTr: 'Tek plaka, aynı renkteki bütün kapıları açar.',
    hintEn: 'One plate opens every gate of its colour.',
    maxTurns: 8,
    maxClones: 1,
    map: '''
###########
#.1.P.....#
#####.#####
#####A#####
#####.#####
#####A#####
#####.#####
#####E#####
###########
''',
    solution: <List<GameAction>>[
      <GameAction>[_l, _l],
      <GameAction>[_r, _d, _d, _d, _d, _d, _d],
    ],
  ),
  Level.parse(
    id: 4,
    par: 2,
    titleTr: 'İkili',
    titleEn: 'The Pair',
    hintTr: 'İki plaka, iki beden ister. Sen üçüncüsüsün.',
    hintEn: 'Two plates need two bodies. You are the third.',
    maxTurns: 10,
    maxClones: 2,
    map: '''
###########
#.1.....2.#
#....P....#
#####.#####
#####A#####
#####.#####
#####B#####
#####.#####
#####E#####
###########
''',
    solution: <List<GameAction>>[
      <GameAction>[_l, _l, _l, _u],
      <GameAction>[_r, _r, _r, _u],
      <GameAction>[_d, _w, _w, _w, _d, _d, _d, _d, _d],
    ],
  ),
  Level.parse(
    id: 5,
    par: 1,
    titleTr: 'Sandık',
    titleEn: 'The Crate',
    hintTr: 'Sandık da plakaya basar — ve hiç çekilmez.',
    hintEn: 'A crate presses a plate too, and it never steps off.',
    maxTurns: 10,
    maxClones: 1,
    map: '''
#########
#.1...2.#
#.....X.#
#.....P.#
###.#####
###A#####
###.#####
###B#####
###E#####
#########
''',
    solution: <List<GameAction>>[
      <GameAction>[_u, _l, _l, _l, _l, _u],
      <GameAction>[_l, _l, _l, _d, _w, _w, _d, _d, _d, _d],
    ],
  ),
  Level.parse(
    id: 6,
    par: 2,
    titleTr: 'Son Döngü',
    titleEn: 'Last Loop',
    hintTr: 'Üç kapı, tek sandık, iki yankı. Sandığı doğru plakaya götür.',
    hintEn: 'Three gates, one crate, two echoes. Put the crate where it counts.',
    maxTurns: 14,
    maxClones: 2,
    map: '''
###########
#.1.....2.#
#....X....#
#.3.....P.#
#####.#####
#####A#####
#####B#####
#####C#####
#####E#####
###########
''',
    solution: <List<GameAction>>[
      <GameAction>[_u, _l, _l, _l, _l, _l, _d, _l, _u, _d],
      <GameAction>[_u, _u],
      <GameAction>[_l, _l, _l, _d, _w, _w, _w, _w, _w, _d, _d, _d, _d],
    ],
  ),
  Level.parse(
    id: 7,
    par: 1,
    titleTr: 'Uzak Plaka',
    titleEn: 'The Far Plate',
    hintTr: 'Plaka uzakta. Yankının oraya varması zaman alır.',
    hintEn: 'The plate is far. Your echo needs time to reach it.',
    maxTurns: 12,
    maxClones: 1,
    map: '''
#############
#.1.........#
#...........#
#......P....#
#######.#####
#######A#####
#######.#####
#######E#####
#############
''',
  ),
  Level.parse(
    id: 8,
    par: 1,
    titleTr: 'Dar Geçit',
    titleEn: 'Tight Squeeze',
    hintTr: 'Sandık yolu tıkıyor. Önce onu kenara it.',
    hintEn: 'The crate blocks the way. Shove it aside first.',
    maxTurns: 10,
    maxClones: 1,
    map: '''
#########
#.1.....#
#.......#
#..PX...#
####.####
####A####
####.####
####E####
#########
''',
  ),
  Level.parse(
    id: 9,
    par: 2,
    titleTr: 'Ayna',
    titleEn: 'Mirror',
    hintTr: 'İki plaka, iki yön. İkisini de birinin tutması gerek.',
    hintEn: 'Two plates, two directions. Both need holding.',
    maxTurns: 12,
    maxClones: 2,
    map: '''
#############
#.1.......2.#
#...........#
#.....P.....#
######.######
######A######
######.######
######B######
######.######
######E######
#############
''',
  ),
  Level.parse(
    id: 10,
    par: 2,
    titleTr: 'Tersine',
    titleEn: 'Upside Down',
    hintTr: 'Çıkış yukarıda, plakalar aşağıda. Yol tek yönlü değil.',
    hintEn: 'The exit is above, the plates below. The path runs both ways.',
    maxTurns: 10,
    maxClones: 2,
    map: '''
###########
#####E#####
#####.#####
#####B#####
#####.#####
#####A#####
#####.#####
#....P....#
#.1.....2.#
###########
''',
  ),
  Level.parse(
    id: 11,
    par: 1,
    titleTr: 'Bankaya Yatır',
    titleEn: 'Bank It',
    hintTr: 'İki sandık, tek döngüye sığmaz. Yaptığın işi yankına devret.',
    hintEn: 'Two crates will not fit in one loop. Hand the work to your echo.',
    maxTurns: 12,
    maxClones: 2,
    map: '''
###########
#.1.....2.#
#..X...X..#
#....P....#
#####.#####
#####A#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 12,
    par: 2,
    titleTr: 'Yan Yana',
    titleEn: 'Side by Side',
    hintTr: 'Plakalar yan yana ama turun çok dar.',
    hintEn: 'The plates sit close, but your turns are tight.',
    maxTurns: 8,
    maxClones: 2,
    map: '''
###########
#.1.2.....#
#.........#
#....P....#
#####.#####
#####A#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 13,
    par: 2,
    titleTr: 'Üç Renk',
    titleEn: 'Three Colours',
    hintTr: 'Üç kapı, iki yankı. Üçüncüsünü sandık tutacak.',
    hintEn: 'Three gates, two echoes. The crate must hold the third.',
    maxTurns: 16,
    maxClones: 2,
    map: '''
#############
#.1.......3.#
#.....X.....#
#.2...P.....#
######.######
######A######
######B######
######C######
######E######
#############
''',
  ),
  Level.parse(
    id: 14,
    par: 1,
    titleTr: 'Kısa Yol',
    titleEn: 'Shortcut',
    hintTr: 'Sandık hemen yanında. Bir hamlede halledebilirsin.',
    hintEn: 'The crate is right there. One move settles it.',
    maxTurns: 9,
    maxClones: 1,
    map: '''
#########
#.....2.#
#.1...X.#
#.....P.#
###.#####
###A#####
###B#####
###E#####
#########
''',
  ),
  Level.parse(
    id: 15,
    par: 2,
    titleTr: 'Çatal',
    titleEn: 'The Fork',
    hintTr: 'Plakalara giden yollar ayrı. Her biri ayrı bir yankı ister.',
    hintEn: 'The plates sit down separate corridors. Each needs its own echo.',
    maxTurns: 14,
    maxClones: 2,
    map: '''
#############
#.1.......2.#
#.#########.#
#.#########.#
#.....P.....#
######.######
######A######
######B######
######E######
#############
''',
  ),
  Level.parse(
    id: 16,
    par: 2,
    titleTr: 'Son Yankı',
    titleEn: 'Final Echo',
    hintTr: 'Üç kapı, iki yankı, uzaktaki bir sandık. Hepsi yerini bulmalı.',
    hintEn: 'Three gates, two echoes, one distant crate. Everything must land.',
    maxTurns: 13,
    maxClones: 2,
    map: '''
###########
#.1.....3.#
#.......X.#
#.2..P....#
#####.#####
#####A#####
#####B#####
#####C#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 17,
    par: 0,
    titleTr: 'Çatlak Zemin',
    titleEn: 'Cracked Ground',
    hintTr: 'Çatlak zemin, üstünden çekildiğin anda çöker. Geri dönüş yok.',
    hintEn: 'Cracked ground caves in the moment you step off. No way back.',
    maxTurns: 12,
    maxClones: 0,
    map: '''
#########
#.......#
#..P....#
#.......#
####~####
####~####
#.......#
#...E...#
#.......#
#########
''',
  ),
  Level.parse(
    id: 18,
    par: 1,
    titleTr: 'Tek Yön',
    titleEn: 'One Way',
    hintTr: 'Köprüyü geçen bir daha dönemez. Öyleyse oraya geçmişini gönder.',
    hintEn: 'Whoever crosses cannot return. So send your past self instead.',
    maxTurns: 8,
    maxClones: 1,
    map: '''
##########
#EA.P~~~1#
##########
''',
  ),
  Level.parse(
    id: 19,
    par: 2,
    titleTr: 'Ağır Plaka',
    titleEn: 'Heavy Plate',
    hintTr: 'Bu plaka tek bedeni taşımaz. İki yankını aynı kareye yığ.',
    hintEn: 'This plate ignores a single body. Stack two echoes on one tile.',
    maxTurns: 6,
    maxClones: 2,
    map: '''
#########
#...4...#
#.......#
#...P...#
####.####
####A####
####E####
#########
''',
  ),
  Level.parse(
    id: 20,
    par: 2,
    titleTr: 'İkiye Bölün',
    titleEn: 'Split in Two',
    hintTr: 'Ağır plaka iki yankı ister, sandık da kendi plakasını tutar.',
    hintEn: 'The heavy plate wants both echoes; the crate holds its own.',
    maxTurns: 14,
    maxClones: 2,
    map: '''
###########
#...4...2.#
#.......X.#
#....P....#
#####.#####
#####A#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 21,
    par: 1,
    titleTr: 'Solan Kapı',
    titleEn: 'Fading Gate',
    hintTr: 'Mavi kapı her döngünün yalnızca ilk turlarında açık. Erken geç.',
    hintEn: 'The blue gate is open only early in each loop. Get through fast.',
    maxTurns: 8,
    maxClones: 1,
    fadeTurns: 4,
    map: '''
###########
#.1.......#
#....P....#
#####.#####
#####T#####
#####.#####
#####A#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 22,
    par: 2,
    titleTr: 'Son Kapı',
    titleEn: 'The Last Gate',
    hintTr: 'Çatlak köprü, ağır plaka ve solan kapı. Üçü de aynı anda.',
    hintEn: 'Cracked bridge, heavy plate, fading gate. All at once.',
    maxTurns: 10,
    maxClones: 2,
    fadeTurns: 5,
    map: '''
###########
#...4.....#
#.........#
#.P~~~~...#
#####.#####
#####T#####
#####A#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 23,
    par: 1,
    titleTr: 'Köprüyü Yakma',
    titleEn: 'Do Not Burn It',
    hintTr: 'Yankın da bu köprüden geçecek. Önden giderse arkasında köprü '
        'kalmaz.',
    hintEn: 'Your echo needs this bridge too. If it goes first, nothing is '
        'left for you.',
    maxTurns: 14,
    maxClones: 1,
    // Yankinin ne zaman gectigi sonucu degistiriyor: cozucu turu de hesaba
    // katmali, yoksa "hemen gec" adayini tutup dogru cevabi eler.
    timingSensitive: true,
    // Plaka ile kapisi arasinda bilerek bir kare var: kapi durumu turun
    // basinda sabitlendigi icin, plakanin uzerindeki biri bitisik kendi
    // kapisindan gecebilir. Aradaki bosluk bu kacamagi kapatir.
    map: '''
##############
#.2.##########
#.X.##########
#P..~~~1.AB.E#
##############
''',
  ),
];
