import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { entryAttributes: String, contestEntriesPath: String };

  async submitEntries(event) {
    event.preventDefault();
    const token = document
      .querySelector("meta[name='csrf-token']")
      .getAttribute("content");
    const entryAttributes = this.entryAttributesValue;

    const response = await fetch(this.contestEntriesPathValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ entryAttributes: entryAttributes }),
    });

    const data = await response.json();
    if (data.redirect_url) {
      window.location.href = data.redirect_url;
    }
    if (data.alert) {
      alert(data.alert);
    }
  }
}
