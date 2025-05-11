import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'phone_login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/theme_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if username is already taken
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: _usernameController.text.trim())
          .limit(1)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message: 'Jina hili la mtumiaji tayari linatumika',
        );
      }

      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Imeshindwa kuunda akaunti. Tafadhali jaribu tena',
        );
      }

      // Store additional user data in Firestore
      final userData = {
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isProfileComplete': false,
        'role': 'job_seeker',
        'phoneNumber': null,
        'isPhoneVerified': false,
        'uid': user.uid,
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      if (mounted) {
        // Navigate to phone verification with user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneLoginPage(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Nywila ni dhaifu sana';
          break;
        case 'email-already-in-use':
          errorMessage = 'Barua pepe tayari inatumika';
          break;
        case 'username-already-in-use':
          errorMessage = 'Jina la mtumiaji tayari linatumika';
          break;
        case 'invalid-email':
          errorMessage = 'Barua pepe si sahihi';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Operesheni hii haijaruhusiwa';
          break;
        case 'user-creation-failed':
          errorMessage = 'Imeshindwa kuunda akaunti. Tafadhali jaribu tena';
          break;
        default:
          errorMessage = 'Hitilafu imetokea. Tafadhali jaribu tena';
      }
      setState(() {
        _errorMessage = errorMessage;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hitilafu imetokea. Tafadhali jaribu tena';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hitilafu: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Start Google Sign In process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get Google Sign In authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Imeshindwa kuunda akaunti. Tafadhali jaribu tena',
        );
      }

      // Check if user already exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // Create new user data
        final userData = {
          'email': user.email,
          'name': user.displayName ?? '',
          'username': user.email?.split('@')[0] ?? '',
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'isProfileComplete': false,
          'role': 'job_seeker',
          'phoneNumber': null,
          'isPhoneVerified': false,
          'uid': user.uid,
        };

        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set(userData);
      }

      if (mounted) {
        // Navigate to phone verification with user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneLoginPage(
              email: user.email ?? '',
              password: user.uid, // Use UID as password for Google sign-in
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'Akaunti hii tayari inatumika na njia nyingine ya kuingia';
          break;
        case 'invalid-credential':
          errorMessage = 'Hati ya kuingia si sahihi';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Kuingia na Google hakijaruhusiwa';
          break;
        case 'user-disabled':
          errorMessage = 'Akaunti hii imezimwa';
          break;
        case 'user-not-found':
          errorMessage = 'Hakuna akaunti inayopatikana';
          break;
        case 'wrong-password':
          errorMessage = 'Nywila si sahihi';
          break;
        case 'invalid-verification-code':
          errorMessage = 'Namba ya uthibitishaji si sahihi';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Kitambulisho cha uthibitishaji si sahihi';
          break;
        default:
          errorMessage = 'Hitilafu imetokea. Tafadhali jaribu tena';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hitilafu: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _isLoading = true);
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.token,
        );
        
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final user = userCredential.user;
        
        if (user == null) {
          throw FirebaseAuthException(
            code: 'user-creation-failed',
            message: 'Imeshindwa kuunda akaunti. Tafadhali jaribu tena',
          );
        }

        // Store user data in Firestore
        final userData = {
          'email': user.email,
          'name': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'isProfileComplete': false,
          'role': 'job_seeker',
          'phoneNumber': null,
          'isPhoneVerified': false,
          'uid': user.uid,
        };

        await _firestore.collection('users').doc(user.uid).set(userData);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneLoginPage(
                email: user.email ?? '',
                password: user.uid, // Use UID as password for Facebook sign-in
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hitilafu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jisajili'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Unda akaunti yako',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Jina kamili',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali weka jina lako';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Jina la mtumiaji',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali weka jina la mtumiaji';
                  }
                  if (value.length < 3) {
                    return 'Jina la mtumiaji liwe na herufi 3 au zaidi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Barua pepe',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali weka barua pepe yako';
                  }
                  if (!value.contains('@')) {
                    return 'Tafadhali weka barua pepe sahihi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Nywila',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali weka nywila yako';
                  }
                  if (value.length < 6) {
                    return 'Nywila iwe na herufi 6 au zaidi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Thibitisha nywila',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tafadhali thibitisha nywila yako';
                  }
                  if (value != _passwordController.text) {
                    return 'Nywila hazifanani';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Endelea',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('AU'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithGoogle,
                icon: Image.asset('assets/images/google_logo.png', height: 24),
                label: const Text(
                  'Endelea na Google',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signInWithFacebook,
                icon: Image.asset('assets/images/facebook_logo.png', height: 24),
                label: const Text(
                  'Endelea na Facebook',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
               style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: ThemeConstants.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Una akaunti? Ingia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
} 