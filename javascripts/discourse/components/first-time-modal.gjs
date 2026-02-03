import Component from "@glimmer/component";

import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";

import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";

import I18n from "discourse-i18n";

import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { tracked } from "@glimmer/tracking";

export default class FirstTimeModal extends Component {
    @tracked shown = false
    @service currentUser;
    @service router;

    constructor() {
        super(...arguments);
        this.determineModalVisibility();
    }

    async determineModalVisibility() {
        try {
            // Check if user has already seen the modal
            const hasSeenModal = localStorage.getItem("has_seen_first_time_modal") === "true";
            if (hasSeenModal) {
                this.shown = false;
                return;
            }

            // If no current user, don't show modal
            if (!this.currentUser) {
                this.shown = false;
                return;
            }

            // Fetch user details including join date
            const userDetails = await ajax(`/u/${this.currentUser.username}.json`);
            const userJoinDate = new Date(userDetails.user.created_at);
            const featureEnabledDate = new Date(settings.feature_enabled_date);
            const gracePeriodMonths = settings.grace_period_months || 3;
            const currentDate = new Date();

            // Scenario 1: New member joins after the feature enabled date
            if (userJoinDate >= featureEnabledDate) {
                this.shown = true;
                return;
            }

            // User joined before the feature enabled date
            // Calculate grace period end date
            const gracePeriodEnd = new Date(featureEnabledDate);
            gracePeriodEnd.setMonth(gracePeriodEnd.getMonth() + gracePeriodMonths);

            // Scenario 2: Within grace period - add flag silently, don't show modal
            if (currentDate <= gracePeriodEnd) {
                this.shown = false;
                localStorage.setItem("has_seen_first_time_modal", "true");
                return;
            }

            // Scenario 3: After grace period - show modal
            if (currentDate > gracePeriodEnd) {
                this.shown = true;
                return;
            }

            // Default case - don't show modal
            this.shown = false;
        } catch (error) {
            console.error("Error fetching user details or determining modal visibility:", error);
            this.shown = false;
        }
    }

    get showModal() {
        return this.shown;
    }

    get modalTitle() {
        return I18n.t(themePrefix("first_time_member.modal_title"));
    }

    get modalCloseBtn() {
        return I18n.t(themePrefix("first_time_member.modal_close_btn"));
    }

    get cardContent() {
        try {
            return settings?.card_content || [];
        } catch (e) {
            console.warn("Error accessing card_content setting:", e);
            return [];
        }
    }

    get cardLayout() {
        try {
            return settings?.card_layout || "grid";
        } catch (e) {
            console.warn("Error accessing card_layout setting:", e);
            return "grid";
        }
    }

    @action
    closeModal() {
        this.shown = false;
        // 3. Persist the "closed" state
        localStorage.setItem("has_seen_first_time_modal", "true");
    }

    @action
    handleCardAction(card) {
        if (card.action) {
            // Navigate to the card's URL
            if (card.action.startsWith('http') || card.action.startsWith('https')) {
                // External URL - open in new tab/window
                window.open(card.action, '_blank');
            } else {
                // Internal route - use router
                this.router.transitionTo(card.action);
            }
        }
        // Close the modal
        this.closeModal();
    }

    <template>
        {{#if this.showModal}}
            <DModal
                @title={{(htmlSafe this.modalTitle)}}
                @closeModal={{this.closeModal}}
                class="first-time-modal"     
            >
                <:body>
                    <div class="modal-content {{this.cardLayout}}-layout">
                        {{#each this.cardContent as |card|}}
                            <div class="card">
                                <img src={{card.imgUrl}} alt="" />
                                <div class="card-content">
                                    <h3>{{card.title}}</h3>
                                    <p>{{card.subtitle}}</p>
                                    <DButton
                                        @action={{fn this.handleCardAction card}}
                                        @translatedLabel={{card.btnLabel}}
                                        class="btn btn-primary btn-small"
                                    />
                                </div>
                            </div>
                        {{/each}}
                    </div>
                </:body>
                <:footer>
                    <DButton
                        @translatedLabel={{(htmlSafe this.modalCloseBtn)}}
                        @action={{this.closeModal}}
                        class="btn-transparent close-button"
                    />
                </:footer>
            </DModal>
        {{/if}}
    </template>
}