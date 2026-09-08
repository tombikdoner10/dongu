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
#########
#.1...2.#
#...P...#
#.3.....#
####.####
####A####
####B####
####C####
####E####
#########
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
    maxTurns: 12,
    maxClones: 2,
    timingSensitive: true,
    map: '''
###########
#P..~~~4..#
#########.#
#########A#
#########E#
###########
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
    maxTurns: 9,
    maxClones: 2,
    fadeTurns: 2,
    map: '''
###########
#.1.....2.#
#.......X.#
#....P....#
#####.#####
#####T#####
#####A#####
#####B#####
#####E#####
###########
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
    hintTr: 'Üç plaka, tam sekiz tur. Hiçbir yankı yolunu şaşıramaz.',
    hintEn: 'Three plates, exactly eight turns. No echo can wander.',
    maxTurns: 8,
    maxClones: 3,
    map: '''
###########
#.1.2.3...#
#....P....#
#####A#####
#####B#####
#####C#####
#####E#####
###########
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
###########
#....1....#
#....P....#
#####A#####
#....5....#
#####.#####
#####B#####
#####E#####
###########
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
#....1....#
#....P....#
#####A#####
#.2~~~....#
#####.#####
#####B#####
#####E#####
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
    maxTurns: 10,
    maxClones: 4,
    map: '''
###########
#....1....#
#....P....#
#####A#####
#....2....#
#####.#####
#####B#####
#....6....#
#####.#####
#####C#####
#####E#####
###########
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
    maxTurns: 14,
    maxClones: 3,
    timingSensitive: true,
    map: '''
#############
#P..~~~5..1.#
##########.##
##########A##
##########B##
##########E##
#############
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
    hintTr: 'İki ağır plaka üst üste. Alttakine inebilmek için üstteki '
        'dolu olmalı.',
    hintEn: 'Two heavy plates, one above the other. The lower one is out of '
        'reach until the upper is full.',
    maxTurns: 7,
    maxClones: 4,
    map: '''
###########
#....4....#
#....P....#
#####A#####
#....5....#
#####.#####
#####B#####
#####E#####
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
#.......#
#.P.7.AE#
#.......#
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
    maxTurns: 20,
    maxClones: 1,
    map: '''
#############
#.7.2...P>..#
#########.###
#########A###
#########B###
#########E###
#############
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
    maxTurns: 13,
    maxClones: 1,
    map: '''
#############
#.P...(.....#
#############
#.1....)..AE#
#############
''',
  ),
  Level.parse(
    id: 53,
    par: 0,
    titleTr: 'Zincirleme',
    titleEn: 'Chain Reaction',
    hintTr: 'Kay, ışınlan, düğmeye bas, oktan geç. Tek hamlede başlıyor.',
    hintEn: 'Slide, teleport, press, pass the arrow. It starts with one move.',
    maxTurns: 8,
    maxClones: 0,
    map: '''
#############
#.P***(.....#
#############
#.....)7.>AE#
#############
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
    maxTurns: 16,
    maxClones: 1,
    map: '''
###########
#....7...2#
#.........#
#...P.....#
#####A#####
#####B#####
#####E#####
###########
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
    maxTurns: 8,
    maxClones: 0,
    map: '''
###########
#.P****7..#
#########.#
#########A#
#########E#
###########
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
    maxTurns: 11,
    maxClones: 1,
    map: '''
#############
#.P..(......#
#############
#.1...)8.ABE#
#############
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
    maxTurns: 17,
    maxClones: 1,
    map: '''
###########
#.2.....7.#
#.........#
#....P....#
#####.#####
#####A#####
#####.#####
#####B#####
#####E#####
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
    maxTurns: 12,
    maxClones: 1,
    map: '''
###########
#P7~~~~2..#
#########.#
#########A#
#########B#
#########E#
###########
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
###########
#....1....#
#....P....#
#####A#####
#....8....#
#####.#####
#####B#####
#####E#####
###########
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
    maxTurns: 8,
    maxClones: 2,
    map: '''
###########
#....7....#
#....P....#
#####A#####
#....5....#
#####.#####
#####B#####
#####E#####
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
];
