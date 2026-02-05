class Document {
  final int id;
  final String title;
  final String description;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String fileType;
  final int uploadedBy;
  final String? uploadedByUsername;
  final DateTime uploadedAt;
  final String tags;

  Document({
    required this.id,
    required this.title,
    required this.description,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileType,
    required this.uploadedBy,
    this.uploadedByUsername,
    required this.uploadedAt,
    required this.tags,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'],
      description: json['description'] ?? '',
      fileName: json['file_name'],
      filePath: json['file_path'],
      fileSize: json['file_size'] is int ? json['file_size'] : int.parse(json['file_size'].toString()),
      fileType: json['file_type'],
      uploadedBy: json['uploaded_by'] is int ? json['uploaded_by'] : int.parse(json['uploaded_by'].toString()),
      uploadedByUsername: json['uploaded_by_username'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
      tags: (json['tags'] ?? 'procedure').toString(),
    );
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }
}
