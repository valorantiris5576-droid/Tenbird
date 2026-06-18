import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeScreen extends StatelessWidget{
  const ChallengeScreen([super.key]);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal : 20, vertica: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children : []
          )
        )
      )
    )
  }
}