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
        const mediaItemsSet = data.mediaItemsSet
        if (mediaItemsSet) {
          this.finishPolling(mediaItemsSet);
        } else {
          const pollInterval = parseFloat(data.pollingConfig.pollInterval.replace('s', '')) * 1000;
          const timeoutIn = parseFloat(data.pollingConfig.timeoutIn.replace('s', '')) * 1000;

          if (timeoutIn > 0) {
            setTimeout(() => this.pollSession(), pollInterval);
          } else {
            alert('写真選択がタイムアウトしました。再度お試しください。');
            this.finishPolling(mediaItemsSet);
          }
        }
      }
    )
      .catch(error => console.error("Polling error:", error))
  }

  finishPolling(mediaItemsSet) {
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch(this.pollFinishUrlValue, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': token,
        'Content-Type': 'application/json',
        'Accept': 'text/vnd.turbo-stream.html'
      },
      body: JSON.stringify({ mediaItemsSet: mediaItemsSet })
    })
      .then(response => {
        if (!response.ok) {
          return response.text().then(errorText => {
            throw new Error(errorText || "不明なエラー");
          })
        }
        return response.text();
      })
      .then(html => {
        document.querySelector("#selected_items").innerHTML = html;
      })
      .catch(error => console.error("ポーリング終了処理の送信に失敗しました:", error.message));
  }
}
