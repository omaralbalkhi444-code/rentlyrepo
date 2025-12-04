/**
 * Firebase Functions v2 entry file
 * --------------------------------
 * Uses v2 onCall / onRequest syntax
 */

import { initializeApp } from "firebase-admin/app";

// Initialize admin SDK once
initializeApp();

// Export v2 callable functions
export { submitUserForApproval } from "./users/submitUserForApproval";
export { approveUser } from "./users/approveUser";
export { rejectUser } from "./users/rejectUser";

// Uncomment when item functions are ready
// export { submitItemForApproval } from "./items/submitItemForApproval";
// export { approveItem } from "./items/approveItem";
// export { rejectItem } from "./items/rejectItem";
