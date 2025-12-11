import { onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

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

    images: Array.isArray(data.images) ? data.images : [],
    rentalPeriods: data.rentalPeriods ?? {},

    // Only store location (your requirement)
    latitude: data.latitude ?? null,
    longitude: data.longitude ?? null,

    status: "pending",
    submittedAt: Timestamp.now(),
  });

  return { success: true, itemId };
});
