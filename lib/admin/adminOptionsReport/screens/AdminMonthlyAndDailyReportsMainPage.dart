import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:project/admin/adminOptionsReport/screens/AdminDailyReportsEmployeListPage.dart';
import 'package:project/constants/AppBar_constant.dart';
import 'package:project/constants/AppColor_constants.dart';
import 'package:project/introduction/bloc/bloc_internet/internet_bloc.dart';
import 'package:project/introduction/bloc/bloc_internet/internet_state.dart';
import '../../../No_internet/no_internet.dart';
import 'AdminReportsEmployeeListPage.dart';

class AdminMonthlyAndDailyReportsMainPage extends StatelessWidget {
  bool isInternetLost = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternetBloc, InternetStates>(
      listener: (context, state) {
        // TODO: implement listener
        if (state is InternetLostState) {
          // Set the flag to true when internet is lost
          isInternetLost = true;
          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(
              context,
              PageTransition(
                child: NoInternet(),
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
        if(state is InternetGainedState)
          {
            return Scaffold(

              body: Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(30),
                      width: double.infinity, // Make the width full
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const AdminDailyReportEmployeeListPage(),
                            )),
                        child: LeaveCard(
                          title: 'DAILY REPORTS',
                          image: Image.asset('assets/icons/submission.png'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(30),
                      width: double.infinity, // Make the width full
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const AdminReportEmployeeListPage(),
                            )),
                        child: LeaveCard(
                          title: 'MONTHLY REPORTS',
                          image: Image.asset('assets/icons/approval.png'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        else {
          return Scaffold(
            body: Center(
                child: CircularProgressIndicator()),
          );
        }

      },
    );
  }
}

class LeaveCard extends StatelessWidget {
  final String title;
  final Image image;

  LeaveCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: image, // Use the provided image here
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
