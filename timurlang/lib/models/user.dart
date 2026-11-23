// ============================================
// TimurLang - User Model
// ============================================

class User {
  final String id;
  final String namaLengkap;
  final String email;
  final String passwordHash;
  final String? fotoProfilUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.namaLengkap,
    required this.email,
    required this.passwordHash,
    this.fotoProfilUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'email': email,
      'password_hash': passwordHash,
      'foto_profil_url': fotoProfilUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      namaLengkap: map['nama_lengkap'] as String? ?? '',
      email: map['email'] as String? ?? '',
      passwordHash: map['password_hash'] as String? ?? '',
      fotoProfilUrl: map['foto_profil_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  User copyWith({
    String? id,
    String? namaLengkap,
    String? email,
    String? passwordHash,
    String? fotoProfilUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      fotoProfilUrl: fotoProfilUrl ?? this.fotoProfilUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
