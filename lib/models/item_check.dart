class ItemCheck {
  final int? id;
  final String content;
  bool isDone;

  ItemCheck({
    this.id,
    required this.content,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isDone': isDone ?  1 : 0,
    };
  }

  factory ItemCheck.fromJson(Map<String, dynamic> json) {
    return ItemCheck(
      id: json['id'],
      content: json['content'],
      isDone: json['isDone'] == 1,
    );
  }
}