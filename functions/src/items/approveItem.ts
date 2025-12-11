import { onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

export const approveItem = onCall(async (request) => {
  const itemId = request.data.itemId;
  if (!itemId) throw new Error("Missing itemId");

  const db = getFirestore();

  const pendingRef = db.collection("pending_items").doc(itemId);
  const itemsRef = db.collection("items").doc(itemId);

  const snap = await pendingRef.get();
  if (!snap.exists) throw new Error("Pending item not found");

  const data = snap.data()!;

  await itemsRef.set({
    ...data,

    status: "approved",
    approvedAt: Timestamp.now(),

    // Add rating system ONLY when approved
    rating: 0,
    reviews: [],
  });

  // Update pending item metadata
  await pendingRef.update({
    status: "approved",
    reviewedAt: Timestamp.now(),
  });

  return { success: true };
});
