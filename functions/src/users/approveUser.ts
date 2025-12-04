import { onCall } from "firebase-functions/v2/https";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
//import { isAdmin } from "../utils/isAdmin";

export const approveUser = onCall(async (request) => {
  //const adminUid = request.auth?.uid;

 // if (!adminUid || !isAdmin(adminUid)) {
 //   throw new Error("Admin only.");
 // }

  const uid = request.data?.uid;
  if (!uid) {
    throw new Error("Missing uid.");
  }

  const db = getFirestore();

  const pendingRef = db.collection("pending_users").doc(uid);
  const pendingSnap = await pendingRef.get();

  if (!pendingSnap.exists) {
    throw new Error("Pending user not found.");
  }

  const pendingUserData = pendingSnap.data()!;

  await db.collection("users").doc(uid).set({
    uid: uid,
    email: pendingUserData.email,
    firstName: pendingUserData.firstName,
    lastName: pendingUserData.lastName,
    phone: pendingUserData.phone,
    birthDate: pendingUserData.birthDate,
    status: "approved",
    approvedAt: Timestamp.now(),
  });

  await pendingRef.update({
    status: "approved",
    approvedAt: Timestamp.now(),
  });

  return { success: true };
});
