/**
 * Firebase Functions v2 entry file
 * --------------------------------
 * Uses v2 onCall / onRequest syntax
 */

import { initializeApp } from "firebase-admin/app";

initializeApp();

export { submitUserForApproval } from "./users/submitUserForApproval";
export { approveUser } from "./users/approveUser";
export { rejectUser } from "./users/rejectUser";

export { submitItemForApproval } from "./items/submitItemForApproval";
export { approveItem } from "./items/approveItem";
export { rejectItem } from "./items/rejectItem";

export { createRentalRequest } from "./users/createRentalRequest";
