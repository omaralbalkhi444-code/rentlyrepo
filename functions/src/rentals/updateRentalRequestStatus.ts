import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { randomUUID } from "crypto";

export const updateRentalRequestStatus = onCall(async (request) => {
  const userUid = request.auth?.uid;
  if (!userUid) {
    throw new HttpsError("unauthenticated", "Not authenticated.");
  }

  const { requestId, newStatus, qrToken } = request.data;
  if (!requestId || !newStatus) {
    throw new HttpsError("invalid-argument", "Missing parameters.");
  }

  const allowed = ["accepted", "rejected", "active", "ended"];
  if (!allowed.includes(newStatus)) {
    throw new HttpsError("invalid-argument", "Invalid status.");
  }

  const db = getFirestore();
  const ref = db.collection("rentalRequests").doc(requestId);
  const snap = await ref.get();

  if (!snap.exists) {
    throw new HttpsError("not-found", "Request not found.");
  }

  const data = snap.data()!;

  if (data.itemOwnerUid !== userUid && newStatus !== "active") {
    throw new HttpsError("permission-denied", "Not allowed.");
  }

  // ACCEPT => generate QR
  if (newStatus === "accepted") {
    const token = randomUUID();

    await ref.update({
      status: "accepted",
      qrToken: token,
      qrGeneratedAt: FieldValue.serverTimestamp(),
    });

    return { success: true };
  }

  // ACTIVATE
  if (newStatus === "active") {
    if (!qrToken || qrToken !== data.qrToken) {
      throw new HttpsError(
        "failed-precondition",
        "Invalid or expired QR code."
      );
    }

    await ref.update({
      status: "active",
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { success: true };
  }

  // rejected/ ended/ pending
  await ref.update({
    status: newStatus,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return { success: true };
});
