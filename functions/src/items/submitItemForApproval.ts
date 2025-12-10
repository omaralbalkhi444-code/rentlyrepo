import { onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
//import * as admin from "firebase-admin";

export const submitItemForApproval = onCall(async (request) => {
  const ownerId = request.auth?.uid;
  if (!ownerId) throw new Error("Not authenticated");

  const data = request.data;

  const db = getFirestore();

  const ref = db.collection("pending_items").doc();
  const itemId = ref.id;

  await ref.set({
    itemId,
    ownerId,
    name: data.name,
    description: data.description ?? "",
    category: data.category,
    subCategory: data.subCategory,
    images: data.images ?? [],
    rentalPeriods: data.rentalPeriods ?? {},
    status: "pending",
    submittedAt: Timestamp.now(),
  });

  return { success: true, itemId };
});
