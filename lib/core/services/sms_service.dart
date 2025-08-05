import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class SMSService {
  // API Configuration
  static const String _apiUrl = 'https://messaging-service.co.tz/api/sms/v1/text/single';
  static const String _authHeader = 'Basic ZGF2eXN3YWk6ZGF2eXN3YWkxOTk1';
  static const String _senderId = 'OTP'; // Changed from OTP to KAZIHURU
  static const String _clientId = 'KAZI-HURU';
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
      
      // Format phone number consistently
      String formattedPhone = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '255${formattedPhone.substring(1)}';
      } else if (formattedPhone.startsWith('255')) {
        // Already formatted
      } else if (formattedPhone.length == 9) {
        formattedPhone = '255$formattedPhone';
      }
      
      print('📱 Storing OTP for formatted phone: $formattedPhone');
      
      // Store OTP in Firestore with 5-minute expiry
      final otpDoc = await _firestore.collection('otps').add({
        'phoneNumber': formattedPhone,
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
      // Format phone number consistently
      String formattedPhone = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
      if (formattedPhone.startsWith('0')) {
        formattedPhone = '255${formattedPhone.substring(1)}';
      } else if (formattedPhone.startsWith('255')) {
        // Already formatted
      } else if (formattedPhone.length == 9) {
        formattedPhone = '255$formattedPhone';
      }
      
      print('🔍 Verifying OTP: $otp for formatted phone: $formattedPhone');
      
      final otpQuery = await _firestore
          .collection('otps')
          .where('phoneNumber', isEqualTo: formattedPhone)
          .where('otp', isEqualTo: otp)
          .where('isUsed', isEqualTo: false)
          .get();

      if (otpQuery.docs.isEmpty) {
        print('❌ No OTP found for phone number: $formattedPhone');
        return false;
      }

      // Find the most recent OTP
      var otpDocs = otpQuery.docs;
      otpDocs.sort((a, b) {
        final aData = a.data();
        final bData = b.data();
        final aCreatedAt = aData['createdAt'] as Timestamp?;
        final bCreatedAt = bData['createdAt'] as Timestamp?;
        
        if (aCreatedAt == null || bCreatedAt == null) return 0;
        return bCreatedAt.compareTo(aCreatedAt);
      });

      final otpDoc = otpDocs.first;
      final otpData = otpDoc.data();
      final createdAt = (otpData['createdAt'] as Timestamp).toDate();
      final expiresAt = createdAt.add(const Duration(minutes: 5));

      // Check if OTP is expired
      if (DateTime.now().isAfter(expiresAt)) {
        print('❌ OTP expired');
        return false;
      }

      // Mark OTP as used
      await otpDoc.reference.update({'isUsed': true});
      print('✅ OTP verified successfully!');
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
        // Format phone number properly
        String formattedNumber = phoneNumber.replaceAll('+', '').replaceAll(' ', '');
        
        // Handle Tanzanian numbers
        if (formattedNumber.startsWith('0')) {
          formattedNumber = '255${formattedNumber.substring(1)}';
        } else if (formattedNumber.startsWith('255')) {
          // Already formatted
        } else if (formattedNumber.length == 9) {
          formattedNumber = '255$formattedNumber';
        }

        print('Attempt ${currentRetry + 1} of $maxRetries');
        print('Original phone number: $phoneNumber');
        print('Formatted phone number: $formattedNumber');
        print('Generated OTP: $otp');
        print('Sender ID: $_senderId');
        print('Client ID: $_clientId');

        // Create request
        var request = http.Request('POST', Uri.parse(_apiUrl));
        
        // Add headers
        request.headers.addAll({
          'Authorization': _authHeader,
          'Content-Type': 'application/json; charset=utf-8',
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
              print('✅ SMS sent successfully! OTP: $otp');
              return true;
            } else {
              print('❌ Unexpected message status: ${messageStatus['name']}');
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
          print('❌ SMS Error: Status ${response.statusCode}');
          print('❌ SMS Error Response: $responseBody');
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
        print('❌ Error sending SMS: $e');
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