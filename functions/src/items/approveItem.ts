import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const approveItem = onCall(async (request) => {
  const itemId = request.data.itemId;
  if (!itemId) throw new Error("Missing itemId");

  const pendingRef = admin.firestore().collection("pending_items").doc(itemId);
  const itemsRef = admin.firestore().collection("items").doc(itemId);

  const snap = await pendingRef.get();
  if (!snap.exists) throw new Error("Pending item not found");

  const data = snap.data()!;

  await itemsRef.set({
    ...data,
    status: "approved",
    approvedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await pendingRef.update({
    status: "approved",
    reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true };
});
