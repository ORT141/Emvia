import '../emvia_types.dart';
import 'base_player.dart';
import 'olya/olya_player.dart';
import 'liam/liam_player.dart';

class CharacterFactory {
  static BasePlayer createPlayer(PlayableCharacter character) {
    switch (character) {
      case PlayableCharacter.olya:
        return OlyaPlayer();
      case PlayableCharacter.liam:
        return LiamPlayer();
      default:
        return OlyaPlayer();
    }
  }
}
