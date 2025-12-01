import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';

import 'screens/splash_screen.dart';
import 'screens/initial_survey_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApoIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasData) {
            final userId = userSnapshot.data!.uid;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('user_data')
                  .doc(userId)
                  .get(),
              builder: (context, surveySnapshot) {
                if (surveySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data =
                    surveySnapshot.data?.data() as Map<String, dynamic>?;
                final surveyCompleted = data?['firstSurveyCompleted'] ?? false;

                if (!surveyCompleted) {
                  return const InitialSurveyScreen();
                } else {
                  return const SplashScreen();
                }
              },
            );
          }

          return const AuthScreen();
        },
      ),
    );
  }
}
