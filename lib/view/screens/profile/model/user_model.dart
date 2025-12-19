class UserModel {
  final String uid;
  final String? displayName;
  final String? photoURL;
  final String? address;
  final String? phoneNumber;
  final String? email;
  final String? appId;
  final String? token;
  UserModel(
      {this.address,
      required this.uid,
      this.displayName,
      this.email,
      this.phoneNumber,
      this.appId,
      this.token,
      this.photoURL});
  // Factory constructor to create an instance from a JSON object (Map)
  factory UserModel.fromJson(Map<String, dynamic> json, String token) {
    return UserModel(
        uid: json['user_id'] as String,
        address: json['address'] as String?,
        displayName: json['name'] as String?,
        email: json['email'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        photoURL: json['photoURL'] as String?,
        appId: json['app_id'] as String?,
        token: token);
  }
  // Method to convert the instance to a JSON object (Map)
  Map<String, dynamic> toJson() {
    return {
      'user_id': uid,
      'address': address,
      'name': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'app_id': appId,
      'token': token
    };
  }
}
