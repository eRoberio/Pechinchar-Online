import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeletarPerfil {


  deletarFirebaseFirestore() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String id = user.uid;

    FirebaseFirestore deletar = FirebaseFirestore.instance;

    deletar.collection("users").doc(id).delete();
    deletarFirebaseAuth();
  }

  deletarFirebaseAuth() {
    User? user = FirebaseAuth.instance.currentUser;
    user?.delete();
  }
}