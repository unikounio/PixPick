import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    url: String,
  };

  copy() {
    navigator.clipboard.writeText(this.urlValue).then(
      () => {
        alert("招待用URLをコピーしました！");
      },
      () => {
        alert("コピーに失敗しました");
      },
    );
  }
}
