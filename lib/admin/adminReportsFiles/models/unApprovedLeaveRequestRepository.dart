import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/admin/adminReportsFiles/models/unApprovedLeaveRequestModel.dart';

class UnApprovedLeaveRepository {
  final String baseUrl =
      'http://62.171.184.216:9595/api/admin/leave/getunapproved?CorporateId=ptsoffice';

  Future<List<UnApprovedLeaveRequest>> fetchUnApprovedLeaveRequests() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<UnApprovedLeaveRequest> unApprovedLeaveRequests = jsonData
            .map((data) => UnApprovedLeaveRequest.fromJson(data))
            .toList();

        return unApprovedLeaveRequests;
      } else {
        throw Exception('Failed to load unapproved leave requests');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
