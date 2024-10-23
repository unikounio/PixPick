import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { sessionUrl: String, accessToken: String, pollNotifyUrl: String }

  startPolling(event) {
    event.preventDefault();

    window.open(event.currentTarget.href, '_blank');

    this.pollSession();
  }

  pollSession() {
    fetch(this.sessionUrlValue, {
      headers: {
        'Authorization': `Bearer ${this.accessTokenValue}`
      }
    })
      .then(response => response.json())
      .then(data => {
        console.log(data)
      }
    )
  }
}
