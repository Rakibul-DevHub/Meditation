// model/subscription_model.dart
class SubscriptionPlan {
  final String id;
  final String name;
  final List<String> description;
  final int price;
  final String currency;
  final String interval;
  final int downloadLimit;
  final String? stripePriceId;
  final String? paypalPlanId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.interval,
    required this.downloadLimit,
    this.stripePriceId,
    this.paypalPlanId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description'] != null
          ? List<String>.from(json['description'])
          : [],
      price: json['price'] as int? ?? 0,
      currency: json['currency']?.toString() ?? 'USD',
      interval: json['interval']?.toString() ?? 'month',
      downloadLimit: json['downloadLimit'] as int? ?? 0,
      stripePriceId: json['stripePriceId']?.toString(),
      paypalPlanId: json['paypalPlanId']?.toString(),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get formattedPrice {
    return '$currency${price.toString()}';
  }

  String get intervalText {
    switch (interval.toLowerCase()) {
      case 'month':
        return 'per month';
      case 'year':
        return 'per year';
      case 'week':
        return 'per week';
      default:
        return 'per $interval';
    }
  }
}

class SubscriptionStatus {
  final String userType;
  final bool isPremium;
  final dynamic subscription;

  SubscriptionStatus({
    required this.userType,
    required this.isPremium,
    this.subscription,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return SubscriptionStatus(
      userType: data['userType']?.toString() ?? 'BASIC',
      isPremium: data['isPremium'] as bool? ?? false,
      subscription: data['subscription'],
    );
  }
}

class SubscriptionResponse {
  final List<SubscriptionPlan> plans;
  final bool stripeEnabled;
  final bool paypalEnabled;

  SubscriptionResponse({
    required this.plans,
    required this.stripeEnabled,
    required this.paypalEnabled,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return SubscriptionResponse(
      plans: data['plans'] != null
          ? (data['plans'] as List)
          .map((e) => SubscriptionPlan.fromJson(e))
          .toList()
          : [],
      stripeEnabled: data['stripeEnabled'] as bool? ?? false,
      paypalEnabled: data['paypalEnabled'] as bool? ?? false,
    );
  }
}