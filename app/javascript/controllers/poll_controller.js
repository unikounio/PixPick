import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { sessionUrl: String, pollNotifyUrl: String }

  startPolling(event) {
    console.log("polling開始")

    event.preventDefault();

    window.open(event.currentTarget.href, '_blank');

    this.pollSession();
  }

  pollSession() {
  }
}
