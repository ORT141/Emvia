import 'dialog_model.dart';

class DialogData {
  static DialogTree getTeacherDialog() {
    return DialogTree(
      startNodeId: 'start',
      nodes: {
        'start': DialogNode(
          id: 'start',
          speakerName: (l) => l.speaker_teacher,
          text: (l) => l.dialog_teacher_start,
          choices: [
            DialogChoice(
              label: (l) => l.dialog_teacher_choice_yes,
              nextNodeId: 'ready',
            ),
            DialogChoice(
              label: (l) => l.dialog_teacher_choice_not_really,
              nextNodeId: 'not_ready',
            ),
          ],
        ),
        'ready': DialogNode(
          id: 'ready',
          speakerName: (l) => l.speaker_teacher,
          text: (l) => l.dialog_teacher_ready,
          nextNodeId: 'end',
        ),
        'not_ready': DialogNode(
          id: 'not_ready',
          speakerName: (l) => l.speaker_teacher,
          text: (l) => l.dialog_teacher_not_ready,
        ),
        'end': DialogNode(
          id: 'end',
          speakerName: (l) => l.speaker_teacher,
          text: (l) => l.dialog_teacher_end,
          choices: [
            DialogChoice(
              label: (l) => l.dialog_teacher_choice_no_lets_go,
              nextNodeId: null,
            ),
            DialogChoice(
              label: (l) => l.dialog_teacher_choice_what_book,
              nextNodeId: 'what_book',
            ),
          ],
        ),
        'what_book': DialogNode(
          id: 'what_book',
          speakerName: (l) => l.speaker_teacher,
          text: (l) => l.dialog_teacher_what_book,
        ),
      },
    );
  }

  static DialogTree getMysteriousStrangerDialog() {
    return DialogTree(
      startNodeId: 'entry',
      nodes: {
        'entry': DialogNode(
          id: 'entry',
          speakerName: (l) => l.speaker_stranger,
          text: (l) => l.dialog_stranger_entry,
          choices: [
            DialogChoice(
              label: (l) => l.dialog_stranger_choice_i_am,
              nextNodeId: 'from_out',
            ),
            DialogChoice(
              label: (l) => l.dialog_stranger_choice_mind_your_business,
              nextNodeId: 'rude',
            ),
          ],
        ),
        'from_out': DialogNode(
          id: 'from_out',
          speakerName: (l) => l.speaker_stranger,
          text: (l) => l.dialog_stranger_from_out,
        ),
        'rude': DialogNode(
          id: 'rude',
          speakerName: (l) => l.speaker_stranger,
          text: (l) => l.dialog_stranger_rude,
        ),
      },
    );
  }
}
