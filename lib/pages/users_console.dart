import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:gokceada/core/colors.dart';
import 'package:gokceada/core/textFont.dart';
import 'package:gokceada/product/hotelListCard.dart';
import '../utils/storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UsersConsole extends StatefulWidget {
  const UsersConsole({Key? key}) : super(key: key);

  @override
  _UsersConsoleState createState() => _UsersConsoleState();
}

class _UsersConsoleState extends State<UsersConsole> {
  final Storage storage = Storage();
  Map<String, List<firebase_storage.Reference>> imageMap = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUsersImages(); // Kullanıcıların resimlerini al
  }

  Future<void> getUsersImages() async {
    setState(() {
      isLoading = true;
    });

    // Tüm kullanıcıların resimlerini almak için storage'dan listeyi çek
    firebase_storage.ListResult result = await storage.listFiles('');

    // Tüm kullanıcıların UID'lerini al
    List<String> userUids = result.prefixes.map((ref) => ref.name).toList();

    // Her kullanıcının resimlerini al ve imageMap'e ekle
    for (String uid in userUids) {
      firebase_storage.ListResult userResult = await storage.listFiles(uid);
      List<firebase_storage.Reference> images = userResult.items;
      imageMap[uid] = images;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteLastImage() async {
    try {
      final userUid = FirebaseAuth.instance.currentUser!.uid;
      final storage = FirebaseStorage.instance;
      final reference = storage.ref('users/$userUid');
      final result = await reference.listAll();

      if (result.items.isNotEmpty && result.items.length != 1) {
        final lastImage = result.items.last;
        await lastImage.delete();
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context).resimSilindi),
          ),
        );
      } else if(result.items.length == 1) {
        final lastImage = result.items.last;
        await lastImage.delete();
        Navigator.pushReplacementNamed(context, '/homepage');
      }
    } catch (e) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final _controller = PageController();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.7,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: ColorConstants.instance.titleColor,
            ),
          ),
          title: Text(AppLocalizations.of(context).sizinGozunuzdenAda,
              style: TextFonts.instance.appBarTitleColor),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.instance.titleColor,
                ),
              )
            : ListView.builder(
                itemCount: imageMap.length,
                itemBuilder: (BuildContext context, int index) {
                  String userUid = imageMap.keys.elementAt(index);
                  List<firebase_storage.Reference> images = imageMap[userUid]!;

                  return images.isEmpty
                      ? Container()
                      : Container(
                          height: 400,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  width: 1,
                                  color: ColorConstants.instance.titleColor)),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FutureBuilder<String?>(
                                future: getUsernameFromUid(userUid),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String?> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasData) {
                                      return Container(
                                          margin: const EdgeInsets.all(8),
                                          child: Text(snapshot.data ?? '',
                                              style: TextFonts
                                                  .instance.middleTitle));
                                    } else {
                                      return Container(
                                          margin: const EdgeInsets.all(8),
                                          child: Text('Google Kullanıcısı',
                                              style: TextFonts
                                                  .instance.middleTitle));
                                    }
                                  } else {
                                    return Container(
                                        margin: const EdgeInsets.all(8),
                                        child: Text(AppLocalizations.of(context).kullaniciYukeliyor,
                                            style: TextFonts
                                                .instance.middleTitle));
                                  }
                                },
                              ),
                              Expanded(
                                child: PageView.builder(
                                  controller: _controller,
                                  itemCount: images.length,
                                  itemBuilder:
                                      (BuildContext context, int pageIndex) {
                                    final imageRef = images[pageIndex];
                                    return FutureBuilder<String>(
                                      future: storage.downloadURL(
                                          imageRef.name, userUid),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasError) {
                                            return Center(
                                              child: Text(
                                                  'Hata: ${snapshot.error}'),
                                            );
                                          } else {
                                            return Image.network(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                            );
                                          }
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: ColorConstants
                                                  .instance.titleColor,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              Center(
                                child: Indicator(
                                    list: images, controller: _controller),
                              )
                            ],
                          ),
                        );
                },
              ),
        floatingActionButton: FirebaseAuth.instance.currentUser != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    FloatingActionButton(
                      backgroundColor: ColorConstants.instance.titleColor,
                      onPressed: FirebaseAuth.instance.currentUser != null
                          ? () async {
                              await deleteLastImage();
                              getUsersImages();
                            }
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                  content: Text(AppLocalizations.of(context).kullaniciGirisiYapilmadi),
                                ),
                              );
                            },
                      child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    FloatingActionButton(
                      backgroundColor: ColorConstants.instance.activatedButton,
                      onPressed: () async {
                        // Dosya seçme işlemini gerçekleştir
                        final results = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['png', 'jpg'],
                        );

                        if (results != null) {
                          final path = results.files.single.path;
                          final fileName = results.files.single.name;

                          // Seçilen dosyanın işlenmesi ve yüklenmesi gibi işlemleri yapabilirsiniz
                          await storage.uploadFile(
                            path!,
                            fileName,
                            FirebaseAuth.instance.currentUser!.uid,
                          );
                          getUsersImages(); // Resimleri yeniden almak için getUsersImages() metodunu çağır

                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text(AppLocalizations.of(context).dosyaBasariylaYuklendi),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text(AppLocalizations.of(context).resimSecilmedi),
                            ),
                          );
                        }
                      },
                      child: const Icon(Icons.upload, color: Colors.white),
                    ),
                  ])
            : FloatingActionButton(
                backgroundColor: ColorConstants.instance.titleColor,
                onPressed: () {
                  // Kullanıcı oturum açmamış, giriş sayfasına yönlendir
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Icon(Icons.login, color: Colors.white),
              ));
  }

  Future<String?> getUsernameFromUid(String uid) async {
    try {
      if (kDebugMode) {
        print('Fetching username for UID: $uid');
      }

      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String? username = userDoc.get('username') as String?;
        if (kDebugMode) {
          print('Username found: $username');
        }
        return username;
      } else {
        if (kDebugMode) {
          print('User not found for UID: $uid');
        }
        return null; // Kullanıcı belgesi bulunamadı
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting username from UID: $e');
      }
      return null;
    }
  }
}
