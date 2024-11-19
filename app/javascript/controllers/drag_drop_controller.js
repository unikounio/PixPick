import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fileInput", "preview"];
  static values = { entriesCreatePath: String };

  connect() {
    this.files = [];
  }

  dragOver(event) {
    event.preventDefault();
    this.element.classList.add("dragover");
  }

  dragLeave() {
    this.element.classList.remove("dragover");
  }

  drop(event) {
    event.preventDefault();
    this.element.classList.remove("dragover");

    const droppedFiles = Array.from(event.dataTransfer.files);
    droppedFiles.forEach((file) => this.addFile(file));
  }

  addFile(file) {
    this.files.push(file);
    this.updatePreview();
  }

  removeFile(index) {
    this.files.splice(index, 1);
    this.updatePreview();
  }

  updatePreview() {
    this.previewTarget.innerHTML = "";

    this.files.forEach((file, index) => {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader();
        reader.onload = (e) => {
          const wrapper = this.createPreviewItem(
            e.target.result,
            file.name,
            index,
          );
          this.previewTarget.appendChild(wrapper);
        };
        reader.readAsDataURL(file);
      }
    });
  }

  createPreviewItem(imageSrc, fileName, index) {
    const wrapper = document.createElement("div");
    wrapper.classList.add("preview-item");

    const img = document.createElement("img");
    img.src = imageSrc;
    img.alt = fileName;

    const button = document.createElement("button");
    button.type = "button";
    button.innerText = "×";
    button.classList.add("remove-button");
    button.addEventListener("click", () => this.removeFile(index));

    wrapper.appendChild(img);
    wrapper.appendChild(button);

    return wrapper;
  }

  async upload(event) {
    event.preventDefault();

    if (this.files.length === 0) {
      alert("アップロードするファイルを選択してください。");
      return;
    }

    const formData = new FormData();
    this.files.forEach((file) => formData.append("files[]", file));
    const token = document
      .querySelector("meta[name='csrf-token']")
      .getAttribute("content");

    try {
      const response = await fetch(this.entriesCreatePathValue, {
        method: "POST",
        headers: { "X-CSRF-Token": token },
        body: formData,
      });

      const responseData = await response.json();

      if (response.ok) {
        window.location.href = responseData.redirect_url;
      } else {
        alert(responseData.error || "アップロードに失敗しました。");
      }
    } catch (error) {
      console.error("Upload error:", error);
      alert("通信エラーが発生しました。");
    }
  }
}
