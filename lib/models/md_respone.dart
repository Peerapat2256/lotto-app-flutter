class MdRespone {
  final String status;
  final String message;
  final dynamic data;

  MdRespone({required this.status, required this.message, this.data});

  factory MdRespone.fromJson(Map<String, dynamic> json) {
    return MdRespone(
      status: json['status'] ?? "error",
      message: json['message'] ?? "",
      data: json['data'],
    );
  }
}
