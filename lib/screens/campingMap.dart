import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gokceada/product/PansionListCard.dart';
import 'package:gokceada/screens/campingDetail.dart';
import '../core/colors.dart';
import '../core/textFont.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CampingDetay extends StatefulWidget {
  const CampingDetay({Key? key}) : super(key: key);

  @override
  _CampingDetayState createState() => _CampingDetayState();
}

class _CampingDetayState extends State<CampingDetay> {
  List<Widget> camping = [];
  List<Widget> campingList = [];

  @override
  void initState() {
    super.initState();
    getCampingList();
  }

  void getCampingList() {
    FirebaseFirestore.instance.collection('campingList').get().then((querySnapshot) {

      for (var doc in querySnapshot.docs) {
        String description = doc['description'];
        String pansionName = doc['camping_name'];
        List<String> images = List<String>.from(doc['image']);
        String location = doc['location'];
        String telNo = doc['telNo'];
        String rating = doc['rating'];
        List<double> latLng = List<double>.from(doc['latLng']);



        Widget campingListWidget = PansionListCard(
            hotelName: pansionName,
            location: location,
            rating: rating,
            list: [images[0],images[1]]);

        Widget campingWidget = CampingDetailView(
          latitude: latLng[0],
          longitude: latLng[1],
          description: description,
          campingName: pansionName,
          list: images,
          location: location,
          telNo: telNo,
          rating: rating,
        );

        setState(() {
          camping.add(campingWidget);
          campingList.add(campingListWidget);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.7,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new, color: ColorConstants.instance.titleColor,),
        ),
        title: Text(AppLocalizations.of(context).kampalanlari, style: TextFonts.instance.titleFont),
      ),
      body: ListView.builder(
        itemCount: camping.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => camping[index],
                ),
              );
            },
            child: campingList[index],
          );
        },
      ),
    );
  }

}

