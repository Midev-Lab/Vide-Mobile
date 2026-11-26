class ChatQuota {
  const ChatQuota({this.remaining, this.limit, this.resetsAt});

  final int? remaining;
  final int? limit;
  final DateTime? resetsAt;
}
