import { onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
//import { isAdmin } from "../utils/isAdmin";

export const rejectUser = onCall(async (request) => {
  //const adminUid = request.auth?.uid;

  //if (!adminUid || !isAdmin(adminUid)) {
  //  throw new Error("Admin only.");
  //}

  const uid = request.data?.uid;
  if (!uid) {
    throw new Error("Missing uid.");
  }

  const auth = getAuth();
  const db = getFirestore();

  await auth.updateUser(uid, { disabled: true });

  await db.collection("pending_users").doc(uid).set(
    {
      status: "rejected",
      rejectedAt: Timestamp.now(),
    },
    { merge: true }
  );

  return { success: true };
});
