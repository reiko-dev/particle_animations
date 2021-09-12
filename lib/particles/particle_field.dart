import 'dart:math';

import 'package:flutter/material.dart';

import 'particle.dart';

enum ParticleAnimationType { line, point, rectanglePerimeter }

//
//Animated particle effects. Note that this just manages the data, ParticleFieldPainter renders the effect.
class ParticleField with ChangeNotifier {
  List<Particle> particles = [];
  int lastT = 0;

  ParticleField();

  void runParticleAnimation({
    required GlobalKey key,
    ParticleAnimationType type = ParticleAnimationType.rectanglePerimeter,
    required BuildContext context,
    Color color = Colors.red,
  }) {
    //
    // Get item's render box, and use it to calculate the position for the particle effect:
    final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;

    double height = Scaffold.of(context).appBarMaxHeight ?? 0;

    Offset offset = box.localToGlobal(Offset(0, -height));

    final bounds = offset & box.size;

    // Delay the start of the effect a little bit, so the item is mostly closed before it begins.
    Future.delayed(const Duration(milliseconds: 100)).then((_) {
      perimeterExplosion(
        bounds,
        color: color,
      );
    });
  }

  // Creates the "delete" effect: red particles exploding from a horizontal line
  void lineExplosion(x, y, w, [count = 150]) {
    for (int i = 0; i < count; i++) {
      particles.add(Particle(
          x: x + i / count * w, // evenly spaced along the line
          y: y,
          vx: Random().nextDouble() * 5.0 - 5.0,
          vy: Random().nextDouble() * 3.0 - 2.5,
          life: Random().nextDouble() * 0.5 + 0.5,
          color: const Color(0xffcb4a65).withOpacity(i.isEven ? 0.8 : 0.3)));
    }
  }

  // Creates the "favorite" effect: blue particles exploding out from a central point (like a firework)
  void pointExplosion(double x, double y, [count = 55]) {
    for (int i = 0; i < count; i++) {
      double rot = i / count * pi * 2; // angle to apply velocity
      double vel = Random().nextDouble() * 2 + .5;
      particles.add(Particle(
          x: x + 18 * cos(rot),
          y: y + 18 * sin(rot),
          vx: cos(rot) * vel,
          vy: sin(rot) * vel,
          life: Random().nextDouble() * 0.5 + 0.5,
          color: const Color(0xff54d8e6).withOpacity(i.isEven ? 0.8 : 0.3)));
    }
  }

  // Creates the rectangle perimeter explosion
  void perimeterExplosion(
    Rect bounds, {
    Color color = const Color(0xff54d8e6),
    int count = 55,
  }) {
    final width = bounds.width;
    final height = bounds.height;

    if (!count.isEven) count++;

    double perimeter = 2 * width + 2 * height;
    double distanceBetweenPoints = perimeter / count;

    final List<Offset> points = [];

    //Adds horizontal particles.
    for (var i = 0; i < (width / distanceBetweenPoints); i++) {
      double x1 = bounds.left + distanceBetweenPoints * i;

      points.add(Offset(x1, bounds.top));

      double x2 = bounds.left + width - distanceBetweenPoints * i;

      points.add(Offset(x2, bounds.bottom));
    }

    //Adds vertical particles.
    for (var i = 0; i < (height / distanceBetweenPoints); i++) {
      double y1 = bounds.top + distanceBetweenPoints * i;

      points.add(Offset(bounds.left, y1));

      double y2 = bounds.bottom - distanceBetweenPoints * i;

      points.add(Offset(bounds.right, y2));
    }

    points.shuffle();

    for (int i = 0; i < points.length; i++) {
      double vel = Random().nextDouble() * .5 + .5;

      final rand = Random().nextDouble() * .5 + .5;

      final point = points[i];

      particles.add(
        Particle(
          x: point.dx,
          y: point.dy,
          vx: i.isEven ? vel : -vel,
          vy: 1.4 * -vel,
          life: rand + 0.3,
          color: color.withOpacity(.3 + (rand - .5)),
        ),
      );
    }
  }

  // Called each tick by the parent & updates all the particles
  void tick(Duration duration) {
    // Calculate how much time has ellapsed since the last tick, and calculate a multiplier from that.
    double t = min(1.5, (duration.inMilliseconds - lastT) / 1000 * 60);
    lastT = duration.inMilliseconds;

    int l = particles.length;
    for (int i = l - 1; i >= 0; i--) {
      // Update each particle's properties.
      Particle o = particles[i];
      o.vy += 0.05 * t; // "gravity"
      o.x += o.vx * t;
      o.y += o.vy * t;
      o.hue = (o.hue + o.vhue) % 360;

      o.life -= 0.01 * t;
      if (o.life <= 0.0) {
        particles.removeAt(i);
      }
    }

    // If we started this tick with particles, then notify the ParticleFieldPainter that it needs to re-paint.
    if (l > 0) {
      notifyListeners();
    }
  }
}
