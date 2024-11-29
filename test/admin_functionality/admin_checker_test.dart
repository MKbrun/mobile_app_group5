import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:mobile_app_group5/backend/admin/admin_checker.dart';
import 'admin_checker_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
  });

  test('AdminChecker should fetch the correct admin list from Firestore', () async {
    // Arrange
    when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('adminList')).thenReturn(mockDocumentReference);
    when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);

    // Mock the data in the snapshot
    when(mockDocumentSnapshot.data()).thenReturn({
      'admins': ['admin1', 'admin2', 'admin3']
    });
    print('Mocked data: ${mockDocumentSnapshot.data()}');

    // Create the AdminChecker instance with the mock Firestore
    AdminChecker adminChecker = AdminChecker(firestore: mockFirestore);

    // Act
    List<String> admins = await adminChecker.getAdminList();

    // Assert
    expect(admins, ['admin1', 'admin2', 'admin3']);
  });

  test('isAdmin should return true if the user is an admin', () async {
  // Arrange
  when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
  when(mockCollectionReference.doc('adminList')).thenReturn(mockDocumentReference);
  when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);

  // Stub the data in the snapshot
  when(mockDocumentSnapshot.data()).thenReturn({
    'admins': ['admin1', 'admin2', 'admin3'],
  });

  // Create the AdminChecker instance with the mock Firestore
  AdminChecker adminChecker = AdminChecker(firestore: mockFirestore);

  // Act
  bool result = await adminChecker.isAdmin('admin1');

  // Assert
  expect(result, true);
});

test('isAdmin should return false if the user is not an admin', () async {
  // Arrange
  when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
  when(mockCollectionReference.doc('adminList')).thenReturn(mockDocumentReference);
  when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);

  // Stub the data in the snapshot
  when(mockDocumentSnapshot.data()).thenReturn({
    'admins': ['admin1', 'admin2', 'admin3'],
  });

  // Create the AdminChecker instance with the mock Firestore
  AdminChecker adminChecker = AdminChecker(firestore: mockFirestore);

  // Act
  bool result = await adminChecker.isAdmin('nonAdminUser');

  // Assert
  expect(result, false);
});

test('isAdmin should handle an empty admin list gracefully', () async {
  // Arrange
  when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
  when(mockCollectionReference.doc('adminList')).thenReturn(mockDocumentReference);
  when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);

  // Stub the data in the snapshot
  when(mockDocumentSnapshot.data()).thenReturn({
    'admins': [],
  });

  // Create the AdminChecker instance with the mock Firestore
  AdminChecker adminChecker = AdminChecker(firestore: mockFirestore);

  // Act
  bool result = await adminChecker.isAdmin('admin1');

  // Assert
  expect(result, false);
});
}
