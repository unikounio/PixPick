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

    const fileId = crypto.randomUUID();
    const wrapper = this.createPreviewItem(fileId, file.name);

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
            { type: "image/jpeg" },
          );

          this.updatePreview(
            wrapper,
            fileId,
            URL.createObjectURL(convertedBlob),
            convertedFile.name,
          );
          this.addFileToList(convertedFile, fileId);
        } catch (error) {
          console.error("HEIC変換エラー:", error);
          this.showErrorOnPreview(wrapper);
        }
      } else {
        this.updatePreview(
          wrapper,
          fileId,
          URL.createObjectURL(file),
          file.name,
        );
        this.addFileToList(file, fileId);
      }
    } else {
      this.updatePreview(wrapper, fileId, URL.createObjectURL(file), file.name);
      this.addFileToList(file, fileId);
    }
  }

  async canDisplayHEIC() {
    const img = new Image();
    img.src =
      "data:image/heic;base64,AAAAGGZ0eXBoZWljAAAAAG1pZjFoZWljAAAEzG1ldGEAAAAAAAAAIWhkbHIAAAAAAAAAAHBpY3QAAAAAAAAAAAAAAAAAAAAADnBpdG0AAAAAAAEAAABNaWluZgAAAAAAAwAAABVpbmZlAgAAAAABAAB";

    return new Promise((resolve) => {
      img.onload = () => resolve(true);
      img.onerror = () => resolve(false);
    });
  }

  addFileToList(file, fileID) {
    const fileWithId = { file: file, id: fileID };
    this.files.push(fileWithId);
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

  createPreviewItem(fileId, fileName) {
    const wrapper = document.createElement("div");
    wrapper.classList.add(
      "preview-item",
      "flex",
      "justify-center",
      "items-center",
      "flex-col",
      "border",
      "border-stone-300",
    );

    const removeButton = this.createRemoveButton(fileId);
    const spinner = this.createSpinner();
    const fileNameText = this.createFileNameText(fileName);

    wrapper.appendChild(removeButton);
    wrapper.appendChild(spinner);
    wrapper.appendChild(fileNameText);
    wrapper.dataset.id = fileId;

    this.previewTarget.appendChild(wrapper);
    return wrapper;
  }

  createRemoveButton(fileId) {
    const removeButton = document.createElement("button");
    removeButton.type = "button";
    removeButton.innerHTML = `<i class="fa-solid fa-xmark"></i>`;
    removeButton.classList.add("remove-button");
    removeButton.addEventListener("click", () => this.removeFile(fileId));
    return removeButton;
  }

  createSpinner() {
    const spinner = document.createElement("div");
    spinner.classList.add(
      "w-8",
      "h-8",
      "border-4",
      "border-stone-200",
      "border-t-cyan-500",
      "rounded-full",
      "animate-spin",
    );
    return spinner;
  }

  createFileNameText(fileName) {
    const fileNameText = document.createElement("p");
    fileNameText.textContent = fileName;
    fileNameText.classList.add(
      "text-center",
      "mt-2",
      "text-sm",
      "text-stone-500",
    );
    return fileNameText;
  }

  updatePreview(wrapper, fileId, imageSrc, fileName) {
    wrapper.innerHTML = "";

    wrapper.classList.remove("border", "border-stone-300");

    const removeButton = this.createRemoveButton(fileId);
    const img = this.createImg(imageSrc, fileName);

    wrapper.appendChild(removeButton);
    wrapper.appendChild(img);
  }

  createImg(imageSrc, fileName) {
    const img = document.createElement("img");
    img.src = imageSrc;
    img.alt = fileName;
    return img;
  }

  showErrorOnPreview(wrapper) {
    wrapper.innerHTML =
      "<p class='text-red-500 text-sm'>エラーが発生しました。</p>";
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
