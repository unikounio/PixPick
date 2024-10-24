import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { sessionUrl: String, accessToken: String, pollFinishUrl: String }

  startPolling(event) {
    event.preventDefault();

    window.open(event.currentTarget.href, '_blank', 'noopener,noreferrer');

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
        if (data.mediaItemsSet) {
          this.finishPolling();
        } else {
          const pollInterval = parseFloat(data.pollingConfig.pollInterval.replace('s', '')) * 1000;
          const timeoutIn = parseFloat(data.pollingConfig.timeoutIn.replace('s', '')) * 1000;

          if (timeoutIn > 0) {
            setTimeout(() => this.pollSession(), pollInterval);
          } else {
            alert('写真選択がタイムアウトしました。再度お試しください。');
            this.finishPolling();
          }
        }
      }
    )
      .catch(error => console.error("Polling error:", error))
  }

  finishPolling() {
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch(this.pollFinishUrlValue, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': token
      }
    })
      .then(response => {
        if (!response.ok) {
          throw new Error("ポーリング終了処理の送信に失敗しました");
        }
      })
      .catch(error => console.error("ポーリング終了処理の送信に失敗しました:", error));
  }
}
