import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile_app_group5/backend/channel_backend/channel_logic.dart';
import 'channel_logic_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockChannelCollectionReference),
  MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockMessagesCollectionReference),
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockChannelCollectionReference mockChannelsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockChannelDocument;
  late MockMessagesCollectionReference mockMessagesCollection;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockChannelsCollection = MockChannelCollectionReference();
    mockChannelDocument = MockDocumentReference<Map<String, dynamic>>();
    mockMessagesCollection = MockMessagesCollectionReference();
  });

  test('ChannelLogic should create a channel and initialize the messages subcollection', () async {
    // Arrange
    when(mockFirestore.collection('channels')).thenReturn(mockChannelsCollection);
    when(mockChannelsCollection.add(any))
        .thenAnswer((_) async => mockChannelDocument);
    when(mockChannelDocument.collection('messages')).thenReturn(mockMessagesCollection);
    when(mockMessagesCollection.add(any)).thenAnswer((_) async => mockChannelDocument);

    final channelLogic = ChannelLogic(firestore: mockFirestore);

    // Act
    await channelLogic.createChannel(
      name: 'Team Updates',
      description: 'Daily standups',
      members: ['user1', 'user2'],
    );

    // Assert
    verify(mockFirestore.collection('channels')).called(1);
    verify(mockChannelsCollection.add(argThat(
      predicate<Map<String, dynamic>>((channel) {
        final members = channel['members'] as List<String>;
        return channel['name'] == 'Team Updates' &&
            channel['description'] == 'Daily standups' &&
            ['user1', 'user2'].every((member) => members.contains(member));
      }),
    ))).called(1);

    verify(mockChannelDocument.collection('messages')).called(1);
    verify(mockMessagesCollection.add(argThat(
      predicate<Map<String, dynamic>>((message) =>
          message['content'] == 'Welcome to the channel!' &&
          message['createdBy'] == 'system' &&
          message.containsKey('createdAt')),
    ))).called(1);
  });
}
