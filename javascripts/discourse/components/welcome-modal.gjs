import Component from "@glimmer/component";

import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";

import { ajax } from "discourse/lib/ajax";

import I18n from "discourse-i18n";

import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";

export default class WelcomeModal extends Component {
    @tracked shown = false
    @tracked loading = false
    @service currentUser;
    @service router;

    constructor() {
        super(...arguments);
        this.determineModalVisibility();
    }

    async determineModalVisibility() {
        // 1. Quick exit for anonymous or repeat visitors
        if (!this.currentUser || localStorage.getItem("has_seen_welcome_modal") === "true") {
            return;
        }

        this.loading = true;
        try {
            const userDetails = await ajax(`/u/${this.currentUser.username}.json`);
            const userRegistrationDate = new Date(userDetails.user.created_at);
            const modalFeatureEnabledDate = new Date(settings.feature_enabled_date);
            const gracePeriodMonths = settings.grace_period_months || 3;
            const currentDate = new Date();

            // Scenario 1: New member after feature launch
            if (userRegistrationDate >= modalFeatureEnabledDate) {
                this.shown = true;
                return;
            }

            // Scenario 2: Check Grace Period
            const gracePeriodEnd = new Date(modalFeatureEnabledDate);
            gracePeriodEnd.setMonth(gracePeriodEnd.getMonth() + gracePeriodMonths);

            if (currentDate <= gracePeriodEnd) {
                // Silently flag so they don't see it later
                localStorage.setItem("has_seen_welcome_modal", "true");
            } else {
                // Scenario 3: Legacy user after grace period expired
                this.shown = true;
            }
        } catch (error) {
            console.error("Welcome Modal visibility check failed:", error);
        } finally {
            this.loading = false;
        }
    }

    get showModal() {
        return this.shown;
    }

    get modalTitle() {
        return I18n.t(themePrefix("discourse_welcome_modal.title"));
    }

    get modalCloseBtn() {
        return I18n.t(themePrefix("discourse_welcome_modal.close_btn"));
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
    dismissModal() {
        this.shown = false;
        // 3. Persist the "closed" state
        localStorage.setItem("has_seen_welcome_modal", "true");
    }

    @action
    handleCardAction(card) {
        const destination = card.action;
        if (!destination) return;

        // Check if it's an external link
        const isExternal = /^https?:\/\//i.test(destination);

        if (isExternal) {
            // Open external links safely
            window.open(destination, '_blank', 'noopener,noreferrer');
        } else {
            // Use Discourse router for internal links (starts with / or is a route name)
            this.router.transitionTo(destination);
        }
        
        this.dismissModal();
    }

    <template>
        {{#if this.showModal}}
            <DModal
                @title={{this.modalTitle}}
                @closeModal={{this.dismissModal}}
                class="welcome-modal"     
            >
                <:body>
                    {{#if this.loading}}
                        <div class="spinner"></div>
                    {{else}}
                        <div class="modal-content {{this.cardLayout}}-layout">
                            {{#each settings.card_content as |card|}}
                                <div class="card">
                                    <img src={{card.imgUrl}} alt={{card.altText}} />
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
                    {{/if}}
                </:body>
                <:footer>
                    <DButton
                        @translatedLabel={{this.modalCloseBtn}}
                        @action={{this.dismissModal}}
                        class="btn-transparent close-button"
                    />
                </:footer>
            </DModal>
        {{/if}}
    </template>
}