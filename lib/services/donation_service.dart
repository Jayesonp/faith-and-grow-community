import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dreamflow/services/firebase_service.dart';

class Donation {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final double amount;
  final String? cardLast4;
  final DateTime createdAt;

  Donation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.amount,
    this.cardLast4,
    required this.createdAt,
  });

  factory Donation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Donation(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      email: data['email'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      cardLast4: data['cardLast4'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'amount': amount,
      'cardLast4': cardLast4,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class DonationService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static const String _donationsCollection = 'donations';

  // Process a donation payment and save to Firestore
  static Future<Donation?> processDonation({
    required String userId,
    required String userName,
    required String email,
    required double amount,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
  }) async {
    try {
      // In a real app, this would integrate with a payment processor like Stripe
      // Here we'll simulate the payment process and just store donation details

      // Extract last 4 digits of card for reference (never store full card details)
      final cardLast4 = cardNumber.length > 4 ? cardNumber.substring(cardNumber.length - 4) : '****';

      // Create donation object
      final donationData = Donation(
        id: '', // Will be set by Firestore
        userId: userId,
        userName: userName,
        email: email,
        amount: amount,
        cardLast4: cardLast4,
        createdAt: DateTime.now(),
      );

      // Add to Firestore
      final docRef = await _firestore.collection(_donationsCollection).add(donationData.toFirestore());

      // Return donation with ID
      return Donation(
        id: docRef.id,
        userId: donationData.userId,
        userName: donationData.userName,
        email: donationData.email,
        amount: donationData.amount,
        cardLast4: donationData.cardLast4,
        createdAt: donationData.createdAt,
      );
    } catch (e) {
      print('Error processing donation: $e');
      return null;
    }
  }

  // Get donations for a specific user
  static Future<List<Donation>> getUserDonations(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_donationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Donation.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching user donations: $e');
      return [];
    }
  }

  // Get total donation amount for a user
  static Future<double> getUserTotalDonation(String userId) async {
    try {
      final donations = await getUserDonations(userId);
      if (donations.isEmpty) return 0.0;

      double total = 0.0;
      for (var donation in donations) {
        total += donation.amount;
      }
      return total;
    } catch (e) {
      print('Error calculating total donations: $e');
      return 0.0;
    }
  }
}