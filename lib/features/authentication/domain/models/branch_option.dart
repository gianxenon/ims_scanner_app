class BranchOption {
  const BranchOption({
    required this.companyCode,
    required this.branchCode,
    required this.branchName,
  });

  final String companyCode;
  final String branchCode;
  final String branchName;

  String get label => '$branchCode - $branchName';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'companyCode': companyCode,
      'branchCode': branchCode,
      'branchName': branchName,
    };
  }

  factory BranchOption.fromJson(Map<String, dynamic> json) {
    return BranchOption(
      companyCode: (json['companyCode'] as String? ?? '').trim(),
      branchCode: (json['branchCode'] as String? ?? '').trim(),
      branchName: (json['branchName'] as String? ?? '').trim(),
    );
  }
}
