import 'package:get/get.dart';
import 'package:notes/models/NotesModel.dart';

class UpdateNoteController extends GetxController {
  var isUpdate = false.obs;
  Rx<Note> _updateNoteModel = Note().obs;

  Note get upateNoteModel => _updateNoteModel.value;

  set upateNoteModel(Note value) => this._updateNoteModel.value = value;
}
