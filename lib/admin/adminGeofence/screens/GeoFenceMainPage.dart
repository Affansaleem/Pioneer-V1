import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:project/admin/adminGeofence/screens/adminGeofencing.dart';
import 'package:project/admin/pendingLeavesApproval/model/ApproveManualPunchRepository.dart';
import 'package:project/admin/pendingLeavesApproval/screens/PendingLeavesPage.dart';
import 'package:project/constants/AppBar_constant.dart';
import 'package:project/constants/AppColor_constants.dart';
import '../../../No_internet/no_internet.dart';
import '../../../introduction/bloc/bloc_internet/internet_bloc.dart';
import '../../../introduction/bloc/bloc_internet/internet_state.dart';

class GeoFenceMainPage extends StatefulWidget {
  const GeoFenceMainPage({Key? key}) : super(key: key);

  @override
  State<GeoFenceMainPage> createState() => _GeoFenceMainPageState();
}

class _GeoFenceMainPageState extends State<GeoFenceMainPage> {
  bool isInternetLost = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternetBloc, InternetStates>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is InternetLostState) {
          // Set the flag to true when internet is lost
          isInternetLost = true;
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.push(
              context,
              PageTransition(
                child: const NoInternet(),
                type: PageTransitionType.rightToLeft,
              ),
            );
          });
        } else if (state is InternetGainedState) {
          // Check if internet was previously lost
          if (isInternetLost) {
            // Navigate back to the original page when internet is regained
            Navigator.pop(context);
          }
          isInternetLost = false; // Reset the flag
        }
      },
      builder: (context, state) {
        if (state is InternetGainedState) {
          return Scaffold(
            appBar: AppBar(
              iconTheme: const IconThemeData(color: AppBarStyles.appBarIconColor),
              title: const Text(
                'GeoFence Hub',
                style: AppBarStyles.appBarTextStyle,
              ),
              centerTitle: true,
              backgroundColor: AppColors.primaryColor,
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: CardButton(
                    text: 'Set Geofence',
                    image: Image.asset(
                        'assets/icons/map.png'), // Replace with your image path
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const AdminGeofencing(),
                          type: PageTransitionType.rightToLeft,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                      // Implement the action for Set Geofence here.
                    },
                  ),
                ),
                Expanded(
                  child: CardButton(
                    text: 'GeoFence Approval',
                    image: Image.asset('assets/icons/geoapproval.png'),
                    // Replace with your image path
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: PendingLeavesPage(
                            approveRepository: ApproveManualPunchRepository(),
                          ),
                          type: PageTransitionType.rightToLeft,
                        ),
                      );
                      // Implement the action for GeoFence Approval here.
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          // You forgot to return the Scaffold widget in the else block
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class CardButton extends StatelessWidget {
  final String text;
  final Image image;
  final VoidCallback onPressed;

  CardButton({
    required this.text,
    required this.image,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 50, bottom: 50),
      // Reduce the margin for a smaller card
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 40, // Adjust the width and height for a smaller image
                height: 40,
                child: image,
              ),
              const SizedBox(width: 12.0), // Reduce spacing
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18.0, // Adjust the font size as needed
                  fontWeight: FontWeight.normal, // Use normal font weight
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
