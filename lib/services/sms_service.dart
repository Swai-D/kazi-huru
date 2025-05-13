import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class SMSService {
  // API Configuration
  static const String _apiUrl = 'https://messaging-service.co.tz/api/sms/v1/text/single';
  static const String _authHeader = 'Basic ZGF2eXN3YWk6ZGF2eXN3YWkxOTk1';
  static const String _senderId = 'OTP';
  static const String _clientId = 'KAZI-HURU'; // Your client ID
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a 6-digit OTP
  String _generateOTP() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Generate and send OTP, store it in Firestore
  Future<String?> generateAndSendOTP(String phoneNumber) async {
    try {
      // Generate OTP
      final otp = _generateOTP();
      
      // Store OTP in Firestore with 5-minute expiry
      final otpDoc = await _firestore.collection('otps').add({
        'phoneNumber': phoneNumber,
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(minutes: 5)),
        'isUsed': false,
      });

      // Send OTP via SMS
      final success = await sendOTP(phoneNumber, otp);
      
      if (success) {
        return otp;
      } else {
        // If SMS sending fails, delete the OTP document
        await otpDoc.delete();
        return null;
      }
    } catch (e) {
      print('Error generating and sending OTP: $e');
      return null;
    }
  }

  // Verify OTP from Firestore
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    try {
      final otpQuery = await _firestore
          .collection('otps')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('otp', isEqualTo: otp)
          .where('isUsed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (otpQuery.docs.isEmpty) {
        return false;
      }

      final otpDoc = otpQuery.docs.first;
      final otpData = otpDoc.data();
      final createdAt = (otpData['createdAt'] as Timestamp).toDate();
      final expiresAt = createdAt.add(const Duration(minutes: 5));

      // Check if OTP is expired
      if (DateTime.now().isAfter(expiresAt)) {
        return false;
      }

      // Mark OTP as used
      await otpDoc.reference.update({'isUsed': true});
      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  static Future<bool> sendOTP(String phoneNumber, String otp) async {
    int maxRetries = 3;
    int currentRetry = 0;
    
    while (currentRetry < maxRetries) {
      try {
        // Format phone number (remove + if present and ensure it starts with 255)
        String formattedNumber = phoneNumber.replaceAll('+', '');
        if (!formattedNumber.startsWith('255')) {
          formattedNumber = '255${formattedNumber.startsWith('0') ? formattedNumber.substring(1) : formattedNumber}';
        }

        print('Attempt ${currentRetry + 1} of $maxRetries');
        print('Original phone number: $phoneNumber');
        print('Formatted phone number: $formattedNumber');

        // Create request
        var request = http.Request('POST', Uri.parse(_apiUrl));
        
        // Add headers
        request.headers.addAll({
          'Authorization': _authHeader,
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });

        // Add body with all required and optional parameters
        final body = {
          "from": _senderId,
          "to": formattedNumber,
          "text": "Your Kazi Huru verification code is: $otp",
          "reference": "kazi_huru_${DateTime.now().millisecondsSinceEpoch}",
          "clientId": _clientId,
          "priority": "HIGH",
          "validity": "5",
          "callbackUrl": "",
          "dlr": "1",
          "type": "text"
        };
        request.body = jsonEncode(body);
        
        print('Request URL: $_apiUrl');
        print('Request headers: ${request.headers}');
        print('Request body: ${request.body}');

        // Send request
        http.StreamedResponse response = await request.send();
        final responseBody = await response.stream.bytesToString();
        
        print('SMS Response Status: ${response.statusCode}');
        print('SMS Response: $responseBody');

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(responseBody);
          if (jsonResponse['messages'] != null && jsonResponse['messages'].isNotEmpty) {
            final messageStatus = jsonResponse['messages'][0]['status'];
            print('Message Status: ${messageStatus['name']}');
            print('Status Description: ${messageStatus['description']}');
            
            // Check if message is in a valid state
            if (messageStatus['groupId'] == 18 && messageStatus['name'] == 'PENDING_ENROUTE') {
              return true;
            } else {
              print('Unexpected message status: ${messageStatus['name']}');
              // If we get an unexpected status, retry
              currentRetry++;
              if (currentRetry < maxRetries) {
                print('Retrying in 2 seconds...');
                await Future.delayed(const Duration(seconds: 2));
                continue;
              }
              return false;
            }
          }
          return true;
        } else {
          print('SMS Error: Status ${response.statusCode}');
          print('SMS Error Response: $responseBody');
          // If we get an error status, retry
          currentRetry++;
          if (currentRetry < maxRetries) {
            print('Retrying in 2 seconds...');
            await Future.delayed(const Duration(seconds: 2));
            continue;
          }
          return false;
        }
      } catch (e, stackTrace) {
        print('Error sending SMS: $e');
        print('Stack trace: $stackTrace');
        // If we get an exception, retry
        currentRetry++;
        if (currentRetry < maxRetries) {
          print('Retrying in 2 seconds...');
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
        return false;
      }
    }
    return false;
  }
} 