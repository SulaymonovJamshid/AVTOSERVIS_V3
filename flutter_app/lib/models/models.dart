class UserModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String role;
  final String? avatar;
  final String? token;

  UserModel({required this.id, required this.name, required this.phone,
    required this.email, required this.role, this.avatar, this.token});

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
    name: j['name'] ?? '',
    phone: j['phone'] ?? '',
    email: j['email'] ?? '',
    role: j['role'] ?? 'user',
    avatar: j['avatar'],
    token: j['token'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'phone': phone,
    'email': email, 'role': role, 'avatar': avatar, 'token': token,
  };
}

class ServiceModel {
  final int id;
  final String name;
  final String description;
  final String address;
  final String city;
  final double lat;
  final double lng;
  final String phone;
  final String? logo;
  final List<String> images; // max 6 ta rasm URL yoki local path
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final String workingHours;
  final double distance;
  final bool isVerified;
  final int ownerId;

  ServiceModel({required this.id, required this.name, required this.description,
    required this.address, required this.city, required this.lat, required this.lng,
    required this.phone, this.logo, required this.images, required this.categories,
    required this.rating, required this.reviewCount, required this.isOpen,
    required this.workingHours, required this.distance, required this.isVerified,
    required this.ownerId});

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
    id: j['id'] is int ? j['id'] : int.parse(j['id'].toString()),
    name: j['name'] ?? '',
    description: j['description'] ?? '',
    address: j['address'] ?? '',
    city: j['city'] ?? '',
    lat: double.tryParse(j['lat'].toString()) ?? 0,
    lng: double.tryParse(j['lng'].toString()) ?? 0,
    phone: j['phone'] ?? '',
    logo: j['logo'],
    images: List<String>.from(j['images'] ?? []),
    categories: List<String>.from(j['categories'] ?? []),
    rating: double.tryParse(j['rating']?.toString() ?? '0') ?? 0,
    reviewCount: int.tryParse(j['review_count']?.toString() ?? '0') ?? 0,
    isOpen: j['is_open'] == true || j['is_open'] == 1,
    workingHours: j['working_hours'] ?? '09:00 - 18:00',
    distance: double.tryParse(j['distance']?.toString() ?? '0') ?? 0,
    isVerified: j['is_verified'] == true || j['is_verified'] == 1,
    ownerId: int.tryParse(j['owner_id']?.toString() ?? '0') ?? 0,
  );

  ServiceModel copyWith({List<String>? images}) => ServiceModel(
    id: id, name: name, description: description, address: address, city: city,
    lat: lat, lng: lng, phone: phone, logo: logo,
    images: images ?? this.images,
    categories: categories, rating: rating, reviewCount: reviewCount,
    isOpen: isOpen, workingHours: workingHours, distance: distance,
    isVerified: isVerified, ownerId: ownerId,
  );
}

class BookingModel {
  final int id;
  final int serviceId;
  final String serviceName;
  final String serviceAddress;
  final int userId;
  final String carModel;
  final String description;
  final String status;
  final String date;
  final String time;

  BookingModel({required this.id, required this.serviceId, required this.serviceName,
    required this.serviceAddress, required this.userId, required this.carModel,
    required this.description, required this.status, required this.date, required this.time});
}

class ReviewModel {
  final int id;
  final String userName;
  final double rating;
  final String comment;
  final String createdAt;

  ReviewModel({required this.id, required this.userName,
    required this.rating, required this.comment, required this.createdAt});
}
