import { onCall } from "firebase-functions/v2/https";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

export const createRentalRequest = onCall(async (request) => {
  const customerUid = request.auth?.uid;
  if (!customerUid) throw new Error("Not authenticated.");

  const data = request.data;

  const required = [
    "itemId",
    "itemTitle",
    "itemOwnerUid",
    "rentalType",
    "startDate",
    "endDate",
    "pickupTime",
    "totalPrice",
  ];

  for (const k of required) {
    if (!data[k]) throw new Error(`Missing field: ${k}`);
  }

  const db = getFirestore();

  await db.collection("rentalRequests").add({
    ...data,
    customerUid,
    status: "pending",
    createdAt: FieldValue.serverTimestamp(),
  });

  return { success: true };
});
