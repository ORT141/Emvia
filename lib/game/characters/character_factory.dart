import '../emvia_types.dart';
import 'base_player.dart';
import 'olya/olya_player.dart';
import 'liam/liam_player.dart';

class CharacterFactory {
  static BasePlayer createPlayer(PlayableCharacter character) {
    if (character == PlayableCharacter.liam) return LiamPlayer();
    return OlyaPlayer();
  }
}
