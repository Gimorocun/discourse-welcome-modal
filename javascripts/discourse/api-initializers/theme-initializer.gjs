import { apiInitializer } from "discourse/lib/api";
import WelcomeModal from "../components/welcome-modal";

export default apiInitializer((api) => {
  api.renderInOutlet("above-main-container", WelcomeModal);
});