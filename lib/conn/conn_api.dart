import 'package:http/http.dart' as http;

Future<void> connAPI() async {
  try {
    final response = await http
        .get(Uri.parse("https://wastemanagement.tubagusariq.repl.co/users"));
    if (response.statusCode == 200) {
      return print('API Connected!');
    } else {
      return print('API Connection failed');
    }
  } catch (e) {
    return print(e);
  }
}

const API_URL = "https://wastemngmt.fdvsdeveloper.repl.co";
