import 'package:http/http.dart' as http;
import 'dart:convert';

class TwilioService {
  // Replace these with your Twilio credentials
  static const String _accountSid = 'YOUR_ACCOUNT_SID';
  static const String _authToken = 'YOUR_AUTH_TOKEN';
  static const String _twilioNumber = 'YOUR_TWILIO_PHONE_NUMBER';

  static Future<bool> sendOTP(String phoneNumber, String otp) async {
    try {
      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json',
      );

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_accountSid:$_authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _twilioNumber,
          'To': phoneNumber,
          'Body': 'Your Kazi Huru verification code is: $otp',
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }
} 