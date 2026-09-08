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
    maxTurns: 13,
    maxClones: 2,
    map: '''
#########
#1X.#####
#2..#####
#P.3ABCE#
#########
''',
    solution: <List<GameAction>>[
      <GameAction>[_u],
      <GameAction>[_r, _r],
      <GameAction>[_u, _r, _r, _u, _l, _d, _d, _r, _r, _r, _r, _r],
    ],
  ),
  Level.parse(
    id: 7,
    par: 1,
    titleTr: 'Uzak Plaka',
    titleEn: 'The Far Plate',
    hintTr: 'Plaka uzakta. Yankının oraya varması zaman alır.',
    hintEn: 'The plate is far. Your echo needs time to reach it.',
    maxTurns: 11,
    maxClones: 1,
    // Yatay kosu, cikis sagda: dikey koridor tekduzeliginden kacinmak icin.
    map: '''
#############
#.1.........#
#...........#
#..P.########
#....A.....E#
#....########
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
    maxTurns: 7,
    maxClones: 1,
    // Cikis yukarida; sandik koridor agzini tikiyor, yandan itilmeli.
    // Plaka bilerek sandigin satirinda degil: yoksa sandik plakaya itilir ve
    // yanki gereksiz kalirdi.
    map: '''
#########
####E####
####.####
####A####
####.####
#...X...#
#.1..P..#
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
    maxTurns: 16,
    maxClones: 2,
    // Acik oda + yatay kapi dizisi. Sandiklar niste: yalnizca yukari, kendi
    // plakalarina itilebilirler.
    map: '''
###########
#.1.....2.#
##X#####X##
#....P....#
#.#########
#.A...B..E#
###########
''',
  ),
  Level.parse(
    id: 12,
    par: 1,
    titleTr: 'Çember',
    titleEn: 'The Ring',
    hintTr: 'Çıkış tam ortada ama plakaya varmak için bütün çemberi dönmen '
        'gerek.',
    hintEn: 'The exit sits in the middle, but the plate is a full lap away.',
    maxTurns: 13,
    maxClones: 1,
    // Halka: cikis ortada, plakaya ulasmak icin butun cemberi donmek gerek.
    map: '''
#########
#...1...#
#.#####.#
#.#.E.#.#
#.##A##.#
#...P...#
#########
''',
  ),
  Level.parse(
    id: 13,
    par: 2,
    titleTr: 'Üç Renk',
    titleEn: 'Three Colours',
    hintTr: 'Üç kapı, iki yankı. Üçüncüsünü sandık tutacak.',
    hintEn: 'Three gates, two echoes. The crate must hold the third.',
    maxTurns: 12,
    maxClones: 2,
    map: '''
###########
#####E#####
#####C#####
#####B#####
#####A#####
#1..X..3..#
#2...P....#
###########
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
    hintTr: 'Sandık tek yönde gitmiyor: önce sağa, sonra aşağı '
        'itilmeli.',
    hintEn: 'The crate will not do it in one direction: push it right, '
        'then down.',
    maxTurns: 11,
    maxClones: 2,
    map: '''
###########
#12...#####
#P.X..ABCE#
#....3#####
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
    maxTurns: 11,
    maxClones: 2,
    map: '''
###########
#4.X.2.####
#P.....ABE#
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
  Level.parse(
    id: 24,
    par: 3,
    titleTr: 'Üçleme',
    titleEn: 'Threefold',
    hintTr: 'Üç plaka, üç kapı. Üçünü de birinin tutması gerek.',
    hintEn: 'Three plates, three gates. Each one needs a body.',
    maxTurns: 8,
    maxClones: 3,
    map: '''
###########
#####1#####
#####.#####
#EABC.P..2#
#####.#####
#####3#####
###########
''',
  ),
  Level.parse(
    id: 25,
    par: 3,
    titleTr: 'Ağır Yankı',
    titleEn: 'Heavy Echo',
    hintTr: 'Ağır plaka iki yankı yutar. Üçüncüsü diğer plakaya kalır.',
    hintEn: 'The heavy plate swallows two echoes. The third takes the other.',
    maxTurns: 7,
    maxClones: 3,
    map: '''
#########
#..4..2.#
#...P...#
####.####
####A####
####B####
####E####
#########
''',
  ),
  Level.parse(
    id: 26,
    par: 2,
    titleTr: 'Birlikte Geç',
    titleEn: 'Cross Together',
    hintTr: 'İki yankı da köprüyü geçmeli. Biri önden giderse diğerine yol '
        'kalmaz — üçünüz aynı anda yürüyün.',
    hintEn: 'Both echoes must cross. If one goes first the other is stranded '
        '— all three of you walk as one.',
    maxTurns: 8,
    maxClones: 2,
    timingSensitive: true,
    map: '''
#######
#P#####
#~#####
#~#####
#~#####
#4.AE##
#######
''',
  ),
  Level.parse(
    id: 27,
    par: 2,
    titleTr: 'Bekleme Odası',
    titleEn: 'The Waiting Room',
    hintTr: 'Mavi kapıdan hemen geçmelisin, sonra içeride yankını bekle.',
    hintEn: 'Dash through the blue gate at once, then wait inside for your '
        'echo.',
    maxTurns: 7,
    maxClones: 2,
    fadeTurns: 3,
    map: '''
##########
#1X.######
#..2TABE##
#.P.######
##########
''',
  ),
  Level.parse(
    id: 28,
    par: 3,
    titleTr: 'Üç Yol',
    titleEn: 'Three Roads',
    hintTr: 'Üç plaka, üç ayrı yön. Hepsine ayrı bir yankı gerekiyor.',
    hintEn: 'Three plates, three directions. Each needs its own echo.',
    maxTurns: 11,
    maxClones: 3,
    map: '''
#############
#.1.......3.#
#...........#
#.....P.....#
#.2.........#
######.######
######A######
######B######
######C######
######E######
#############
''',
  ),
  Level.parse(
    id: 29,
    par: 2,
    titleTr: 'Yankı Treni',
    titleEn: 'Echo Train',
    hintTr: 'Köprünün ötesinde iki plaka var ve köprü tek geçişlik. '
        'Kafile hâlinde yürüyün.',
    hintEn: 'Two plates wait beyond a bridge that holds for one crossing. '
        'Travel as a convoy.',
    maxTurns: 15,
    maxClones: 2,
    timingSensitive: true,
    map: '''
#############
#P..~~~~12..#
###########.#
###########A#
###########B#
###########E#
#############
''',
  ),
  Level.parse(
    id: 30,
    par: 2,
    titleTr: 'Zincir',
    titleEn: 'The Chain',
    hintTr: 'İkinci yankın, birincinin açtığı kapıdan geçmek zorunda. '
        'Sıra önemli.',
    hintEn: 'Your second echo must pass the gate the first one holds open. '
        'Order matters.',
    maxTurns: 7,
    maxClones: 2,
    map: '''
###########
#....1....#
#....P....#
#####A#####
#....2....#
#####.#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 31,
    par: 3,
    titleTr: 'Çifte Zincir',
    titleEn: 'Double Chain',
    hintTr: 'Her yankı bir öncekinden bir kapı daha derine iniyor.',
    hintEn: 'Each echo reaches one gate deeper than the last.',
    maxTurns: 10,
    maxClones: 3,
    map: '''
###########
#....1....#
#....P....#
#####A#####
#....2....#
#####.#####
#####B#####
#....3....#
#####.#####
#####C#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 32,
    par: 3,
    titleTr: 'Kıl Payı',
    titleEn: 'By a Hair',
    hintTr: 'Üç plaka, üç kapı, dar bir tur bütçesi. Her yankı en kısa '
        'yolu bulmalı.',
    hintEn: 'Three plates, three gates, a tight budget: every echo must '
        'take the shortest way.',
    maxTurns: 8,
    maxClones: 3,
    map: '''
#########
#1P######
#2.######
#3.######
##.ABCE##
#########
''',
  ),
  Level.parse(
    id: 33,
    par: 2,
    titleTr: 'Tek Şans',
    titleEn: 'One Chance',
    hintTr: 'Mavi kapı yalnızca ilk turda açık. Aşağı inecek herkes hemen '
        'inmeli.',
    hintEn: 'The blue gate is open on the first turn only. Everyone going '
        'down goes now.',
    maxTurns: 7,
    maxClones: 2,
    fadeTurns: 1,
    map: '''
###########
#....1....#
#....P....#
#####T#####
#####A#####
#....2....#
#####.#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 34,
    par: 4,
    titleTr: 'Dört Beden',
    titleEn: 'Four Bodies',
    hintTr: 'İki ağır plaka, ikişer beden. Dördünü de geçmişten çıkaracaksın.',
    hintEn: 'Two heavy plates, two bodies each. All four come from your past.',
    maxTurns: 6,
    maxClones: 4,
    map: '''
#########
#..4.5..#
#...P...#
####A####
####B####
####E####
#########
''',
  ),
  Level.parse(
    id: 35,
    par: 3,
    titleTr: 'Ağır Zincir',
    titleEn: 'Heavy Chain',
    hintTr: 'Ağır plaka kapının ardında. İki yankının da oraya inmesi gerek.',
    hintEn: 'The heavy plate sits behind a gate. Both echoes must get down '
        'there.',
    maxTurns: 7,
    maxClones: 3,
    map: '''
#########
###...###
##..1..##
###.P.###
####A####
###...###
##..5..##
###...###
####B####
####E####
#########
''',
  ),
  Level.parse(
    id: 36,
    par: 2,
    titleTr: 'Kırılgan Zincir',
    titleEn: 'Brittle Chain',
    hintTr: 'Yankın kapıdan geçip köprüyü de yakacak. Onunla aynı anda in.',
    hintEn: 'Your echo goes through the gate and burns the bridge behind it. '
        'Go down at the same moment.',
    maxTurns: 9,
    maxClones: 2,
    timingSensitive: true,
    map: '''
###########
#P..1.....#
##A########
##~~2.....#
##.########
##B########
##E########
###########
''',
  ),
  Level.parse(
    id: 37,
    par: 2,
    titleTr: 'Kilitli Sandık',
    titleEn: 'The Locked Crate',
    hintTr: 'Sandık kapının ardında kilitli. Önce kapıyı açtır, sonra it.',
    hintEn: 'The crate is locked behind a gate. Open it first, then shove.',
    maxTurns: 12,
    maxClones: 2,
    map: '''
###########
#....1....#
#....P....#
#####A#####
#.2X.....3#
#####.#####
#####B#####
#####C#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 38,
    par: 2,
    titleTr: 'Hep Birlikte',
    titleEn: 'All at Once',
    hintTr: 'Mavi kapı bir tur açık, ağır plaka iki beden istiyor. '
        'Herkes ilk turda inecek.',
    hintEn: 'The blue gate lasts one turn and the heavy plate wants two '
        'bodies. Everyone goes on turn one.',
    maxTurns: 7,
    maxClones: 2,
    fadeTurns: 1,
    map: '''
###########
#....P....#
#####T#####
#####.#####
#....4....#
#####.#####
#####A#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 39,
    par: 4,
    titleTr: 'Dörtlü Zincir',
    titleEn: 'Fourfold Chain',
    hintTr: 'Her yankı bir kapı daha derine. En dipteki plaka ikisini birden '
        'istiyor.',
    hintEn: 'Each echo goes one gate deeper. The last plate wants two of them.',
    maxTurns: 12,
    maxClones: 4,
    map: '''
#########
#1P######
##A######
##.2.####
####B####
####.6.##
######C##
######E##
#########
''',
  ),
  Level.parse(
    id: 40,
    par: 2,
    titleTr: 'Üç Sandık',
    titleEn: 'Three Crates',
    hintTr: 'Üç sandık, üç plaka. Hepsi tek döngüye sığmaz.',
    hintEn: 'Three crates, three plates. They will not fit in one loop.',
    maxTurns: 13,
    maxClones: 2,
    // Sandiklar birer nise oturuyor: yalnizca yukari, kendi plakalarina
    // itilebilirler. Hem oyuncu icin okunakli, hem cozucunun durum uzayi
    // sandik konumlariyla patlamiyor.
    map: '''
#############
#.1...2...3.#
##X###X###X##
#.....P.....#
######.######
######A######
######B######
######C######
######E######
#############
''',
  ),
  Level.parse(
    id: 41,
    par: 3,
    titleTr: 'Köprü ve Ağırlık',
    titleEn: 'Bridge and Weight',
    hintTr: 'Köprünün ötesinde ağır bir plaka var. İki yankı da karşıya '
        'geçmeli, üçüncüsü uzaktaki plakayı tutmalı.',
    hintEn: 'A heavy plate waits across the bridge. Two echoes must cross, '
        'a third holds the far plate.',
    maxTurns: 11,
    maxClones: 3,
    timingSensitive: true,
    map: '''
###########
#P.~~######
####~######
#..5.1.ABE#
###########
''',
  ),
  Level.parse(
    id: 42,
    par: 4,
    titleTr: 'Sıkışık Dörtlü',
    titleEn: 'Tight Four',
    hintTr: 'İki ağır plaka, dört beden, tam yedi tur. Kimse yolunu şaşıramaz.',
    hintEn: 'Two heavy plates, four bodies, exactly seven turns. Nobody may '
        'wander.',
    maxTurns: 7,
    maxClones: 4,
    map: '''
###########
#.4.....5.#
#....P....#
#####A#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 43,
    par: 3,
    titleTr: 'Solan Zincir',
    titleEn: 'Fading Chain',
    hintTr: 'Mavi kapı bir tur açık. Aşağı inecek dört bedenin dördü de '
        'ilk turda inmeli.',
    hintEn: 'The blue gate lasts one turn. All four bodies going down must '
        'go now.',
    maxTurns: 10,
    maxClones: 3,
    fadeTurns: 1,
    map: '''
###########
#....P....#
#####T#####
#####.#####
#....1....#
#####.#####
#####A#####
#....5....#
#####.#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 44,
    par: 4,
    titleTr: 'Kalabalık',
    titleEn: 'The Crowd',
    hintTr: 'İki ağır plaka arka arkaya. İkinciye geçmek için '
        'birincisi dolu kalmalı.',
    hintEn: 'Two heavy plates in a row: the second is out of reach '
        'until the first stays full.',
    maxTurns: 8,
    maxClones: 4,
    map: '''
###########
#...#...###
#.4.A.5.BE#
#.P.#...###
###########
''',
  ),
  Level.parse(
    id: 45,
    par: 3,
    titleTr: 'Döngünün Sonu',
    titleEn: 'End of the Loop',
    hintTr: 'Solan kapı, zincir, çatlak köprü ve ağır plaka. Hepsi aynı anda.',
    hintEn: 'Fading gate, chain, brittle bridge and heavy plate. All at once.',
    maxTurns: 11,
    maxClones: 3,
    fadeTurns: 1,
    timingSensitive: true,
    map: '''
###########
#....P....#
#####T#####
#....1....#
#####.#####
#####A#####
#.6~~~....#
#####.#####
#####C#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 46,
    par: 0,
    titleTr: 'Düğme',
    titleEn: 'The Switch',
    hintTr: 'Düğmeye bas ve yürü. Plakadan farkı: çekilince kapanmaz.',
    hintEn: 'Press the switch and walk on. Unlike a plate, it stays.',
    maxTurns: 8,
    maxClones: 0,
    map: '''
#########
#.....###
#.P.7.AE#
#.....###
#########
''',
  ),
  Level.parse(
    id: 47,
    par: 1,
    titleTr: 'Düğme ve Plaka',
    titleEn: 'Switch and Plate',
    hintTr: 'Biri basılı tutulmak ister, diğeri istemez. Hangisi hangisi?',
    hintEn: 'One wants to be held down, the other does not. Which is which?',
    maxTurns: 23,
    maxClones: 1,
    map: '''
###########
#.1.......#
#.P....8..#
#.#########
#.A...B..E#
###########
''',
  ),
  Level.parse(
    id: 48,
    par: 0,
    titleTr: 'Buz',
    titleEn: 'Ice',
    hintTr: 'Buzda duramazsın; bir engel seni durdurana kadar kayarsın.',
    hintEn: 'You cannot stop on ice; you slide until something stops you.',
    maxTurns: 5,
    maxClones: 0,
    map: '''
##########
#.P*****##
#######E##
##########
''',
  ),
  Level.parse(
    id: 49,
    par: 1,
    titleTr: 'Buzda Yankı',
    titleEn: 'Echo on Ice',
    hintTr: 'Kayış seni tam kapının önüne bırakıyor. Kapıyı da birinin '
        'açması gerek.',
    hintEn: 'The slide drops you right at the gate. Somebody still has to '
        'open it.',
    maxTurns: 4,
    maxClones: 1,
    map: '''
##########
#.1......#
#.P*****##
#######A##
#######E##
##########
''',
  ),
  Level.parse(
    id: 50,
    par: 1,
    titleTr: 'Geri Dönüş Yok',
    titleEn: 'No Way Back',
    hintTr: 'Oktan geçince sola dönemezsin. Düğmeye önce basmalısın.',
    hintEn: 'Past the arrow there is no going left. Press the switch first.',
    maxTurns: 19,
    maxClones: 1,
    map: '''
#########
#7.2.P>.#
#######.#
#EA...B.#
#########
''',
  ),
  Level.parse(
    id: 51,
    par: 0,
    titleTr: 'Işınlanma',
    titleEn: 'The Gateway',
    hintTr: 'İki ada birbirine değmiyor. Halkaya bas, eşinde çık.',
    hintEn: 'Two islands that never touch. Step on the ring, come out at its '
        'twin.',
    maxTurns: 12,
    maxClones: 0,
    map: '''
###########
#.P..(....#
###########
#.E......)#
###########
''',
  ),
  Level.parse(
    id: 52,
    par: 1,
    titleTr: 'İki Ada',
    titleEn: 'Two Islands',
    hintTr: 'Plaka öteki adada. Yankını da oraya göndermen gerekecek.',
    hintEn: 'The plate is on the other island. Your echo has to go there too.',
    maxTurns: 7,
    maxClones: 1,
    map: '''
#######
#P#)..#
#1#...#
#(#...#
###A..#
###E###
#######
''',
  ),
  Level.parse(
    id: 53,
    par: 0,
    titleTr: 'Zincirleme',
    titleEn: 'Chain Reaction',
    hintTr: 'Kay, ışınlan, düğmeye bas, oktan geç. Tek hamlede başlıyor.',
    hintEn: 'Slide, teleport, press, pass the arrow. It starts with one move.',
    maxTurns: 6,
    maxClones: 0,
    map: '''
########
#P***(##
######)#
######7#
######v#
######A#
######E#
########
''',
  ),
  Level.parse(
    id: 54,
    par: 0,
    titleTr: 'İki Düğme',
    titleEn: 'Two Switches',
    hintTr: 'Her düğme bir sonraki kapıyı açıyor. Yol seni geri getiriyor.',
    hintEn: 'Each switch opens the next gate. The path folds back on itself.',
    maxTurns: 18,
    maxClones: 0,
    map: '''
##########
#.P.7....#
#######A##
#....8...#
##B#######
#E.......#
##########
''',
  ),
  Level.parse(
    id: 55,
    par: 1,
    titleTr: 'Yankı Düğmeyi Bozar',
    titleEn: 'The Echo Undoes It',
    hintTr: 'Yankın yolda düğmeye basabilir. Onu nereden geçireceğin önemli.',
    hintEn: 'Your echo can hit the switch on its way. Where you route it '
        'matters.',
    maxTurns: 10,
    maxClones: 1,
    map: '''
##########
#######E##
#######B##
#######A##
#..7.P..2#
##########
''',
  ),
  Level.parse(
    id: 56,
    par: 0,
    titleTr: 'Buz Üstünde Düğme',
    titleEn: 'Switch on Ice',
    hintTr: 'Buzda duramazsın ama düğmede durursun. Kayış seni oraya bırakır.',
    hintEn: 'You cannot stop on ice, but you can stop on a switch. The slide '
        'delivers you.',
    maxTurns: 5,
    maxClones: 0,
    map: '''
#########
#E#######
#A#######
#P***7..#
#########
''',
  ),
  Level.parse(
    id: 57,
    par: 1,
    titleTr: 'Kaygan Zincir',
    titleEn: 'Slippery Chain',
    hintTr: 'Kayış seni koridorun ağzına bırakıyor. Yukarısı için yankı lazım.',
    hintEn: 'The slide leaves you at the corridor mouth. The way up needs an '
        'echo.',
    maxTurns: 7,
    maxClones: 1,
    map: '''
###########
####E######
####A######
####.######
#.1..****P#
###########
''',
  ),
  Level.parse(
    id: 58,
    par: 1,
    titleTr: 'Ada Düğmesi',
    titleEn: 'Island Switch',
    hintTr: 'Düğme de plaka da öteki adada. Yankını da oraya yollaman gerek.',
    hintEn: 'Switch and plate both sit on the far island. Your echo has to go '
        'too.',
    maxTurns: 8,
    maxClones: 1,
    map: '''
#######
#P.(..#
#######
#18)..#
#####A#
#####B#
#####E#
#######
''',
  ),
  Level.parse(
    id: 59,
    par: 1,
    titleTr: 'Tek Yön Düğmesi',
    titleEn: 'One-Way Switch',
    hintTr: 'Aşağı inince yukarı dönemezsin. Plakayı tutacak biri yukarıda '
        'kalmalı.',
    hintEn: 'Once you drop, there is no climbing back. Somebody must stay up '
        'top.',
    maxTurns: 7,
    maxClones: 1,
    map: '''
###########
#.2.......#
#....P....#
#####v#####
#####7#####
#####A#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 60,
    par: 1,
    titleTr: 'Uzun Yol',
    titleEn: 'The Long Way',
    hintTr: 'Düğme bir uçta, plaka diğerinde. İkisi de gerekli.',
    hintEn: 'The switch at one end, the plate at the other. You need both.',
    maxTurns: 13,
    maxClones: 1,
    map: '''
###########
#2#######E#
#.#######B#
#.#######A#
#.#######.#
#P...7....#
###########
''',
  ),
  Level.parse(
    id: 61,
    par: 1,
    titleTr: 'Kırılgan Düğme',
    titleEn: 'Brittle Switch',
    hintTr: 'Yankın da düğmeye basıp köprüyü geçecek. Aynı turda basarsanız '
        'düğme tek sayılır.',
    hintEn: 'Your echo presses the switch and crosses too. Step on it together '
        'and it counts once.',
    maxTurns: 9,
    maxClones: 1,
    map: '''
########
#####7P#
#####~##
#####~##
#EBA.2##
########
''',
  ),
  Level.parse(
    id: 62,
    par: 0,
    titleTr: 'Üç Düğme',
    titleEn: 'Three Switches',
    hintTr: 'Sarmal bir yol, üç düğme. Her biri bir sonraki kapıyı açar.',
    hintEn: 'A spiralling path and three switches, each opening the next gate.',
    maxTurns: 28,
    maxClones: 0,
    map: '''
###########
#.P.7.....#
#########.#
#.8.....A.#
#..########
#.9..B.C.E#
###########
''',
  ),
  Level.parse(
    id: 63,
    par: 1,
    titleTr: 'Zincirde Düğme',
    titleEn: 'Switch in the Chain',
    hintTr: 'Zincirin dibindeki düğme, orada kalacak bir yankıdan tasarruf '
        'ettirir.',
    hintEn: 'A switch at the end of the chain saves you an echo.',
    maxTurns: 7,
    maxClones: 1,
    map: '''
#######
#1P####
##A####
##.8###
###.B##
####E##
#######
''',
  ),
  Level.parse(
    id: 64,
    par: 1,
    titleTr: 'Solan Düğme',
    titleEn: 'Fading Switch',
    hintTr: 'Mavi kapı bir tur açık. İkiniz de aynı anda inip düğmeye birlikte '
        'basacaksınız.',
    hintEn: 'The blue gate lasts one turn. You and your echo go down together '
        'and hit the switch as one.',
    maxTurns: 8,
    maxClones: 1,
    fadeTurns: 1,
    map: '''
###########
#....P....#
#####T#####
#####7#####
#####A#####
#....2....#
#####.#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 65,
    par: 2,
    titleTr: 'Ağır Düğme',
    titleEn: 'Heavy Switch',
    hintTr: 'Düğmeye hep birlikte basın: aynı turda basılırsa bir kez sayılır.',
    hintEn: 'Press the switch all together: stepped on in one turn, it counts '
        'once.',
    maxTurns: 12,
    maxClones: 2,
    map: '''
###########
#.7.#.....#
#...A.#.#.#
#.P.#..5..#
########B##
########E##
###########
''',
  ),
  Level.parse(
    id: 66,
    par: 0,
    titleTr: 'Buz Yolu',
    titleEn: 'Ice Run',
    hintTr: 'İki kayış, iki duvar. Duvarlar seni doğru yere bırakıyor.',
    hintEn: 'Two slides, two walls. The walls put you where you need to be.',
    maxTurns: 4,
    maxClones: 0,
    map: '''
#########
#.P*****#
#######*#
#######*#
#######E#
#########
''',
  ),
  Level.parse(
    id: 67,
    par: 1,
    titleTr: 'Sandık ve Düğme',
    titleEn: 'Crate and Switch',
    hintTr: 'İki sandık, bir düğme, üç kapı. Tek döngüye sığmaz.',
    hintEn: 'Two crates, one switch, three gates. Too much for a single loop.',
    maxTurns: 18,
    maxClones: 2,
    map: '''
###########
#.2.....3.#
##X#####X##
#..7.P....#
#####.#####
#####A#####
#####B#####
#####C#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 68,
    par: 1,
    titleTr: 'Yanlış Düğme',
    titleEn: 'The Wrong Switch',
    hintTr: 'Kısa yol düğmeye uğramıyor. Yankını uzun yoldan '
        'geçirmelisin.',
    hintEn: 'The short route skips the switch, so send your echo the long '
        'way round.',
    maxTurns: 9,
    maxClones: 1,
    map: '''
##########
#..7..####
#P...2ABE#
##########
''',
  ),
  Level.parse(
    id: 69,
    par: 2,
    titleTr: 'Sıra Meselesi',
    titleEn: 'A Matter of Order',
    hintTr: 'Düğmeye basacak yankı, plakaya oturacak yankıdan önce '
        'kaydedilmeli.',
    hintEn: 'The echo that presses must be recorded before the echo that '
        'sits.',
    maxTurns: 13,
    maxClones: 2,
    map: '''
##########
#7P#######
##A#######
##..2#####
###B######
###..3####
####C#####
####E#####
##########
''',
  ),
  Level.parse(
    id: 70,
    par: 1,
    titleTr: 'Kayarak Bas',
    titleEn: 'Slide and Press',
    hintTr: 'Kayış seni düğmeye götürüyor ama plakaya götürmüyor.',
    hintEn: 'The slide carries you to the switch, but never to the plate.',
    maxTurns: 10,
    maxClones: 1,
    map: '''
############
#.2........#
#.P****7..##
#########.##
#########A##
#########B##
#########E##
############
''',
  ),
  Level.parse(
    id: 71,
    par: 2,
    titleTr: 'Ada Zinciri',
    titleEn: 'Island Chain',
    hintTr: 'Öteki adada bir düğme, bir de plaka var. İkisi de tutulmalı.',
    hintEn: 'The far island holds a switch and a plate. Both must be dealt '
        'with.',
    maxTurns: 9,
    maxClones: 2,
    map: '''
########
#P..(..#
########
###1####
###).2.#
###9####
###A####
###B####
###C####
###E####
########
''',
  ),
  Level.parse(
    id: 72,
    par: 1,
    titleTr: 'Ok ve Düğme',
    titleEn: 'Arrow and Switch',
    hintTr: 'Ok seni tek yöne sokuyor. Düğmeye girmeden önce basmalısın.',
    hintEn: 'The arrow commits you. Press the switch before you go in.',
    maxTurns: 16,
    maxClones: 1,
    map: '''
#############
#.7...2...P.#
#.#########.#
#.A.......>.#
##B##########
##E##########
#############
''',
  ),
  Level.parse(
    id: 73,
    par: 2,
    titleTr: 'Çifte Parite',
    titleEn: 'Double Parity',
    hintTr: 'İki yankı da düğmenin üstünden geçecek. Aynı turda geçerlerse '
        'bir kez sayılır.',
    hintEn: 'Both echoes will cross the switch. Crossing together counts '
        'once.',
    maxTurns: 6,
    maxClones: 2,
    map: '''
##########
#..P..ABE#
###7######
###~######
###5######
##########
''',
  ),
  Level.parse(
    id: 74,
    par: 0,
    titleTr: 'Buz Sarmalı',
    titleEn: 'Ice Spiral',
    hintTr: 'Her duvar seni bir sonraki kayışa hazırlıyor.',
    hintEn: 'Each wall sets you up for the next slide.',
    maxTurns: 8,
    maxClones: 0,
    map: '''
##########
#.P*****##
#######*##
#######*##
#E******##
##########
''',
  ),
  Level.parse(
    id: 75,
    par: 2,
    titleTr: 'Üç Beden',
    titleEn: 'Three Bodies',
    hintTr: 'Ağır plaka iki beden, düğme bir dokunuş ister.',
    hintEn: 'The heavy plate wants two bodies; the switch wants one touch.',
    maxTurns: 9,
    maxClones: 2,
    map: '''
#############
#.....4.....#
#.....P.....#
#.8#######..#
#.A.........#
##B##########
##E##########
#############
''',
  ),
  Level.parse(
    id: 76,
    par: 1,
    titleTr: 'Dar Ada',
    titleEn: 'Narrow Island',
    hintTr: 'Işınlanma kapısı seni alt sıraya atar. Plaka orada kalmalı, '
        'çıkış yukarıda.',
    hintEn: 'The portal drops you to the lower row: the plate stays down '
        'there, the exit is up top.',
    maxTurns: 8,
    maxClones: 1,
    map: '''
########
#P.(#AE#
#####.##
#1..)..#
########
''',
  ),
  Level.parse(
    id: 77,
    par: 1,
    titleTr: 'Düğme Köprüsü',
    titleEn: 'Switch Bridge',
    hintTr: 'Köprüyü geçen düğmeye basar ama geri dönemez.',
    hintEn: 'Whoever crosses hits the switch and can never return.',
    maxTurns: 11,
    maxClones: 2,
    map: '''
##########
#P..7#####
####~#####
####~#####
####.2ABE#
##########
''',
  ),
  Level.parse(
    id: 78,
    par: 2,
    titleTr: 'Dört Kapı',
    titleEn: 'Four Gates',
    hintTr: 'Düğme bir kapıyı halleder. Kalan üçü beden ister.',
    hintEn: 'The switch handles one gate. The other three want bodies.',
    maxTurns: 12,
    maxClones: 3,
    map: '''
###########
#1.......2#
#....9....#
#....P....#
#.#########
#A#########
#B#########
#C#########
#E#########
###########
''',
  ),
  Level.parse(
    id: 79,
    par: 1,
    titleTr: 'Geri Sayım',
    titleEn: 'Countdown',
    hintTr: 'Mavi kapı iki tur açık. Düğmeye basıp dönecek vaktin var mı?',
    hintEn: 'The blue gate lasts two turns. Time enough to press and return?',
    maxTurns: 12,
    maxClones: 2,
    fadeTurns: 2,
    map: '''
###########
#.7.P.2...#
#####T#####
#####.#####
#####A#####
#####B#####
#####E#####
###########
''',
  ),
  Level.parse(
    id: 80,
    par: 1,
    titleTr: 'Geniş Oda',
    titleEn: 'The Wide Room',
    hintTr: 'Koridor yok, tek bir oda var. Çıkış odanın göbeğinde kilitli.',
    hintEn: 'No corridors here, just one room — with the exit locked in its '
        'heart.',
    maxTurns: 13,
    maxClones: 1,
    map: '''
#############
#...........#
#...........#
#....###....#
#....#E#....#
#....#B#....#
#....#A#....#
#.1......8..#
#.....P.....#
#############
''',
  ),
  Level.parse(
    id: 81,
    par: 1,
    titleTr: 'Sola Doğru',
    titleEn: 'Leftward',
    hintTr: 'Çıkış solda. Yolun üstündeki iki kapı da açılmalı.',
    hintEn: 'The exit lies west. Both gates on the way must give.',
    maxTurns: 14,
    maxClones: 1,
    map: '''
#############
#########.1.#
#E.B...A....#
#########.8.#
#########P..#
#############
''',
  ),
  Level.parse(
    id: 82,
    par: 1,
    titleTr: 'T Kolu',
    titleEn: 'The T',
    hintTr: 'Düğme bir yanda, plaka diğer yanda. Çıkış tam ortadan yukarı.',
    hintEn: 'Switch on one side, plate on the other. The exit runs straight '
        'up the middle.',
    maxTurns: 11,
    maxClones: 1,
    map: '''
#############
######E######
######B######
######A######
#..8..P..1..#
#############
''',
  ),
  Level.parse(
    id: 83,
    par: 0,
    titleTr: 'Yılan',
    titleEn: 'Serpentine',
    hintTr: 'Yol katlanarak geri geliyor. Düğme en uzak noktada.',
    hintEn: 'The path folds back on itself, and the switch sits at the far '
        'end.',
    maxTurns: 19,
    maxClones: 0,
    map: '''
#########
#P.....7#
#######.#
#A......#
#.#######
#E#######
#########
''',
  ),
  Level.parse(
    id: 84,
    par: 1,
    titleTr: 'İkiz Oda',
    titleEn: 'Twin Rooms',
    hintTr: 'İki odayı tek bir kapı ayırıyor. Onu açık tutacak biri lazım.',
    hintEn: 'A single gate divides the two rooms, and it needs somebody to '
        'hold it.',
    maxTurns: 12,
    maxClones: 1,
    map: '''
#############
#.....#.....#
#.1...A...E.#
#.....#.....#
#..P..#.....#
#############
''',
  ),
  Level.parse(
    id: 85,
    par: 2,
    titleTr: 'Merkez',
    titleEn: 'The Middle',
    hintTr: 'Ortadan başlıyorsun. Plakalar iki farklı kolda.',
    hintEn: 'You start at the centre. The plates lie down separate arms.',
    maxTurns: 7,
    maxClones: 2,
    map: '''
###########
#####E#####
#####B#####
#####A#####
#..1.P....#
#####.#####
#####2#####
###########
''',
  ),
  Level.parse(
    id: 86,
    par: 1,
    titleTr: 'Halka',
    titleEn: 'The Ring',
    hintTr: 'İki düğme halkanın iki ucunda. Bir turda ikisine birden '
        'yetişemezsin.',
    hintEn: 'Two switches sit at opposite ends of the ring, and one loop is '
        'not enough for both.',
    maxTurns: 12,
    maxClones: 1,
    map: '''
#########
#...P...#
#.#####.#
#7##E##8#
#.##A##.#
#...B...#
#########
''',
  ),
  Level.parse(
    id: 87,
    par: 1,
    titleTr: 'Aynı Adım',
    titleEn: 'In Step',
    hintTr: 'Düğmeye yankınla aynı anda basarsan düğme yalnızca bir kez '
        'döner.',
    hintEn: 'Step onto the switch at the same moment as your echo and it '
        'turns only once.',
    maxTurns: 8,
    maxClones: 1,
    map: '''
#########
#P..7.8##
####A####
####B####
####E####
#########
''',
  ),
  Level.parse(
    id: 88,
    par: 2,
    titleTr: 'Dört Oda',
    titleEn: 'Four Rooms',
    hintTr: 'Ağır plaka alt odada, düğme karşı odada. Sıra önemli.',
    hintEn: 'The heavy plate is downstairs, the switch is across the hall, '
        'and the order matters.',
    maxTurns: 13,
    maxClones: 2,
    map: '''
#############
#.....#.....#
#..P..A..8..#
#.....#.....#
###.#####B###
#.....#.....#
#..4..#..E..#
#.....#.....#
#############
''',
  ),
  Level.parse(
    id: 89,
    par: 1,
    titleTr: 'Tek Sayı',
    titleEn: 'Odd Count',
    hintTr: 'Aynı kapıya iki düğme. Kapı ancak tek sayıda basıştan sonra '
        'açık kalır.',
    hintEn: 'Two switches, one gate: it stays open only after an odd number '
        'of presses.',
    maxTurns: 10,
    maxClones: 1,
    map: '''
########
#P###AE#
#.###.##
#7...7##
########
''',
  ),
  Level.parse(
    id: 90,
    par: 2,
    titleTr: 'İki Yaka',
    titleEn: 'Two Shores',
    hintTr: 'Işınlanma kapısı seni karşıya atar, plakalar bu yakada kalır.',
    hintEn: 'The portal throws you across, but the plates stay on this shore.',
    maxTurns: 8,
    maxClones: 2,
    map: '''
#############
#.....#.....#
#1.(.2#..)..#
#..P..#..A..#
#.....###B###
#########E###
#############
''',
  ),
  Level.parse(
    id: 91,
    par: 1,
    titleTr: 'Feda',
    titleEn: 'The Sacrifice',
    hintTr: 'Düğmeye giden köprü tek geçişlik. Giden geri dönemez.',
    hintEn: 'The bridge to the switch holds for one crossing; whoever goes '
        'does not come back.',
    maxTurns: 9,
    maxClones: 1,
    map: '''
###########
#....#....#
#.P..A..E.#
#....#....#
###~#######
###7#######
###########
''',
  ),
  Level.parse(
    id: 92,
    par: 1,
    titleTr: 'Tek Yön',
    titleEn: 'One Way',
    hintTr: 'İki kol da tek yönlü. Bir beden ancak birini seçebilir.',
    hintEn: 'Both branches are one-way, so a single body can only pick one.',
    maxTurns: 9,
    maxClones: 1,
    map: '''
###########
#....P....#
#.........#
##v#####v##
##7#####A##
########E##
###########
''',
  ),
  Level.parse(
    id: 93,
    par: 1,
    titleTr: 'Sarmal',
    titleEn: 'Spiral',
    hintTr: 'Yol merkeze kadar sarılıyor. Plakayı en baştaki geçitte bırak.',
    hintEn: 'The path winds all the way to the centre, so leave the plate '
        'held back at the start.',
    maxTurns: 17,
    maxClones: 1,
    map: '''
#######
#P.1..#
#####.#
#.AE#.#
#.###.#
#.....#
#######
''',
  ),
  Level.parse(
    id: 94,
    par: 1,
    titleTr: 'Buz Odası',
    titleEn: 'The Ice Room',
    hintTr: 'Buzda duramazsın; ancak buz olmayan bir kare seni durdurur.',
    hintEn: 'You cannot stop on ice — only a tile that is not ice will halt '
        'you.',
    maxTurns: 5,
    maxClones: 1,
    map: '''
#########
#*******#
#P*****7#
#******A#
#2****#B#
#*****#E#
#########
''',
  ),
  Level.parse(
    id: 95,
    par: 1,
    titleTr: 'Uzak Sandık',
    titleEn: 'The Far Crate',
    hintTr: 'Sandığı plakaya itmek uzun sürer. Çıkış ise ters yönde.',
    hintEn: 'Shoving the crate onto the plate takes a while, and the exit is '
        'the other way.',
    maxTurns: 6,
    maxClones: 1,
    map: '''
###########
##.......##
#EA..P.X.1#
##.......##
###########
''',
  ),
  Level.parse(
    id: 96,
    par: 2,
    titleTr: 'Üç Kapı',
    titleEn: 'Three Gates',
    hintTr: 'Üç kapı arka arkaya. Ağır plaka iki beden ister, düğmeler '
        'sana kalıyor.',
    hintEn: 'Three gates in a row: the heavy plate wants two bodies, so both '
        'switches are yours to press.',
    maxTurns: 18,
    maxClones: 2,
    map: '''
#############
####7#8######
####.#.######
#P......ABCE#
##.##########
##6##########
#############
''',
  ),
  Level.parse(
    id: 97,
    par: 2,
    titleTr: 'Kule',
    titleEn: 'The Tower',
    hintTr: 'Merdivenler tek yönlü: çıkan geri inemez. Her kat kendi '
        'plakasını basılı ister.',
    hintEn: 'The ladders only lead up, and each floor wants its own plate '
        'held down.',
    maxTurns: 15,
    maxClones: 2,
    map: '''
#########
######E##
######B##
######^##
#.2.....#
#A#######
#^#######
#..1P...#
#########
''',
  ),
  Level.parse(
    id: 98,
    par: 2,
    titleTr: 'Üç Ada',
    titleEn: 'Three Islands',
    hintTr: 'Işınlanma kapıları zinciri üç adayı bağlıyor; plakalar geride '
        'kalıyor.',
    hintEn: 'A chain of portals links the three islands, and the plates stay '
        'behind you.',
    maxTurns: 10,
    maxClones: 2,
    map: '''
#############
#.1.#.2.##E##
#...#...##A##
#.P.#.[.##B##
#.(.#.).#.].#
#...#...#...#
#############
''',
  ),
  Level.parse(
    id: 99,
    par: 2,
    titleTr: 'Geri Sayım',
    titleEn: 'Countdown',
    hintTr: 'Solan kapı dört tur sonra kapanır. Yankıların ilk adımda '
        'plakalarda olmalı.',
    hintEn: 'The fading gate shuts after four turns, so your echoes must be '
        'on the plates from their very first step.',
    maxTurns: 5,
    maxClones: 2,
    fadeTurns: 4,
    map: '''
#########
#..1#####
#..PABTE#
#..2#####
#########
''',
  ),
  Level.parse(
    id: 100,
    par: 2,
    titleTr: 'Döngü',
    titleEn: 'The Loop',
    hintTr: 'Son döngü. İki yankını ağır plakaya bırak, düğmeyi kendin '
        'çevir.',
    hintEn: 'The last loop: leave both echoes on the heavy plate and turn '
        'the switch yourself.',
    maxTurns: 7,
    maxClones: 2,
    map: '''
#######
#P.7###
#.#.###
#5.AB.#
###BEB#
###.B.#
#######
''',
  ),
];
