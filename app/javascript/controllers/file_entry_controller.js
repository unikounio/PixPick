import { Controller } from "@hotwired/stimulus";
import heic2any from "heic2any";

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

  async addFiles(event) {
    const files = Array.from(event.target.files);
    const processPromises = files.map((file) => this.addFile(file));

    try {
      await Promise.all(processPromises);
    } catch (error) {
      console.error("ファイル処理中にエラーが発生しました:", error);
    }
  }

  async addFile(file) {
    const allowedExtensions = [
      ".jpg",
      ".jpeg",
      ".png",
      ".webp",
      ".heic",
      ".heif",
    ];
    const fileExtension = file.name.split(".").pop().toLowerCase();

    if (
      !file.type.startsWith("image/") &&
      !allowedExtensions.includes(`.${fileExtension}`)
    ) {
      alert(
        `"${file.name}" は画像ではありません。画像ファイルのみアップロードできます。`,
      );
      return;
    }

    if (fileExtension === "heic" || fileExtension === "heif") {
      const canDisplayHEIC = await this.canDisplayHEIC();
      if (!canDisplayHEIC) {
        try {
          const convertedBlob = await heic2any({
            blob: file,
            toType: "image/jpeg",
          });
          const convertedFile = new File(
            [convertedBlob],
            file.name.replace(/\.(heic|heif)$/i, ".jpg"),
            {
              type: "image/jpeg",
            },
          );

          this.addFileToList(convertedFile, convertedFile.name);
        } catch (error) {
          console.error("HEIC変換エラー:", error);
          alert("HEICファイルの変換に失敗しました。");
        }
      } else {
        this.addFileToList(file, file.name);
      }
    } else {
      this.addFileToList(file, file.name);
    }
  }

  async canDisplayHEIC() {
    const img = new Image();
    img.src = "data:image/heic;base64,AAAAGGZ0eXBoZWljAAAAAG1pZjFoZWljAAAEzG1ldGEAAAAAAAAAIWhkbHIAAAAAAAAAAHBpY3QAAAAAAAAAAAAAAAAAAAAADnBpdG0AAAAAAAEAAABNaWluZgAAAAAAAwAAABVpbmZlAgAAAAABAAB";

    return new Promise((resolve) => {
      img.onload = () => resolve(true);
      img.onerror = () => resolve(false);
    });
  }

  addFileToList(file, name) {
    const fileWithId = { file: file, id: crypto.randomUUID() };
    this.files.push(fileWithId);

    const reader = new FileReader();
    reader.onload = (e) => {
      const wrapper = this.createPreviewItem(
        e.target.result,
        name,
        fileWithId.id,
      );
      this.previewTarget.appendChild(wrapper);
    };
    reader.readAsDataURL(file);
  }

  removeFile(id) {
    this.files = this.files.filter((file) => file.id !== id);

    const previewItems = this.previewTarget.querySelectorAll(".preview-item");
    previewItems.forEach((item) => {
      if (item.dataset.id === id) {
        item.remove();
      }
    });
  }

  createPreviewItem(imageSrc, fileName, id) {
    const wrapper = document.createElement("div");
    wrapper.classList.add("preview-item");
    wrapper.dataset.id = id;

    const img = document.createElement("img");
    img.src = imageSrc;
    img.alt = fileName;

    const button = document.createElement("button");
    button.type = "button";
    button.innerHTML = `<i class="fa-solid fa-xmark"></i>`;
    button.classList.add("remove-button");
    button.addEventListener("click", () => this.removeFile(id));

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
    this.files.forEach((fileWithId) =>
      formData.append("files[]", fileWithId.file),
    );
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
