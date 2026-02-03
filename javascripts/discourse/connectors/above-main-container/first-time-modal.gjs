import Component from "@glimmer/component";
import DButton from "discourse/components/d-button";
import DModal from "discourse/components/d-modal";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import icon from "discourse/helpers/d-icon";
import { walkthroughState, markWalkthroughAsSeen } from "../../lib/walkthrough-state";

export default class FirstTimeModal extends Component {
  @service router;
  @service currentUser;
  @service capabilities;

  get showModal() {
    return walkthroughState.isVisible;
  }

  get helpOthersUrl() {
    const date = new Date();
    date.setDate(date.getDate() - 7);
    const formattedDate = date.toISOString().split('T')[0];
    return `https://wix.staged-by-discourse.com/search?q=status%3Anoreplies%20after%3A${formattedDate}`;
  }

  get forumSections() {
    return [
      {
        id: "ask-the-community",
        imgUrl: "https://static.wixstatic.com/media/ed437f_b1a7b1affe4d4d448448ed548e2c2234~mv2.png",
        title: "Ask the community",
        subtitle: "Find answers, get expert advice and crack complex code and design issues with other Studio creators.",
        btnLabel: "Ask a question",
        action: "https://wix.staged-by-discourse.com/c/ask-the-community/8?new"
      },
      {
        id: "share-your-expertise",
        imgUrl: "https://static.wixstatic.com/media/ed437f_89608207f85f4210b8c72b8d6ae066eb~mv2.png",
        title: "Share your expertise",
        subtitle: "Share your work and get inspired by what other community members are creating.",
        btnLabel: "Showcase your work",
        action: "https://wix.staged-by-discourse.com/c/show-and-tell/16?new"
      },
      {
        id: "help-a-fellow-creator",
        imgUrl: "https://static.wixstatic.com/media/ed437f_9ccabd9429354c91b0609f1cb28d14a4~mv2.png",
        title: "Help a fellow creator",
        subtitle: "There are users waiting for an answer. Share your expertise today.",
        btnLabel: "Answer a question",
        action: this.helpOthersUrl
      }
    ];
  }

  @action
  closeModal() {
    walkthroughState.isVisible = false;
    markWalkthroughAsSeen();
  }

  @action
  handleSectionClick(url, event) {
    event?.preventDefault();

    if (url) {
      try {
        const targetUrl = new URL(url);
        if (targetUrl.hostname === window.location.hostname) {
          this.router.transitionTo(targetUrl.pathname + targetUrl.search);
        } else {
          window.location.href = url;
        }
      } catch (e) {
        this.router.transitionTo(url);
      }
    }
    
    this.closeModal();
  }

  <template>
    {{#if this.showModal}}
      <DModal
        @title="Join the conversation"
        @closeModal={{this.closeModal}}
        class="forum-sections-modal"
      >
        <:body>
          <div class="forum-sections-container">
            {{#each this.forumSections as |section|}}
              <div class="forum-section-card {{unless this.capabilities.viewport.sm 'stacked'}}">
                <img src={{section.imgUrl}} alt="">
                <div class="section-content">
                  <div class="section-title">{{section.title}}</div>
                  <div class="section-subtitle">{{section.subtitle}}</div>
                  <div class="section-action">
                    <button class="btn btn-primary btn-small section-btn" {{on "click" (fn this.handleSectionClick section.action)}}>
                        {{section.btnLabel}}
                        {{icon "chevron-right"}}
                    </button>
                </div>
                </div>
              </div>
            {{/each}}
          </div>
        </:body>
        <:footer>
          <DButton
            @translatedLabel="Close"
            @action={{this.closeModal}}
            class="btn-transparent close-button"
          />
        </:footer>
      </DModal>
    {{/if}}

    <style>
      .forum-sections-container {
        display: flex;
        flex-direction: column;
        gap: 24px;
        max-width: 600px;
      }

      .forum-section-card {
        display: flex;
        align-items: center;
        gap: 24px;
        background: var(--secondary);
        border-radius: 8px;
        transition: background-color 0.2s ease;
      }

      .forum-section-card img {
        width: 35%;
        border-radius: 6px;
      }

      .forum-section-card.stacked {
        flex-direction: column;
        align-items: stretch;
      }

      .forum-section-card.stacked img {
        width: 100%;
        height: auto;
      }

      .section-icon {
        font-size: 24px;
        color: var(--primary-medium);
        margin-right: 16px;
        flex-shrink: 0;
      }

      .section-content {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 4px;
      }

      .section-title {
        font-size: 16px;
        font-weight: 500;
        color: var(--primary);
        line-height: 1.3;
      }

      .section-subtitle {
        font-size: 14px;
        color: var(--primary-high);
        font-weight: 400;
      }

      .section-action {
        flex-shrink: 0;
      }

      .section-btn {
        padding: 8px 8px 8px 16px !important;
        display: flex;
        align-items: center;
        flex-direction: row;
        gap: 8px;
      }

      .section-btn .d-icon {
        font-size: 16px;
      }

      .forum-sections-modal .modal-footer {
        display: flex;
        justify-content: flex-end;
        gap: 8px;
      }
    </style>
  </template>
}
