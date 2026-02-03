import { tracked } from "@glimmer/tracking";

const STORAGE_KEY = "forum_walkthrough_v1";
const LAUNCH_DATE = new Date("2026-02-01");
const GRACE_PERIOD_MONTHS = 6;

// Shared reactive state
class WalkthroughState {
  @tracked isVisible = false;
  @tracked initialized = false;
}

export const walkthroughState = new WalkthroughState();

// Helper functions
export function hasSeenWalkthrough() {
  try {
    return localStorage.getItem(STORAGE_KEY) === "true";
  } catch (e) {
    console.warn("Could not access localStorage:", e);
    return false;
  }
}

export function markWalkthroughAsSeen() {
  try {
    localStorage.setItem(STORAGE_KEY, "true");
  } catch (e) {
    console.warn("Could not set localStorage:", e);
  }
}

export function getDebugOverride() {
  try {
    const urlParams = new URLSearchParams(window.location.search);
    
    if (urlParams.get('clear_walkthrough') === 'true') {
      localStorage.removeItem(STORAGE_KEY);
      console.log('🧪 Debug: Cleared walkthrough storage');
    }
    
    if (urlParams.get('simulate_new_user') === 'true') {
      console.log('🧪 Debug: Simulating new user - showing walkthrough');
      return true;
    }
    
    if (urlParams.get('simulate_existing_user') === 'true') {
      console.log('🧪 Debug: Simulating existing user - hiding walkthrough');
      return false;
    }
    
    if (urlParams.get('force_walkthrough') === 'true') {
      console.log('🧪 Debug: Force showing walkthrough');
      return true;
    }
    
    return null;
  } catch (e) {
    console.warn('Could not parse URL parameters:', e);
    return null;
  }
}

export function shouldShowWalkthrough(currentUser) {
  const debugOverride = getDebugOverride();
  if (debugOverride !== null) {
    return debugOverride;
  }

  if (!currentUser || hasSeenWalkthrough()) {
    return false;
  }

  const now = new Date();
  const graceEndDate = new Date(LAUNCH_DATE);
  graceEndDate.setMonth(graceEndDate.getMonth() + GRACE_PERIOD_MONTHS);
  
  const userCreatedAt = new Date(currentUser.created_at);
  const isNewUser = userCreatedAt > LAUNCH_DATE;
  const inGracePeriod = now < graceEndDate;

  if (inGracePeriod) {
    if (isNewUser) {
      return true;
    } else {
      markWalkthroughAsSeen();
      return false;
    }
  } else {
    return true;
  }
}
