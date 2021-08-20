import 'package:brew_crew/models/brew.dart';
import 'package:brew_crew/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSevice {
  final String uid;
  DatabaseSevice({this.uid: ''});

  // collection reference
  final CollectionReference brewCollection =
      FirebaseFirestore.instance.collection('brews');

  Future updateUserData(String sugars, String name, int strength) async {
    return await brewCollection
        .doc(uid)
        .set({'sugars': sugars, 'name': name, 'strength': strength});
  }

  List<Brew> _brewListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map data = doc.data() as Map;
      return Brew(
          name: data["name"] ?? '',
          strength: data["strength"] ?? 0,
          sugars: data["sugars"] ?? '');
    }).toList();
  }

  //get brews stream
  Stream<List<Brew>> get brews {
    return brewCollection.snapshots().map(_brewListFromSnapshot);
  }

  // get user doc stream

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map;
    return UserData(uid: uid, sugars: data['sugars'], strength: data['strength'], name: data['name']);
  }

  Stream<UserData> get userData {
    return brewCollection.doc(uid).snapshots().map((_userDataFromSnapshot));
  }
}
