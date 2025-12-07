import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

export const submitItemForApproval = onCall(async (request) => {
  const ownerId = request.auth?.uid;
  if (!ownerId) throw new Error("Not authenticated");

  const data = request.data;

  const ref = admin.firestore().collection("pending_items").doc();
  const itemId = ref.id;

  await ref.set({
    itemId: itemId,
    ownerId: ownerId,
    name: data.name,
    description: data.description,
    category: data.category,
    imageUrls: data.imageUrls,
    pricePerHour: data.pricePerHour,
    pricePerWeek: data.pricePerWeek,
    pricePerMonth: data.pricePerMonth,
    pricePerYear: data.pricePerYear,
    status: "pending",
    submittedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, itemId: itemId };
});
