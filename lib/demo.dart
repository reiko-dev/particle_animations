import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vignettes_animations/particles/particle_field.dart';
import 'package:vignettes_animations/particles/particle_field_painter.dart';
import 'package:vignettes_animations/particles/sprite_sheet.dart';

class ParticleSwipeDemo extends StatefulWidget {
  const ParticleSwipeDemo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ParticleSwipeDemoState();
  }
}

class ParticleSwipeDemoState extends State<ParticleSwipeDemo>
    with SingleTickerProviderStateMixin {
  late final SpriteSheet _spriteSheet;
  static late final ParticleField particleField;
  late final Ticker _ticker;

  final GlobalKey globalKey2 = GlobalKey();

  @override
  void initState() {
    // Create the "circle" sprite sheet for the particles:
    _spriteSheet = SpriteSheet(
      imageProvider: const AssetImage("images/circle_spritesheet.png"),
      length: 15, // number of frames in the sprite sheet.
      frameWidth: 10,
      frameHeight: 10,
    );

    particleField = ParticleField();
    _ticker = createTicker(particleField.tick)..start();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: <Widget>[
        //
        Positioned(
          top: size.height * .1,
          width: size.width * .3,
          height: size.height * .1,
          child: const DemoItem(),
        ),

        Positioned(
          top: size.height * .3,
          width: size.width * .25,
          height: size.height * .1,
          child: const DemoItem(color: Colors.blue),
        ),

        Positioned(
          top: size.height * .5,
          width: size.width * .8,
          height: size.height * .1,
          child: const DemoItem(color: Colors.green),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                willChange: true,
                painter: ParticleFieldPainter(
                    field: particleField, spriteSheet: _spriteSheet),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DemoItem extends StatefulWidget {
  const DemoItem({Key? key, this.color = Colors.red}) : super(key: key);
  final Color color;

  @override
  State<DemoItem> createState() => _DemoItemState();
}

class _DemoItemState extends State<DemoItem> {
  final GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void runAnimation(BuildContext context) {
    ParticleSwipeDemoState.particleField.runParticleAnimation(
      context: context,
      key: key,
      type: ParticleAnimationType.rectanglePerimeter,
      color: widget.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (key.currentContext == null) {
          WidgetsBinding.instance?.addPostFrameCallback((d) {
            runAnimation(context);
          });
        } else {
          runAnimation(context);
        }
      },
      child: Container(key: key, width: 50, height: 50, color: widget.color),
    );
  }
}
