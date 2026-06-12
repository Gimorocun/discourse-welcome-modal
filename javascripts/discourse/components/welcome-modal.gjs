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
    @tracked shown = false;
    @tracked loading = false;
    @tracked userType = null; // "new", "returning", "engaged"
    @service currentUser;
    @service router;

    constructor() {
        super(...arguments);
        this.determineModalVisibility();
    }

    updateVisitTimestamp() {
        localStorage.setItem("welcome_modal_last_visit_at", new Date().toISOString());
    }

    async determineModalVisibility() {
        // Check for force query parameter - preserve admin testing functionality
        const urlParams = new URLSearchParams(window.location.search);
        const forceShow = urlParams.get('show-welcome-modal') === 'true';
        const userType = urlParams.get('user-type'); // e.g., "new", "returning", "engaged"
        
        if (forceShow) {
            if(!userType) {
                this.userType = "new"
            } else if (["new", "returning", "engaged"].includes(userType)) {
                this.userType = userType;
            }
            this.shown = true;
            return;
        }
        
        if (!settings?.enabled) {
            return;
        }

        // Quick exit for anonymous users
        if (!this.currentUser) {
            return;
        }

        const currentDate = new Date();
        
        this.loading = true;

        try {
            const userDetails = await ajax(`/u/${this.currentUser.username}.json`);
            const userRegistrationDate = new Date(userDetails.user.created_at);
            const modalFeatureEnabledDate = new Date(settings.feature_enabled_date);
            const gracePeriodMonths = settings.grace_period_months || 3;
            const returningUserInactivityMonths = settings.returning_user_inactivity_months || 6;

            // Convert months to milliseconds (using average month length)
            const msPerMonth = 30.44 * 24 * 60 * 60 * 1000;
            // If grace period is 0, set to far future (infinite grace period)
            const gracePeriodEnd = gracePeriodMonths === 0 
                ? new Date(2099, 11, 31) // Far future date
                : new Date(modalFeatureEnabledDate.getTime() + (gracePeriodMonths * msPerMonth));
            const rollingPeriodMs = returningUserInactivityMonths * msPerMonth;

            // Check if user is "engaged" (visits regularly) - they should never see the modal
            const lastVisitAt = localStorage.getItem("welcome_modal_last_visit_at");
            if (lastVisitAt) {
                const lastVisitDate = new Date(lastVisitAt);
                const timeSinceLastVisit = currentDate - lastVisitDate;
                
                if (timeSinceLastVisit < rollingPeriodMs) {
                    // User is engaged - visited within the inactivity period
                    this.userType = "engaged";
                    this.shown = false;
                    this.updateVisitTimestamp();
                    return;
                }
            }

            // Handle migration from old boolean flag to timestamp-based tracking
            const hasOldFlag = localStorage.getItem("has_seen_welcome_modal");
            let lastSeenModalAt = localStorage.getItem("welcome_modal_last_seen_at");
            
            if (hasOldFlag === "true" && !lastSeenModalAt) {
                // Migrate: assume they saw it when the feature was enabled
                lastSeenModalAt = modalFeatureEnabledDate.toISOString();
                localStorage.setItem("welcome_modal_last_seen_at", lastSeenModalAt);
            }
            // Always remove the old flag regardless of its value
            if (hasOldFlag !== null) {
                localStorage.removeItem("has_seen_welcome_modal");
            }

            // Determine if user is existing (registered before feature launch)
            const isExistingUser = userRegistrationDate < modalFeatureEnabledDate;

            // Handle grace period "silent mark" for existing users
            if (isExistingUser && currentDate <= gracePeriodEnd && !lastSeenModalAt) {
                // Silently mark as seen during grace period
                localStorage.setItem("welcome_modal_last_seen_at", currentDate.toISOString());
                this.userType = "existing";
                this.updateVisitTimestamp();
                return; // Don't show modal
            }

            // Determine visibility and user type
            let shouldShow = false;
            let userType = "engaged";

            if (!lastSeenModalAt) {
                // Never seen modal and outside grace period (or new user)
                shouldShow = true;
                userType = isExistingUser ? "returning" : "new";
            } else {
                // Calculate gap since they LAST SAW THE MODAL (not since last visit)
                const modalSeenDate = new Date(lastSeenModalAt);
                const timeSinceLastSeenModal = currentDate - modalSeenDate;
                
                if (timeSinceLastSeenModal > rollingPeriodMs) {
                    shouldShow = true;
                    userType = "returning";
                }
            }

            this.userType = userType;
            this.shown = shouldShow;
            this.updateVisitTimestamp();

        } catch (error) {
            console.error("Welcome Modal: Visibility determination failed:", error);
            // Graceful fallback - don't show modal if we can't determine eligibility
            this.userType = "engaged";
            this.shown = false;
            this.updateVisitTimestamp();
        } finally {
            this.loading = false;
        }
    }

    get showModal() {
        // Don't show modal if there's no content to display
        if (this.shown && this.cardContent.length === 0) {
            return false;
        }
        return this.shown;
    }

    get modalTitle() {
        return I18n.t(themePrefix("discourse_welcome_modal.title"));
    }

    get modalCloseBtn() {
        return I18n.t(themePrefix("discourse_welcome_modal.close_btn"));
    }

    get cardContent() {
        try {
            // 1. If the user is engaged, return an empty array immediately
            if (this.userType === "engaged") return [];

            // 2. Validate settings exist
            if (!settings?.card_content || !Array.isArray(settings.card_content)) {
                console.warn("Welcome Modal: card_content setting is missing or invalid");
                return [];
            }

            // 3. Filter and validate cards
            return settings.card_content.filter(card => {
                // Validate required fields
                if (!card || !card.id || !card.title || !card.subtitle) {
                    console.warn("Welcome Modal: Invalid card detected, skipping:", card);
                    return false;
                }
                
                // Filter based on display criteria
                if (!card.displayFor) return true; 
                if (card.displayFor === "both") return true;
                if (card.displayFor === "new_users" && this.userType === "new") return true;
                if (card.displayFor === "returning_users" && this.userType === "returning") return true;
                
                return false;
            });
        } catch (e) {
            console.error("Welcome Modal: Error processing card content:", e);
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
    dismissModal() {
        this.shown = false;
        // Persist the timestamp when they saw/dismissed the modal
        localStorage.setItem("welcome_modal_last_seen_at", new Date().toISOString());
    }

    @action
    handleCardAction(card) {
        const destination = card?.action;
        if (!destination || typeof destination !== 'string') {
            console.warn("Welcome Modal: Invalid action for card:", card?.id);
            return;
        }

        // Sanitize the destination
        const sanitizedDestination = destination.trim();
        
        try {
            // Check if it's an external link
            const isExternal = /^https?:\/\//i.test(sanitizedDestination);

            if (isExternal) {
                // Additional validation for external URLs
                const url = new URL(sanitizedDestination);
                // Basic security check - reject data: and javascript: protocols
                if (url.protocol !== 'http:' && url.protocol !== 'https:') {
                    console.warn("Welcome Modal: Unsafe URL protocol detected:", url.protocol);
                    return;
                }
                // Open external links safely
                window.open(sanitizedDestination, '_blank', 'noopener,noreferrer');
            } else {
                // Use Discourse router for internal links
                this.router.transitionTo(sanitizedDestination);
            }
            
            this.dismissModal();
        } catch (error) {
            console.error("Welcome Modal: Error handling card action:", error);
            // Still dismiss modal even if navigation fails
            this.dismissModal();
        }
    }

    <template>
        {{#if this.showModal}}
            <DModal
                @title={{this.modalTitle}}
                @closeModal={{this.dismissModal}}
                class="welcome-modal"
            >
                <:body>
                    <div class="modal-content {{this.cardLayout}}-layout" role="main" aria-label="Welcome content">
                        {{#each this.cardContent as |card|}}
                            <article class="card" role="article" aria-labelledby="card-title-{{card.id}}">
                                {{#if card.imgUrl}}
                                    <img
                                        src={{card.imgUrl}}
                                        alt={{card.altText}}
                                        loading="lazy"
                                        onerror="this.style.display='none'"
                                        role="img"
                                    />
                                {{/if}}
                                <div class="card-content">
                                    <h3 id="card-title-{{card.id}}">{{card.title}}</h3>
                                    <p>{{card.subtitle}}</p>
                                    {{#if card.btnLabel}}
                                        <DButton
                                            @action={{fn this.handleCardAction card}}
                                            @translatedLabel={{card.btnLabel}}
                                            class="btn btn-primary btn-small"
                                            aria-describedby="card-title-{{card.id}}"
                                        />
                                    {{/if}}
                                </div>
                            </article>
                        {{/each}}
                    </div>
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