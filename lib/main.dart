import 'dart:async';
import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_spine/flame_spine.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/src/services/keyboard_key.g.dart';

enum PlayerState { running, jump }

enum MoveDirection { left, right, up, down }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSpineFlutter();
  runApp(GameWidget(game: FlameSpineExample()));
}

class FlameSpineExample extends FlameGame with TapDetector, KeyboardEvents {
 late final SpineComponent spineboy;

 @override
 Future<void> onLoad() async {
  await initSpineFlutter();
  // Load the Spineboy atlas and skeleton data from asset files
  // and create a SpineComponent from them, scaled down and
  // centered on the screen
  spineboy = await SpineComponent.fromAssets(
   atlasFile: 'assets/images/spineboy.atlas',
   skeletonFile: 'assets/images/spineboy-pro.json',
   scale: Vector2(0.4, 0.4),
   anchor: Anchor.center,
   position: size / 2,
  );

  // Set the "walk" animation on track 0 in looping mode
  spineboy.animationState.setAnimationByName(0, 'run-to-idle', true);
  await add(spineboy);
 }

@override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if(keysPressed.contains(LogicalKeyboardKey.keyA)) {
        spineboy.animationState.setAnimationByName(0, 'jump', true);
    }
    if(keysPressed.contains(LogicalKeyboardKey.keyW)) {
        spineboy.animationState.setAnimationByName(0, 'shoot', true);
    }
    if(keysPressed.contains(LogicalKeyboardKey.keyS)) {
        spineboy.animationState.setAnimationByName(0, 'run', true);
    }
    if(keysPressed.contains(LogicalKeyboardKey.keyD)) {
        spineboy.animationState.setAnimationByName(0, 'walk', true);
    }
    // TODO: implement onKeyEvent
    return super.onKeyEvent(event, keysPressed);
  }

 @override
 void onDetach() {
  // Dispose the native resources that have been loaded for spineboy.
  spineboy.dispose();
 }
}