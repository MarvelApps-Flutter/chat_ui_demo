import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel
{
  DateTime? time;
  String? message;
  String? type;
  String? sendBy;
  String? sendto;
  bool? isRead;
  int? count;
  String? roomId;
  ChatModel({this.time, this.message, this.type, this.sendBy,this.sendto,this.isRead,this.count,this.roomId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatModel &&
              runtimeType == other.runtimeType &&
              time == other.time;

  @override
  int get hashCode => time.hashCode;
}