import 'package:testapi/database/SignaturePhotoDB.dart';

class Signaturephotocontroller {
  final SignaturePhotoDB signaturePhotoDB;

  Signaturephotocontroller(this.signaturePhotoDB);

  Future<List<Map<String, dynamic>>?> fetchTaskDeliverDetails({
    required int userId,
    required int taskId,
  }) async {
    return await signaturePhotoDB.getTaskDeliverDetails(
      userId: userId,
      taskId: taskId,
    );
  }

  Future<bool> updateConfirmationField({
    required int userId,
    required int taskId,
    required String status,
    required Map<String, String> fields,
  }) async {
    return await signaturePhotoDB.updateConfirmationField(
      userId: userId,
      taskId: taskId,
      status: status,
      fields: fields,
    );
  }

  Future<bool> clearConfirmationFields({
    required int userId,
    required int taskId,
    bool clearSignature = false,
    bool clearImage = false,
  }) async {
    return await signaturePhotoDB.clearConfirmationFields(
      userId: userId,
      taskId: taskId,
      clearSignature: clearSignature,
      clearImage: clearImage,
    );
  }
}
