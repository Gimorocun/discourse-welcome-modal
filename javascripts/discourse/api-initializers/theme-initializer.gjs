import { apiInitializer } from "discourse/lib/api";
import FirstTimeModal from "../components/first-time-modal";

export default apiInitializer((api) => {
  api.renderInOutlet("above-main-container", FirstTimeModal);
});