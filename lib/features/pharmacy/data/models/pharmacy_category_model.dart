class PharmacyCategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int sortOrder;
  final int productCount;

  const PharmacyCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.sortOrder = 0,
    this.productCount = 0,
  });

  factory PharmacyCategoryModel.fromJson(Map<String, dynamic> json) {
    return PharmacyCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      productCount:
          (json['productCount'] as num?)?.toInt() ??
          (json['_count'] is Map
              ? ((json['_count'] as Map)['products'] as num?)?.toInt()
              : null) ??
          0,
    );
  }
}
