import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = [ "content" ];

  connect() {
    const [errors] = this.contentTarget.getElementsByClassName("govuk-error-summary");
    const actionEl = document.querySelector('[data-action="click->show-hidden-content#show"')

    if (!errors) {
      this.contentTarget.style.display = "none";
      this.ariaHidden(this.contentTarget);

      this.ariaExpanded(actionEl);
    } else {
      actionEl.style.display = "none";

      this.ariaExpanded(this.contentTarget);
      this.ariaHidden(actionEl);
    }
  }

  show(event) {
    event.preventDefault();

    event.target.style.display = "none";
    this.ariaHidden(event.target);

    this.contentTarget.style.display = "block";
    this.ariaExpanded(this.contentTarget);
  }

  ariaHidden(el) {
    el.setAttribute('aria-hidden', 'true');
    el.setAttribute('aria-expanded', 'false');
  }

  ariaExpanded(el) {
    el.setAttribute('aria-hidden', 'false');
    el.setAttribute('aria-expanded', 'true');
  }
}
