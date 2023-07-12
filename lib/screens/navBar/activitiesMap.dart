import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gokceada/screens/activitiesDetail.dart';
import '../../core/colors.dart';
import '../../core/textFont.dart';
import '../../product/networkCardDesign.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ActivitiesDetay extends StatefulWidget {
  const ActivitiesDetay({Key? key}) : super(key: key);

  @override
  _ActivitiesDetayState createState() => _ActivitiesDetayState();
}

class _ActivitiesDetayState extends State<ActivitiesDetay> {
  List<Widget> activities = [];
  List<Widget> activitiesList = [];

  @override
  void initState() {
    super.initState();
    getActivities();
  }

  void getActivities() {
    FirebaseFirestore.instance.collection('activitiesList').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        String activitiesName = doc['activitiesName'];
        List<String> images = List<String>.from(doc['image']);
        String description = doc['description'];
        String location = doc['location'];
        List<String> telNo = List<String>.from(doc['telNo']);
        List<String> owner = List<String>.from(doc['owner']);


        Widget pansionListWidget = NetworkCardDesign(
            cardText: activitiesName,
            path: images[0]);


        Widget pansionWidget = ActivitiesDetail(
          description: description,
          location: location,
          telNo: telNo,
          list: images,
          activitiesName: activitiesName,
          owner: owner,
        );

        setState(() {
          activities.add(pansionWidget);
          activitiesList.add(pansionListWidget);
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
        title: Text(AppLocalizations.of(context).aktiviteler, style: TextFonts.instance.appBarTitleColor),
      ),
      body: ListView.builder(
        itemCount: activities.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => activities[index],
                ),
              );
            },
            child: activitiesList[index],
          );
        },
      ),
    );
  }

}

