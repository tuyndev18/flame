import 'dart:async';
import 'package:flame/cache.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/src/services/keyboard_key.g.dart';

enum PlayerState { jump }

enum MoveDirection { left, right, up, down }

main() {
  runApp(
    GameWidget(
      game: GameCtrl(),
    ),
  );
}

class GameCtrl extends FlameGame with HasKeyboardHandlerComponents {
  bool pause = false;
  late CameraComponent cam;
  @override
  FutureOr<void> onLoad() {
    Map lv1 = Map();
    cam = CameraComponent.withFixedResolution(
        world: lv1, width: 720, height: 400);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, lv1]);
    return super.onLoad();
  }
}

class Map extends World {
  final List<Block> _blockList = [];
  late Player _player;

  @override
  FutureOr<void> onLoad() async {
    TiledComponent map = await TiledComponent.load("lv1.tmx", Vector2.all(16));
    final spawnCharacter = map.tileMap.getLayer<ObjectGroup>("Spawn");
    if (spawnCharacter is ObjectGroup) {
      for (final spawn in spawnCharacter.objects) {
        switch (spawn.class_) {
          case "Player":
            _player = Player(position: Vector2(spawn.x, spawn.y));
            add(_player);
            break;
          case "Block":
            print(spawn.x);
            var block = Block()
              ..size = Vector2(spawn.width, spawn.height)
              ..position = Vector2(spawn.x, spawn.y);
            _blockList.add(block);
            add(block);
            break;
        }
      }
    }
    add(map);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _player.position.x += _player.velocity.x * _player.moveSpeed * dt;


    checkHorizontalCollision();
    _player.velocity.y += _player.gravity;
    _player.position.y += _player.velocity.y * dt;
    

    checkVerticalCollision();
    super.update(dt);
  }

  void checkHorizontalCollision() {
    for (var block in _blockList) {
      if (checkCollision(_player, block)) {
        if (_player.velocity.x > 0) {
          _player.velocity.x = 0;
          _player.position.x = block.position.x - _player.width;
          break;
        }
        if (_player.velocity.x < 0) {
          _player.velocity.x = 0;
          _player.position.x = block.position.x + _player.width + block.width;
          break;
        }
      }
    }
  }

  void checkVerticalCollision() {
    for (var block in _blockList) {
      if (checkCollision(_player, block)) {
        if (_player.velocity.y > 0) {
          _player.velocity.y = 0;
          _player.position.y = block.position.y - _player.height;
          break;
        }
      }
    }
  }

  bool checkCollision(player, block) {
    double bw = block.width;
    double bh = block.height;
    double bx = block.position.x;
    double by = block.position.y;

    double pw = player.width;
    double ph = player.height;
    double psx = player.scale.x;
    double px = psx > 0 ? player.position.x : player.position.x - pw;
    double py = player.position.y;
    return px + pw > bx && px < bx + bw && py + ph > by && py < by + bh;
  }
}

class Block extends PositionComponent {
  @override
  FutureOr<void> onLoad() {
    priority = 2;
    debugMode = true;
    return super.onLoad();
  }
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<GameCtrl>, KeyboardHandler {
  late final SpriteAnimation jumpCharacter;
  MoveDirection moveDirection = MoveDirection.right;
  bool isFlipHorizontal = false;
  double moveSpeed = 100;
  final int gravity = 10;
  Vector2 velocity = Vector2.zero();

  Player({required position}) : super(position: position);

  @override
  FutureOr<void> onLoad() async {
    priority = 1;
    debugMode = true;
    jumpCharacter = SpriteAnimation.fromFrameData(
        await Flame.images.load("Main Characters/Virtual Guy/Run (32x32).png"),
        SpriteAnimationData.sequenced(
            amount: 11, stepTime: 0.05, textureSize: Vector2.all(32)));
    animations = {PlayerState.jump: jumpCharacter};
    current = PlayerState.jump;
    return super.onLoad();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      velocity.x = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      velocity.x = 1;
    } else {
      velocity.x = 0;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    // applyGravity(dt);
    updateMovement();
    super.update(dt);
  }

  void applyGravity(dt) {
    velocity.y += 0.5 * gravity;
    position.y += velocity.y * dt;
  }

  void updateMovement() {
    if (velocity.x < 0 && !isFlipHorizontal) {
      flipHorizontallyAroundCenter();
      isFlipHorizontal = true;
    }
    if (velocity.x > 0 && isFlipHorizontal) {
      flipHorizontallyAroundCenter();
      isFlipHorizontal = false;
    }
  }
}
