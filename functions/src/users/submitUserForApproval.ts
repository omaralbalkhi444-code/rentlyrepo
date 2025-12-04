import { onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp  } from "firebase-admin/firestore";

export const submitUserForApproval = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new Error("User must be logged in.");

  const email = request.auth?.token.email;
  if (!email) throw new Error("Email missing.");

  const data = request.data;

  const required = [
    "firstName",
    "lastName",
    "phone",
    "birthDate",
    "idPhotoUrl",
    "selfiePhotoUrl",
  ];

  for (const field of required) {
    if (!data[field]) {
      throw new Error(`Missing: ${field}`);
    }
  }

  const db = getFirestore();

  await db.collection("pending_users").doc(uid).set({
    uid,
    email,
    firstName: data.firstName,
    lastName: data.lastName,
    phone: data.phone,
    birthDate: data.birthDate,
    idPhotoUrl: data.idPhotoUrl,
    selfiePhotoUrl: data.selfiePhotoUrl,
    status: "pending",
    submittedAt: Timestamp.now(),
  });

  return { success: true };
});
