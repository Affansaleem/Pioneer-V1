import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:project/admin/adminOptionsReport/screens/AdminMonthlyAndDailyReportsMainPage.dart';
import 'package:project/admin/adminOptionsReport/screens/AdminReportsEmployeeListPage.dart';
import 'package:project/admin/pendingLeavesApproval/model/ApproveManualPunchRepository.dart';
import 'package:project/constants/AppColor_constants.dart';
import '../../adminReportsFiles/screens/AdminReportsMainPage.dart';
import '../../adminmanualAttendance/screens/ManualMarkAttendance.dart';
import '../../pendingLeavesApproval/screens/PendingLeavesPage.dart';
import 'adminOptions_card.dart';
import 'adminconstants.dart';

class AdminStorageDetails extends StatelessWidget {
  const AdminStorageDetails({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Options",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: defaultPadding),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                    child: ManualMarkAttendance(),
                    type: PageTransitionType.rightToLeft,
                    duration: Duration(seconds: 1),
                  ));
            },
            child: const AdminStorageInfoCard(
              svgSrc: "assets/icons/present.png",
              title: "Mark Attendance",
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  PageTransition(
                      child: AdminReportsMainPage(),
                      type: PageTransitionType.rightToLeft));
            },
            child: const AdminStorageInfoCard(
              svgSrc: "assets/icons/leave.png",
              title: "Leaves",
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>  AdminMonthlyAndDailyReportsMainPage(viaDrawer: false,),
                )),
            child: const AdminStorageInfoCard(
              svgSrc: "assets/icons/report.png",
              title: "Report",
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
