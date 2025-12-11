import { onCall } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

export const updateRentalRequestStatus = onCall(async (request) => {
  const userUid = request.auth?.uid;
  if (!userUid) throw new Error("Not authenticated.");

  const { requestId, newStatus } = request.data;

  if (!requestId) throw new Error("Missing requestId");
  if (!newStatus) throw new Error("Missing newStatus");

  const allowed = ["pending", "accepted", "active", "ended", "rejected"];
  if (!allowed.includes(newStatus)) {
    throw new Error(`Invalid status: ${newStatus}`);
  }

  const db = getFirestore();

  await db.collection("rentalRequests").doc(requestId).update({
    status: newStatus,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true };
});
