import { apiInitializer } from "discourse/lib/api";
import SetUsernameModal from "../components/set-username-modal";

export default apiInitializer((api) => {
  api.renderInOutlet("above-main-container", SetUsernameModal);
});
