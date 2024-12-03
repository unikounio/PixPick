import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["toast"];

  connect() {
    const dismissAfter = this.element.dataset.dismissAfter || 3000;
    setTimeout(() => {
      this.element.remove();
    }, dismissAfter);
  }
}
