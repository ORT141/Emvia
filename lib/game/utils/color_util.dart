import 'package:emvia/game/utils/survey_service.dart';
import 'package:flame/rendering.dart';

class ColorUtil {
  static void applySurveyColor(Decorator decorator, SurveyProfile profile) {
    final color = profile.safeColorValue;
    decorator.addLast(PaintDecorator.tint(color));
  }

  static void colorWalls(Decorator decorator, SurveyProfile profile) {
    applySurveyColor(decorator, profile);
  }
}
