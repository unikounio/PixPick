import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { baseUrls: String, contestEntriesPath: String };

  async submitEntries(event) {
    event.preventDefault();
    console.log(this.contestEntriesPathValue);
    const token = document
      .querySelector("meta[name='csrf-token']")
      .getAttribute("content");
    const baseUrls = this.baseUrlsValue;

    const response = await fetch(this.contestEntriesPathValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ baseUrls: baseUrls }),
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
