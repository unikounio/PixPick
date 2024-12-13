import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const img = this.element.querySelector("img");
    if (img.complete) {
      this.finish();
    } else {
      this.element.setAttribute("aria-busy", "true");
    }
  }

  finish() {
    this.element.setAttribute("aria-busy", "false");
  }
}
