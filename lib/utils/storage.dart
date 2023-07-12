import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/cupertino.dart';


class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  Future<void> uploadFile(String filePath, String fileName, String userId) async {
    File file = File(filePath);
    try {
      await storage.ref('users/$userId/$fileName').putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<firebase_storage.ListResult> listFiles(String userId) async {
    return await storage.ref('users/$userId').listAll();
  }

  Future<String> downloadURL(String imageName, String userId) async {
    String downloadURL = await storage.ref('users/$userId/$imageName').getDownloadURL();
    return downloadURL;
  }
/*
  Future<List<String>> getFolderList(String userId) async {
    List<String> folderList = [];

    try {
      firebase_storage.ListResult result = await storage.ref('users').child(userId).listAll();
      for (var ref in result.prefixes) {
        String folderName = ref.fullPath.split('/').last;
        folderList.add(folderName);
        print(folderList.toString());
      }
    } catch (e) {
      debugPrint('getFolderList Hata: $e');
    }

    return folderList;
  }*/
}