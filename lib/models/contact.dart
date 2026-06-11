class Contact {
  final String id;
  String firstName;
  String lastName;
  String phoneNumber;
  String? email;
  String? company;
  String? address;
  String? notes;
  String? photoPath;
  bool isFavorite;
  DateTime createdAt;
  DateTime updatedAt;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.company,
    this.address,
    this.notes,
    this.photoPath,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    String first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last'.trim().isEmpty ? '?' : '$first$last'.trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'company': company,
      'address': address,
      'notes': notes,
      'photoPath': photoPath,
      'isFavorite': isFavorite ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      company: map['company'],
      address: map['address'],
      notes: map['notes'],
      photoPath: map['photoPath'],
      isFavorite: map['isFavorite'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Contact copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? company,
    String? address,
    String? notes,
    String? photoPath,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      company: company ?? this.company,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
