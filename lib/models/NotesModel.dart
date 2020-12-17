class Note {
  String id;
  String title;
  String content;
  DateTime date;
  String color;
  String searchKey;

  Note(
      {this.id,
      this.title,
      this.content,
      this.date,
      this.color,
      this.searchKey});

  Note.fromDocumentSnapshot(var doc) {
    id = doc['id'].toString();
    title = doc["title"];
    date = doc["date"];
    content = doc["content"];
    color = doc["color"];
    searchKey = doc["searchKey"];
  }
}
