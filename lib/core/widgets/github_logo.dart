import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';

/// Official GitHub "octocat" mark rendered from its SVG path.
///
/// Drawn with [CustomPainter] so no extra asset/dependency is required and it
/// stays crisp at any size. Path data is the canonical simple-icons GitHub
/// glyph (24×24 view-box).
class GitHubLogo extends StatelessWidget {
  const GitHubLogo({super.key, this.size = 16, this.color = AppColors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GitHubLogoPainter(color),
    );
  }
}

// Canonical GitHub mark (24×24 view-box).
const String _kGitHubPath =
    'M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 '
    '0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7'
    'c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998'
    '.108-.776.417-1.305.76-1.605-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221'
    '-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0 1 12 5.803'
    'c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176'
    '.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222 '
    '0 1.606-.014 2.898-.014 3.293 0 .322.216.694.825.576C20.565 22.092 24 17.592 24 12.297'
    'c0-6.627-5.373-12-12-12';

class _GitHubLogoPainter extends CustomPainter {
  _GitHubLogoPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _parseSvgPath(_kGitHubPath);
    final scale = size.width / 24.0;
    final scaled = path.transform(
      (Matrix4.identity()..scaleByDouble(scale, scale, 1, 1)).storage,
    );
    canvas.drawPath(
      scaled,
      Paint()
        ..color = color
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_GitHubLogoPainter old) => old.color != color;
}

/// Minimal SVG path-data parser → [Path].
///
/// Supports the command set used by typical icon glyphs: M/m L/l H/h V/v
/// C/c S/s Q/q T/t A/a Z/z. Arcs are delegated to [Path.arcToPoint], whose
/// flags map 1:1 onto the SVG large-arc / sweep flags.
Path _parseSvgPath(String d) {
  final tokens = _tokenize(d);
  final path = Path();

  int i = 0;
  double cx = 0, cy = 0; // current point
  double sx = 0, sy = 0; // current sub-path start
  double pcx = 0, pcy = 0; // previous cubic control point (for S/s)
  double pqx = 0, pqy = 0; // previous quad control point (for T/t)
  String cmd = '';

  double n() => tokens[i++] as double;

  while (i < tokens.length) {
    if (tokens[i] is String) {
      cmd = tokens[i] as String;
      i++;
    }

    switch (cmd) {
      case 'M':
        cx = n();
        cy = n();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        cmd = 'L';
      case 'm':
        cx += n();
        cy += n();
        path.moveTo(cx, cy);
        sx = cx;
        sy = cy;
        cmd = 'l';
      case 'L':
        cx = n();
        cy = n();
        path.lineTo(cx, cy);
      case 'l':
        cx += n();
        cy += n();
        path.lineTo(cx, cy);
      case 'H':
        cx = n();
        path.lineTo(cx, cy);
      case 'h':
        cx += n();
        path.lineTo(cx, cy);
      case 'V':
        cy = n();
        path.lineTo(cx, cy);
      case 'v':
        cy += n();
        path.lineTo(cx, cy);
      case 'C':
        final x1 = n(), y1 = n(), x2 = n(), y2 = n(), x = n(), y = n();
        path.cubicTo(x1, y1, x2, y2, x, y);
        pcx = x2;
        pcy = y2;
        cx = x;
        cy = y;
      case 'c':
        final x1 = cx + n(),
            y1 = cy + n(),
            x2 = cx + n(),
            y2 = cy + n(),
            x = cx + n(),
            y = cy + n();
        path.cubicTo(x1, y1, x2, y2, x, y);
        pcx = x2;
        pcy = y2;
        cx = x;
        cy = y;
      case 'S':
        final x1 = 2 * cx - pcx, y1 = 2 * cy - pcy;
        final x2 = n(), y2 = n(), x = n(), y = n();
        path.cubicTo(x1, y1, x2, y2, x, y);
        pcx = x2;
        pcy = y2;
        cx = x;
        cy = y;
      case 's':
        final x1 = 2 * cx - pcx, y1 = 2 * cy - pcy;
        final x2 = cx + n(), y2 = cy + n(), x = cx + n(), y = cy + n();
        path.cubicTo(x1, y1, x2, y2, x, y);
        pcx = x2;
        pcy = y2;
        cx = x;
        cy = y;
      case 'Q':
        final x1 = n(), y1 = n(), x = n(), y = n();
        path.quadraticBezierTo(x1, y1, x, y);
        pqx = x1;
        pqy = y1;
        cx = x;
        cy = y;
      case 'q':
        final x1 = cx + n(), y1 = cy + n(), x = cx + n(), y = cy + n();
        path.quadraticBezierTo(x1, y1, x, y);
        pqx = x1;
        pqy = y1;
        cx = x;
        cy = y;
      case 'T':
        final x1 = 2 * cx - pqx, y1 = 2 * cy - pqy;
        final x = n(), y = n();
        path.quadraticBezierTo(x1, y1, x, y);
        pqx = x1;
        pqy = y1;
        cx = x;
        cy = y;
      case 't':
        final x1 = 2 * cx - pqx, y1 = 2 * cy - pqy;
        final x = cx + n(), y = cy + n();
        path.quadraticBezierTo(x1, y1, x, y);
        pqx = x1;
        pqy = y1;
        cx = x;
        cy = y;
      case 'A':
        final rx = n(), ry = n(), rot = n(), large = n(), sweep = n();
        final x = n(), y = n();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rot,
          largeArc: large != 0,
          clockwise: sweep != 0,
        );
        cx = x;
        cy = y;
      case 'a':
        final rx = n(), ry = n(), rot = n(), large = n(), sweep = n();
        final x = cx + n(), y = cy + n();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rot,
          largeArc: large != 0,
          clockwise: sweep != 0,
        );
        cx = x;
        cy = y;
      case 'Z':
      case 'z':
        path.close();
        cx = sx;
        cy = sy;
      default:
        i++; // skip anything unexpected to avoid an infinite loop
    }
  }

  return path;
}

/// Splits SVG path data into command letters ([String]) and numbers ([double]).
List<Object> _tokenize(String d) {
  final tokens = <Object>[];
  final re = RegExp(
    r'([a-zA-Z])|([+-]?(?:\d*\.\d+|\d+\.?\d*)(?:[eE][+-]?\d+)?)',
  );
  for (final m in re.allMatches(d)) {
    final letter = m.group(1);
    if (letter != null) {
      tokens.add(letter);
    } else {
      tokens.add(double.parse(m.group(2)!));
    }
  }
  return tokens;
}
