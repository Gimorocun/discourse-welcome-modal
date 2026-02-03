import { apiInitializer } from "discourse/lib/api";
import { walkthroughState, shouldShowWalkthrough } from "../lib/walkthrough-state";

// Initialize walkthrough once
const initializeWalkthrough = (() => {
  let initialized = false;
  return (api) => {
    if (initialized) return;
    initialized = true;
    
    const currentUser = api.getCurrentUser();
    if (shouldShowWalkthrough(currentUser)) {
      setTimeout(() => {
        walkthroughState.isVisible = true;
        walkthroughState.initialized = true;
      }, 500);
    }
  };
})();

export default apiInitializer("1.8.0", (api) => {
  initializeWalkthrough(api);
});