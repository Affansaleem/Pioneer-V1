import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:project/constants/AppBar_constant.dart';
import 'package:project/constants/AppColor_constants.dart';
import 'package:project/introduction/bloc/bloc_internet/internet_bloc.dart';
import 'package:project/introduction/bloc/bloc_internet/internet_state.dart';
import '../../../No_internet/no_internet.dart';
import 'EmployeeList.dart';
import 'LeaveApprovalPage.dart';

class AdminReportsMainPage extends StatelessWidget {
  bool isInternetLost = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternetBloc, InternetStates>(
      listener: (context, state) {
        if (state is InternetLostState) {
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
          if (isInternetLost) {
            Navigator.pop(context);
          }
          isInternetLost = false;
        }
      },
      builder: (context, state) {
        if (state is InternetGainedState) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Leave Page',
                style: AppBarStyles.appBarTextStyle,
              ),
              centerTitle: true,
              backgroundColor: AppColors.primaryColor,
              iconTheme: IconThemeData(color: AppColors.brightWhite),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Equal space between cards
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity, // Cover the full width of the screen
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmployeeList(),
                          ),
                        ),
                        child: LeaveCard(
                          title: 'Leave Submission',
                          image: Image.asset('assets/icons/submission.png'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Add spacing between cards
                  Expanded(
                    child: Container(
                      width: double.infinity, // Cover the full width of the screen
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaveApprovalPage(),
                          ),
                        ),
                        child: LeaveCard(
                          title: 'Leave Approval',
                          image: Image.asset('assets/icons/approval.png'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
      margin: const EdgeInsets.all(30.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center( // Wrap the content in a Center widget
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center-align content
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: image,
              ),
              const SizedBox(height: 10),
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
      ),
    );
  }
}
