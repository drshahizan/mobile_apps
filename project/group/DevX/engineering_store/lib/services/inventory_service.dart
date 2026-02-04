import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// InventoryService handles authentication with Google and downloading/parsing
/// an Excel (.xlsx) file stored in Google Drive.
///
/// IMPORTANT:
/// - You must create the Excel file in Google Drive and obtain its FILE ID.
///   (Open the file in a browser: the ID is the long string in the URL after /d/ )
/// - In Google Cloud Console enable the Drive API for your project.
/// - Configure your Android OAuth consent + add an Android OAuth client with your app's package name
///   and SHA-1 signing certificate.
/// - google_sign_in handles user OAuth; we then use the access token to call Drive API.
/// - This approach downloads the entire Excel file each time; for large data sets consider
///   migrating to Google Sheets + Cloud Function or syncing into Firestore.
class InventoryService {
  InventoryService({required this.driveFileId});

  final String driveFileId; // e.g. '1AbCdEfGhIj...'

  // Scope for readonly Drive file access.
  static const _scopes = [
    'https://www.googleapis.com/auth/drive.readonly',
  ];

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  GoogleSignInAccount? _account;

  Future<GoogleSignInAccount> ensureSignedIn() async {
    _account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    _account ??= await _googleSignIn.signIn();
    if (_account == null) {
      throw Exception('Google sign-in failed or was cancelled.');
    }
    return _account!;
  }

  /// Downloads the Excel file bytes from Drive using the authenticated user's access token.
  Future<Uint8List> downloadExcelBytes() async {
    final acct = await ensureSignedIn();
    final auth = await acct.authentication;
    final accessToken = auth.accessToken;
    if (accessToken == null) {
      throw Exception('Missing access token after sign-in.');
    }
    final url = Uri.parse('https://www.googleapis.com/drive/v3/files/$driveFileId?alt=media');
    final resp = await http.get(url, headers: {
      'Authorization': 'Bearer $accessToken',
    });
    if (resp.statusCode != 200) {
      throw Exception('Drive download failed (${resp.statusCode}): ${resp.body}');
    }
    return Uint8List.fromList(resp.bodyBytes);
  }

  /// Parses the Excel bytes into a list of row maps.
  /// Expected header row (first row) e.g.: Code | Name | Qty | Location
  List<Map<String, dynamic>> parseExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    // Use first sheet if you don't know the name.
    final sheet = excel.tables.isNotEmpty ? excel.tables.values.first : null;
    if (sheet == null) return [];
    final rows = sheet.rows;
    if (rows.isEmpty) return [];
    // Assume header in row 0.
    final List<Map<String, dynamic>> items = [];
    for (var i = 1; i < rows.length; i++) {
      final r = rows[i];
      items.add({
        'code': r.length > 0 ? r[0]?.value : null,
        'name': r.length > 1 ? r[1]?.value : null,
        'qty': r.length > 2 ? r[2]?.value : null,
        'location': r.length > 3 ? r[3]?.value : null,
      });
    }
    return items;
  }

  /// High-level convenience to sign in, download and parse.
  Future<List<Map<String, dynamic>>> loadInventory() async {
    final bytes = await downloadExcelBytes();
    return parseExcel(bytes);
  }
}
