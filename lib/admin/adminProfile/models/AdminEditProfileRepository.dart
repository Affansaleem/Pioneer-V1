import 'dart:convert';
import 'package:http/http.dart' as http;
import 'AdminEditProfileModel.dart';

class AdminEditProfileRepository {
  final String baseUrl;
  AdminEditProfileRepository(this.baseUrl);

  Future<bool> updateAdminProfile(AdminEditProfile adminEditProfile) async {
    final url = Uri.parse('$baseUrl/api/admin/dashboard/updateprofile?CorporateId=ptsoffice');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(adminEditProfile.toJson()),
    );

    if (response.statusCode == 200) {
      // Data was successfully posted
      return true;
    } else {
      // Handle the error and return false
      return false;
    }
  }
}
