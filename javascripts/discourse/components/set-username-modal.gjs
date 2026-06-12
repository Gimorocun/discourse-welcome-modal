import Component from "@glimmer/component";

import DModal from "discourse/components/d-modal";
import DButton from "discourse/components/d-button";

import { ajax } from "discourse/lib/ajax";

import I18n from "discourse-i18n";

import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";

const DEFAULT_USERNAME_PREFIX = "user_";

export default class SetUsernameModal extends Component {
  @tracked shown = false;
  @tracked loading = false;
  @tracked newUsername = "";
  @tracked errorMessage = null;

  @service currentUser;

  constructor() {
    super(...arguments);
    this.determineModalVisibility();
  }

  determineModalVisibility() {
    if (!settings?.enabled) {
      return;
    }

    if (!this.currentUser) {
      return;
    }

    if (this.currentUser.username?.startsWith(DEFAULT_USERNAME_PREFIX)) {
      this.shown = true;
    }
  }

  get modalTitle() {
    return I18n.t(themePrefix("set_username_modal.title"));
  }

  get modalDescription() {
    return I18n.t(themePrefix("set_username_modal.description"));
  }

  get usernameLabel() {
    return I18n.t(themePrefix("set_username_modal.username_label"));
  }

  get submitBtnLabel() {
    return I18n.t(themePrefix("set_username_modal.submit_btn"));
  }

  get modalImageUrl() {
    return settings?.modal_image || null;
  }

  get modalImageAlt() {
    return settings?.modal_image_alt || "";
  }

  @action
  handleUsernameInput(event) {
    this.newUsername = event.target.value;
    this.errorMessage = null;
  }

  @action
  async submit() {
    const username = this.newUsername.trim();

    if (!username) {
      this.errorMessage = I18n.t(themePrefix("set_username_modal.error.blank"));
      return;
    }

    if (username.startsWith(DEFAULT_USERNAME_PREFIX)) {
      this.errorMessage = I18n.t(
        themePrefix("set_username_modal.error.default_prefix")
      );
      return;
    }

    this.loading = true;
    this.errorMessage = null;

    try {
      const checkResult = await ajax("/u/check_username", {
        data: {
          username,
          for_user_id: this.currentUser.id,
        },
      });

      if (!checkResult.available) {
        if (checkResult.suggestion) {
          this.errorMessage = I18n.t(
            themePrefix("set_username_modal.error.unavailable_with_suggestion"),
            { suggestion: checkResult.suggestion }
          );
        } else {
          this.errorMessage = I18n.t(
            themePrefix("set_username_modal.error.unavailable")
          );
        }
        return;
      }

      await ajax(`/u/${this.currentUser.username}/preferences/username`, {
        type: "PUT",
        data: { new_username: username },
      });

      this.shown = false;
      window.location.reload();
    } catch (error) {
      const apiError = error?.jqXHR?.responseJSON?.errors?.[0];
      this.errorMessage =
        apiError ||
        I18n.t(themePrefix("set_username_modal.error.generic"));
    } finally {
      this.loading = false;
    }
  }

  <template>
    {{#if this.shown}}
      <DModal @title={{this.modalTitle}} class="set-username-modal">
        <:body>
          <div class="modal-content" role="main">
            {{#if this.modalImageUrl}}
              <img
                src={{this.modalImageUrl}}
                alt={{this.modalImageAlt}}
                class="modal-image"
                loading="lazy"
              />
            {{/if}}

            <p class="modal-description">{{this.modalDescription}}</p>

            <div class="username-field">
              <label for="set-username-input">{{this.usernameLabel}}</label>
              <input
                id="set-username-input"
                type="text"
                value={{this.newUsername}}
                {{on "input" this.handleUsernameInput}}
                disabled={{this.loading}}
                autocomplete="username"
              />
            </div>

            {{#if this.errorMessage}}
              <p class="error-message" role="alert">{{this.errorMessage}}</p>
            {{/if}}
          </div>
        </:body>
        <:footer>
          <DButton
            @action={{this.submit}}
            @translatedLabel={{this.submitBtnLabel}}
            @disabled={{this.loading}}
            class="btn-primary"
          />
        </:footer>
      </DModal>
    {{/if}}
  </template>
}
