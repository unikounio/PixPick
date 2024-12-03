import { Modal } from "tailwindcss-stimulus-components";

export default class extends Modal {
  static targets = ["content"];

  async open(event) {
    event.preventDefault();

    const url = event.currentTarget.dataset.modalEntriesShowUrlValue;

    if (url) {
      try {
        const response = await fetch(url, {
          headers: { Accept: "text/vnd.turbo-stream.html" },
        });

        if (response.ok) {
          this.contentTarget.innerHTML = await response.text();
        } else {
          console.error("コンテンツの取得に失敗しました:", response.statusText);
        }
      } catch (error) {
        console.error("コンテンツの取得中にエラーが発生しました:", error);
      }
    }

    super.open(event);
  }
}
