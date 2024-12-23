import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static values = { contestId: Number };

  connect() {
    this.polling = setInterval(this.checkStatus.bind(this), 3000);
  }

  disconnect() {
    clearInterval(this.polling);
  }

  async checkStatus() {
    const response = await fetch(
      `/contests/${this.contestIdValue}/upload_status`,
    );
    const upload_status = await response.text();

    if (upload_status === "completed") {
      clearInterval(this.polling);
      this.refreshPage();
    }
  }

  refreshPage() {
    Turbo.visit(window.location.href, { action: "replace" });
  }
}
