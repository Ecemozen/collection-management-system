class DashboardModel {
  final int totalCustomers;
  final double totalDebtAmount;
  final double totalCollectedAmount;
  final double remainingAmount;
  final int overdueDebtCount;
  final int pendingDebtCount;
  final int paidDebtCount;

  DashboardModel({
    required this.totalCustomers,
    required this.totalDebtAmount,
    required this.totalCollectedAmount,
    required this.remainingAmount,
    required this.overdueDebtCount,
    required this.pendingDebtCount,
    required this.paidDebtCount,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalCustomers: json['totalCustomers'] ?? 0,
      totalDebtAmount:
          (json['totalDebtAmount'] ?? 0).toDouble(),
      totalCollectedAmount:
          (json['totalCollectedAmount'] ?? 0).toDouble(),
      remainingAmount:
          (json['remainingAmount'] ?? 0).toDouble(),
      overdueDebtCount:
          json['overdueDebtCount'] ?? 0,
      pendingDebtCount:
          json['pendingDebtCount'] ?? 0,
      paidDebtCount:
          json['paidDebtCount'] ?? 0,
    );
  }
}