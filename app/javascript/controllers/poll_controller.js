import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    sessionGetEndpoint: String,
    accessToken: String,
    pollFinishPath: String,
  };

  startPolling(event) {
    event.preventDefault();
    window.open(event.currentTarget.href, "_blank", "noopener,noreferrer");
    this.pollSession();
  }

  async pollSession() {
    try {
      const response = await fetch(this.sessionGetEndpointValue, {
        headers: {
          Authorization: `Bearer ${this.accessTokenValue}`,
        },
      });

      const pickingSession = await response.json();
      const mediaItemsSet = pickingSession.mediaItemsSet;

      if (mediaItemsSet) {
        await this.finishPolling(mediaItemsSet);
      } else {
        const pollInterval =
          parseFloat(
            pickingSession.pollingConfig.pollInterval.replace("s", ""),
          ) * 1000;
        const timeoutIn =
          parseFloat(pickingSession.pollingConfig.timeoutIn.replace("s", "")) *
          1000;

        if (timeoutIn > 0) {
          setTimeout(() => this.pollSession(), pollInterval);
        } else {
          alert("写真選択がタイムアウトしました。再度お試しください。");
          await this.finishPolling(mediaItemsSet);
        }
      }
    } catch (error) {
      console.error("Polling error:", error);
    }
  }

  async finishPolling(mediaItemsSet) {
    const token = document
      .querySelector('meta[name="csrf-token"]')
      .getAttribute("content");

    try {
      const response = await fetch(this.pollFinishPathValue, {
        method: "PATCH",
        headers: {
          "X-CSRF-Token": token,
          "Content-Type": "application/json",
          Accept: "text/vnd.turbo-stream.html",
        },
        body: JSON.stringify({ mediaItemsSet: mediaItemsSet }),
      });

      const contentType = response.headers.get("content-type");
      if (contentType && contentType.includes("application/json")) {
        const { redirect_url, alert: alertMessage } = await response.json();
        alert(alertMessage);
        window.location.href = redirect_url;
      } else {
        document.querySelector("#media_items").innerHTML = await response.text();
      }
    } catch (error) {
      console.error("ポーリング終了処理の送信に失敗しました:", error.message);
    }
  }
}
