import 'package:flutter/material.dart';

/// 16x16 pixel-art icons drawn from character bitmaps (original artwork).
///
/// Palette: `.` transparent, `k` black, `w` white, `g` light grey,
/// `d` dark grey, `y` yellow, `o` dark yellow, `b` blue, `n` navy,
/// `c` cyan, `r` red, `G` green, `m` magenta, `s` brown.
class PixelIcon extends StatelessWidget {
  const PixelIcon(this.bitmap, {super.key, this.size = 16, this.semanticLabel});

  final List<String> bitmap;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _PixelPainter(bitmap)),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: icon);
    return Semantics(label: semanticLabel, image: true, child: icon);
  }
}

class _PixelPainter extends CustomPainter {
  _PixelPainter(this.bitmap);
  final List<String> bitmap;

  static const _palette = <String, Color>{
    'k': Color(0xFF000000),
    'w': Color(0xFFFFFFFF),
    'g': Color(0xFFC3C3C3),
    'd': Color(0xFF7B7B7B),
    'y': Color(0xFFFFE34D),
    'o': Color(0xFFC9A100),
    'b': Color(0xFF2A6BD6),
    'n': Color(0xFF0A1F7A),
    'c': Color(0xFF5FD3E6),
    'r': Color(0xFFD62020),
    'G': Color(0xFF1FA34A),
    'm': Color(0xFFE0007A),
    's': Color(0xFF8B5A2B),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final rows = bitmap.length;
    final px = size.width / 16;
    final py = size.height / (rows == 0 ? 16 : rows);
    final paint = Paint()..isAntiAlias = false;
    for (var y = 0; y < rows; y++) {
      final row = bitmap[y];
      for (var x = 0; x < row.length && x < 16; x++) {
        final color = _palette[row[x]];
        if (color == null) continue;
        paint.color = color;
        canvas.drawRect(
          Rect.fromLTWH(x * px, y * py, px + 0.3, py + 0.3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PixelPainter old) => old.bitmap != bitmap;
}

/// Original icon set.
class PixelIcons {
  PixelIcons._();

  static const computer = [
    '................',
    '.kkkkkkkkkkkkkk.',
    '.kggggggggggggk.',
    '.kgkkkkkkkkkkgk.',
    '.kgkccccccccdgk.',
    '.kgkcwwcccccdgk.',
    '.kgkcwcccccccgk.',
    '.kgkccccccccdgk.',
    '.kgkkkkkkkkkkgk.',
    '.kggggggggggGgk.',
    '.kkkkkkkkkkkkkk.',
    '......kggk......',
    '....kkkkkkkk....',
    '...kggggggggk...',
    '...kkkkkkkkkk...',
    '................',
  ];

  static const folder = [
    '................',
    '................',
    '................',
    '.kkkkk..........',
    'kyyyyyk.........',
    'kywwwwykkkkkkk..',
    'kwyyyyyyyyyyyyk.',
    'kwyyyyyyyyyyyyk.',
    'kwyyyyyyyyyyyyk.',
    'kwyyyyyyyyyyyyk.',
    'kwyyyyyyyyyyyyk.',
    'kwyyyyyyyyyyyyk.',
    'kwyyyyyyyyyyyyk.',
    'kooooooooooooook',
    '.kkkkkkkkkkkkkk.',
    '................',
  ];

  static const warning = [
    '.......kk.......',
    '......kyyk......',
    '......kyyk......',
    '.....kyyyyk.....',
    '.....kykkyk.....',
    '....kyykkyyk....',
    '....kyykkyyk....',
    '...kyyykkyyyk...',
    '...kyyykkyyyk...',
    '..kyyyykkyyyyk..',
    '..kyyyyyyyyyyk..',
    '.kyyyyykkyyyyyk.',
    '.kyyyyykkyyyyyk.',
    'kyyyyyyyyyyyyyyk',
    'kkkkkkkkkkkkkkkk',
    '................',
  ];

  static const error = [
    '.....kkkkkk.....',
    '...kkrrrrrrkk...',
    '..krrrrrrrrrrk..',
    '.krrwrrrrrrwrrk.',
    '.krwwwrrrrwwwrk.',
    'krrrwwwrrwwwrrrk',
    'krrrrwwwwwwrrrrk',
    'krrrrrwwwwrrrrrk',
    'krrrrrwwwwrrrrrk',
    'krrrrwwwwwwrrrrk',
    'krrrwwwrrwwwrrrk',
    '.krwwwrrrrwwwrk.',
    '.krrwrrrrrrwrrk.',
    '..krrrrrrrrrrk..',
    '...kkrrrrrrkk...',
    '.....kkkkkk.....',
  ];

  static const question = [
    '.....kkkkkk.....',
    '...kkbbbbbbkk...',
    '..kbbbbbbbbbbk..',
    '.kbbbbwwwwbbbbk.',
    '.kbbbwwbbwwbbbk.',
    'kbbbbwwbbwwbbbbk',
    'kbbbbbbbbwwbbbbk',
    'kbbbbbbbwwbbbbbk',
    'kbbbbbbwwbbbbbbk',
    'kbbbbbbwwbbbbbbk',
    'kbbbbbbbbbbbbbbk',
    '.kbbbbbwwbbbbbk.',
    '.kbbbbbwwbbbbbk.',
    '..kbbbbbbbbbbk..',
    '...kkbbbbbbkk...',
    '.....kkkkkk.....',
  ];

  static const info = [
    '.....kkkkkk.....',
    '...kkbbbbbbkk...',
    '..kbbbbbbbbbbk..',
    '.kbbbbbwwbbbbbk.',
    '.kbbbbbwwbbbbbk.',
    'kbbbbbbbbbbbbbbk',
    'kbbbbbwwwbbbbbbk',
    'kbbbbbbwwbbbbbbk',
    'kbbbbbbwwbbbbbbk',
    'kbbbbbbwwbbbbbbk',
    'kbbbbbbwwbbbbbbk',
    '.kbbbbwwwwbbbbk.',
    '.kbbbbbbbbbbbbk.',
    '..kbbbbbbbbbbk..',
    '...kkbbbbbbkk...',
    '.....kkkkkk.....',
  ];

  static const key = [
    '................',
    '................',
    '..kkkkk.........',
    '.kyyyyyk........',
    'kyykkkyyk.......',
    'kykdddkyk.......',
    'kykdddkykkkkkkk.',
    'kyykkkyyyyyyyyyk',
    '.kyyyyyokkokyokk',
    '..kkkkk..k.kk.k.',
    '................',
    '................',
    '................',
    '................',
    '................',
    '................',
  ];

  static const trash = [
    '................',
    '......kkkk......',
    '..kkkkkddkkkkk..',
    '..kwwwwwwwwwwk..',
    '..kkkkkkkkkkkk..',
    '...kwgwgwgwgk...',
    '...kwgwgwgwgk...',
    '...kwgwgwgwgk...',
    '...kwgwgwgwgk...',
    '...kwgwgwgwgk...',
    '...kwgwgwgwgk...',
    '...kwgwgwgwgk...',
    '...kwgwgwgwgk...',
    '....kkkkkkkk....',
    '................',
    '................',
  ];

  static const disk = [
    'kkkkkkkkkkkkkkk.',
    'knnwwwwwwwwwnnk.',
    'knnwwwwwwwwwnnk.',
    'knnwddddddwwnnk.',
    'knnwwwwwwwwwnnk.',
    'knnnnnnnnnnnnnk.',
    'knnnnnnnnnnnnnk.',
    'knnnggggggggnnk.',
    'knnnggkkggggnnk.',
    'knnnggkkggggnnk.',
    'knnnggkkggggnnk.',
    'knnnggggggggnnk.',
    'kkkkkkkkkkkkkkk.',
    '................',
    '................',
    '................',
  ];

  static const hourglass = [
    '..kkkkkkkkkkk...',
    '..kgggggggggk...',
    '...kwwwwwwwk....',
    '...kwyyyyywk....',
    '....kwyyywk.....',
    '.....kwywk......',
    '......kyk.......',
    '......kwk.......',
    '.....kwwwk......',
    '....kwwywwk.....',
    '...kwwyyywwk....',
    '...kwyyyyywk....',
    '..kgggggggggk...',
    '..kkkkkkkkkkk...',
    '................',
    '................',
  ];

  static const picture = [
    'kkkkkkkkkkkkkkkk',
    'kwwwwwwwwwwwwwwk',
    'kwccccccccccccwk',
    'kwccccccccyyccwk',
    'kwccccccccyyccwk',
    'kwccccccccccccwk',
    'kwcccGccccccccwk',
    'kwccGGGcccGcccwk',
    'kwcGGGGGcGGGccwk',
    'kwGGGGGGGGGGGGwk',
    'kwGGGGGGGGGGGGwk',
    'kwwwwwwwwwwwwwwk',
    'kkkkkkkkkkkkkkkk',
    '................',
    '................',
    '................',
  ];

  static const pencil = [
    '...........kk...',
    '..........kmmk..',
    '.........kkmmk..',
    '........kyykk...',
    '.......kyyyk....',
    '......kyyyk.....',
    '.....kyyyk......',
    '....kyyyk.......',
    '...kyyyk........',
    '..kwyyk.........',
    '..kwwk..........',
    '..kkk...........',
    '................',
    '................',
    '................',
    '................',
  ];

  static const star = [
    '.......kk.......',
    '.......yk.......',
    '......kyyk......',
    '......kyyk......',
    'kkkkkkkyyykkkkkk',
    '.kyyyyyyyyyyyyk.',
    '..kyyyyyyyyyyk..',
    '...kyyyyyyyyk...',
    '....kyyyyyyk....',
    '....kyyyyyyk....',
    '...kyyykkyyyk...',
    '...kyyk..kyyk...',
    '..kyk......kyk..',
    '..kk........kk..',
    '................',
    '................',
  ];

  static const document = [
    '..kkkkkkkkk.....',
    '..kwwwwwwwkk....',
    '..kwwwwwwwkwk...',
    '..kwkkkkwwkkkk..',
    '..kwwwwwwwwwwk..',
    '..kwkkkkkkkwwk..',
    '..kwwwwwwwwwwk..',
    '..kwkkkkkkkwwk..',
    '..kwwwwwwwwwwk..',
    '..kwkkkkkkkwwk..',
    '..kwwwwwwwwwwk..',
    '..kwkkkkkwwwwk..',
    '..kwwwwwwwwwwk..',
    '..kkkkkkkkkkkk..',
    '................',
    '................',
  ];
}
