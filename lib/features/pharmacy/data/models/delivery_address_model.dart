class DeliveryAddressModel {
  final String id;
  final String label;
  final String recipientName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String province;
  final String? postalCode;
  final bool isDefault;

  const DeliveryAddressModel({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.province,
    this.postalCode,
    this.isDefault = false,
  });

  factory DeliveryAddressModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressModel(
      id: json['id'] as String,
      label: json['label'] as String? ?? '',
      recipientName: json['recipientName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressLine1: json['addressLine1'] as String? ?? '',
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String? ?? '',
      province: json['province'] as String? ?? '',
      postalCode: json['postalCode'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
