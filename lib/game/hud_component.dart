import 'package:flame/components.dart';

/// HudComponent for Flame game HUD, accepts children components.
class HudComponent extends PositionComponent {
  HudComponent({Iterable<Component>? children}) : super(children: children);
}
