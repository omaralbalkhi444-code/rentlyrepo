import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:p2/fake_uid.dart';
import 'package:p2/logic/chat_logic.dart';


class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

@GenerateMocks([DatabaseReference, DatabaseEvent, DataSnapshot])
void main() {
  late MockDatabaseReference mockDbRef;
  late ChatLogic chatLogic;
  
  setUp(() {
    mockDbRef = MockDatabaseReference();
    chatLogic = ChatLogic(
      personName: "Test User",
      personUid: "testUid123",
    );
    
    LoginUID.uid = "currentUser123";
  });

  test('ChatLogic constructor initializes chatId correctly', () {
    expect(chatLogic.chatId, "currentUser123-testUid123");
    
    LoginUID.uid = "aaa";
    final logic2 = ChatLogic(personName: "Test", personUid: "bbb");
    expect(logic2.chatId, "aaa-bbb");
  });

  test('canEditOrDelete returns false for non-sender messages', () {
    final msg = {
      "sender": "otherUser",
      "timestamp": DateTime.now().millisecondsSinceEpoch - 5000
    };
    
    expect(chatLogic.canEditOrDelete(msg), false);
  });

  test('canEditOrDelete returns true for sender messages within 10 minutes', () {
    final msg = {
      "sender": "currentUser123",
      "timestamp": DateTime.now().millisecondsSinceEpoch - 5 * 60 * 1000
    };
    
    expect(chatLogic.canEditOrDelete(msg), true);
  });

  test('canEditOrDelete returns false for sender messages after 10 minutes', () {
    final msg = {
      "sender": "currentUser123",
      "timestamp": DateTime.now().millisecondsSinceEpoch - 11 * 60 * 1000
    };
    
    expect(chatLogic.canEditOrDelete(msg), false);
  });

  test('formatTime formats correctly', () {
    final timestamp = DateTime(2024, 1, 1, 14, 30).millisecondsSinceEpoch;
    expect(chatLogic.formatTime(timestamp), "2:30 PM");
    
    final timestamp2 = DateTime(2024, 1, 1, 9, 5).millisecondsSinceEpoch;
    expect(chatLogic.formatTime(timestamp2), "9:05 AM");
  });

  test('messageDateLabel returns correct labels', () {
    final now = DateTime.now();
    final todayTimestamp = now.millisecondsSinceEpoch;
    final yesterdayTimestamp = now.subtract(Duration(days: 1)).millisecondsSinceEpoch;
    final oldTimestamp = DateTime(2023, 1, 1).millisecondsSinceEpoch;
    
    expect(chatLogic.messageDateLabel(todayTimestamp), "Today");
    expect(chatLogic.messageDateLabel(yesterdayTimestamp), "Yesterday");
    expect(chatLogic.messageDateLabel(oldTimestamp), "2023/1/1");
  });

  test('setReplyMessage and clearReplyMessage work correctly', () {
    final testMsg = {"text": "Test message", "sender": "user1"};
    
    chatLogic.setReplyMessage(testMsg);
    expect(chatLogic.replyMessage, testMsg);
    
    chatLogic.clearReplyMessage();
    expect(chatLogic.replyMessage, isNull);
  });

  test('setSelectedMessageKey works correctly', () {
    chatLogic.setSelectedMessageKey("testKey123");
    expect(chatLogic.selectedMessageKey, "testKey123");
    
    chatLogic.setSelectedMessageKey(null);
    expect(chatLogic.selectedMessageKey, isNull);
  });
}
