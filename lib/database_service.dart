import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:cloud_firestore/cloud_firestore.dart' as cloud_firestore;

import 'recipe.dart';

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(File file, String fileName) async {
    try {
      storage.ref('images/$fileName').putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      // ignore: avoid_print
      print(e.message);
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      storage.ref('images/$fileName').delete();
    } on firebase_core.FirebaseException catch (e) {
      // ignore: avoid_print
      print(e.message);
    }
  }

  Future<String> downloadURL(String? fileName) async {
    if (fileName == null) {
      return Recipe.defaultImg;
    }
    try {
      return await storage.ref('images/$fileName').getDownloadURL();
    } catch (e) {
      return Recipe.defaultImg;
    }
  }
}

class Cloud {
  final cloud_firestore.FirebaseFirestore cloud =
      cloud_firestore.FirebaseFirestore.instance;

  Future<void> uploadRecipe(Recipe recipe, String type) async {
    try {
      cloud.collection(type).add(recipe.toJson());
    } on firebase_core.FirebaseException catch (e) {
      // ignore: avoid_print
      print(e.message);
    }
  }

  Future<void> deleteRecipe(String id, String type) async {
    try {
      cloud.collection(type).doc(id).delete();
    } on firebase_core.FirebaseException catch (e) {
      // ignore: avoid_print
      print(e.message);
    }
  }

  Stream<List<Recipe>> readRecipes(String collection) =>
      cloud.collection(collection).snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => Recipe.fromJson(doc.data(), doc.id))
                .toList(),
          );
}
