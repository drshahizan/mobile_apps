import 'package:cloud_firestore/cloud_firestore.dart';

class ValidationService {
  /// Validates SAP Number according to business rules:
  /// - Must start with '7'
  /// - Must be exactly 7 digits
  /// Returns an error message string if invalid, otherwise null.
  static String? validateSapNumber(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) {
      return 'SAP Number is required';
    }

    // Must be digits only
    final digitsOnly = RegExp(r'^\d+$');
    if (!digitsOnly.hasMatch(v)) {
      return 'SAP Number must contain digits only';
    }

    // Must start with 7 and be exactly 7 digits
    if (!v.startsWith('7')) {
      return 'SAP Number must start with 7';
    }

    if (v.length != 7) {
      return 'SAP Number must be exactly 7 digits';
    }

    // Final full pattern check
    final pattern = RegExp(r'^7\d{6}$');
    if (!pattern.hasMatch(v)) {
      return 'Invalid SAP Number format';
    }

    return null;
  }

  /// Checks if SAP Number already exists in the inventory collection
  /// Optionally excludes a specific document ID (for edit scenarios)
  /// Returns null if SAP Number is available, or error message if it exists
  static Future<String?> checkSapNumberExists(
    String sapNumber, {
    String? excludeDocId,
  }) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('inventory')
          .where('sapCode', isEqualTo: sapNumber)
          .get();

      QuerySnapshot<Map<String, dynamic>>? numericSnapshot;
      final sapAsInt = int.tryParse(sapNumber);
      if (sapAsInt != null) {
        numericSnapshot = await FirebaseFirestore.instance
            .collection('inventory')
            .where('sapCode', isEqualTo: sapAsInt)
            .get();
      }

      final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[
        ...snapshot.docs,
        if (numericSnapshot != null) ...numericSnapshot.docs,
      ];

      if (allDocs.isEmpty) {
        return null; // SAP Number is available
      }

      if (excludeDocId != null) {
        final filtered =
            allDocs.where((doc) => doc.id != excludeDocId).toList();
        if (filtered.isEmpty) {
          return null; // This is the same item, allow it
        }
      }

      return 'This SAP Number already exists in inventory';
    } catch (e) {
      return 'Error checking SAP Number availability: $e';
    }
  }

  /// Checks if Internal Reference No already exists in the inventory collection
  /// Returns null if available, or error message if it exists
  static Future<String?> checkInternalRefExists(
    String internalRef, {
    String? excludeDocId,
  }) async {
    try {
      final normalized = internalRef.trim().toUpperCase();
      final compact = normalized.replaceAll(' ', '');
      if (normalized.isEmpty) return null;

      final formatted = validateInternalReference(normalized) ?? normalized;
      final formattedCompact = formatted.replaceAll(' ', '');

      final formattedSnapshot = await FirebaseFirestore.instance
          .collection('inventory')
          .where('internalRef', isEqualTo: formatted)
          .get();

      QuerySnapshot<Map<String, dynamic>>? formattedCompactSnapshot;
      if (formattedCompact != formatted) {
        formattedCompactSnapshot = await FirebaseFirestore.instance
            .collection('inventory')
            .where('internalRef', isEqualTo: formattedCompact)
            .get();
      }

      QuerySnapshot<Map<String, dynamic>>? normalizedSnapshot;
      if (formatted != normalized) {
        normalizedSnapshot = await FirebaseFirestore.instance
            .collection('inventory')
            .where('internalRef', isEqualTo: normalized)
            .get();
      }

      QuerySnapshot<Map<String, dynamic>>? compactSnapshot;
      if (compact != normalized && compact != formatted && compact != formattedCompact) {
        compactSnapshot = await FirebaseFirestore.instance
        .collection('inventory')
        .where('internalRef', isEqualTo: compact)
        .get();
      }

      final allDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[
        ...formattedSnapshot.docs,
        if (formattedCompactSnapshot != null)
          ...formattedCompactSnapshot.docs,
        if (normalizedSnapshot != null) ...normalizedSnapshot.docs,
        if (compactSnapshot != null) ...compactSnapshot.docs,
      ];

      if (allDocs.isEmpty) {
        return null;
      }

      if (excludeDocId != null) {
        final filtered =
            allDocs.where((doc) => doc.id != excludeDocId).toList();
        if (filtered.isEmpty) {
          return null;
        }
      }

      return 'This Internal Reference already exists in inventory';
    } catch (e) {
      return 'Error checking Internal Reference availability: $e';
    }
  }

  /// Validates and formats Internal Reference No. according to business rules:
  /// - Must consist of 2-4 alphabets and 3-4 numbers
  /// - Valid patterns: AA 111, AAA 111, AAAA 111, AA 1111
  /// - Converts to uppercase for both alphabets and numbers
  /// - Ensures space between alphabets and numbers
  /// Returns formatted string if valid, or null with error via exception
  static String? validateInternalReference(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) {
      return null; // Will be caught as "required" by form validator
    }

    // Remove spaces and convert to uppercase
    final normalized = v.replaceAll(' ', '').toUpperCase();

    // Extract alphabets and numbers using regex
    final match = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(normalized);
    if (match == null) {
      return null; // Will show error message
    }

    final alphabets = match.group(1) ?? '';
    final numbers = match.group(2) ?? '';

    // Validate alphabet count (2-4)
    if (alphabets.length < 2 || alphabets.length > 4) {
      return null; // Invalid format
    }

    // Validate number count (3-4)
    if (numbers.length < 3 || numbers.length > 4) {
      return null; // Invalid format
    }

    // Return formatted: alphabets + space + numbers
    return '$alphabets $numbers';
  }

  /// Validates Internal Reference No. format and returns error message
  /// Returns error string if invalid, null if valid
  static String? validateInternalReferenceFormat(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) {
      return 'Internal Reference is required';
    }

    // Remove spaces and convert to uppercase
    final normalized = v.replaceAll(' ', '').toUpperCase();

    // Extract alphabets and numbers using regex
    final match = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(normalized);
    if (match == null) {
      return 'Internal Reference must contain only alphabets and numbers';
    }

    final alphabets = match.group(1) ?? '';
    final numbers = match.group(2) ?? '';

    // Validate alphabet count (2-4)
    if (alphabets.length < 2 || alphabets.length > 4) {
      return 'Alphabets must be 2-4 characters';
    }

    // Validate number count (3-4)
    if (numbers.length < 3 || numbers.length > 4) {
      return 'Numbers must be 3-4 digits';
    }

    // Valid format
    return null;
  }
}
