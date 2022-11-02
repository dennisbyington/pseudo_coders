<template>
    <div id="pspdf">
        <button class="prev-button" @click="prevDoc" :disabled="isMinIndex()">
            <span class="material-symbols-outlined">
                keyboard_arrow_left
            </span>
        </button>
        <h2>{{getFileName()}}</h2>
        <button class="next-button" @click="nextDoc" :disabled="isMaxIndex()">
            <span class="material-symbols-outlined">
                keyboard_arrow_right
            </span>
        </button>
        <PSPDFKitContainer :pdfFile="pdfFile" @loaded="handleLoaded" />
    </div>
</template>

<script setup>
  import { computed } from "vue";
  import { useCurrentFileStore } from "../stores/currentFile"
  import { useCurrentIndexStore } from "../stores/currentIndex"
  const store = useCurrentFileStore()
  const indexStore = useCurrentIndexStore()
  const currentFileWatch = computed(() => store.currentFile ) // can't directly watch a store variable, so use computed
</script>

<script>
import PSPDFKitContainer from "./PSPDFKitContainer.vue"

export default {
  data() {
    return {
      pdfFile: "-", // "-" used as a placeholder document name (doesn't actually load a document)
    }
  },
  /**
   * Render the `PSPDFKitContainer` component.
   */
  components: {
    PSPDFKitContainer,
  },
  mounted() { // needed when first loading a PDF file (otherwise watch statement below won't act in time)
    this.pdfFile = this.store.currentFile
  },
  watch: {
    currentFileWatch(val) {
      if (val) {
        console.log("PDFViewer.vue: this.currentFile (which holds this.store.currentFile) has changed.")
        console.log("PDFViewer.vue: Setting this.pdfFile to",this.store.currentFile)
        this.pdfFile = this.store.currentFile
      }
    },
  },
  methods: {
    handleLoaded(instance) { // Currently just for logging
      console.log("PDFViewer.vue: PSPDFKit has been initialized, loading", this.pdfFile)
    },
    prevDoc() {
      console.log("LEFT")
      this.indexStore.currentIndex--
    },
    nextDoc() {
      console.log("RIGHT")
      this.indexStore.currentIndex++
    },
    /**
     * Gets a substring of everything after the last "/",
     * might need to change later for different URLS (FIXME)
     */
    getFileName() {
      //return this.pdfFile.substr(22,) // removes "http://localhost:5173/"
      return this.pdfFile.substring(this.pdfFile.lastIndexOf("/")+1,)
    },
    isMinIndex() { // determines whether to disable previous button (can't go further back)
      if (this.indexStore.currentIndex <= 0) {
        return true
      }
      return false
    },
    isMaxIndex() { // determines whether to disable next button (can't go further forward)
      if (this.indexStore.currentIndex >= this.indexStore.arrayLength - 1) {
        return true
      }
      return false
    }

  },
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  text-align: center;
  color: #2c3e50;
}

body {
  margin: 0;
}

input[type="file"] {
    display: none;
}

.custom-file-upload {
    border: 1px solid #ccc;
    border-radius: 4px;
    display: inline-block;
    padding: 6px 12px;
    cursor: pointer;
    background:#4A8FED;
    padding:10px;
    color:#fff;
    font:inherit;
    font-size: 16px;
    font-weight: bold;
}
</style>

<style lang="scss" scoped>
.material-symbols-outlined {
    font-size: 2rem;
    color: var(--light);
    transition: 0.2 ease-out;
}
.prev-button, .next-button {
    display: inline;
    align-items: center;
    padding: 0.5rem 1rem;
    margin: 1.5rem; 
    background-color: var(--dark);
    &:hover {
        background-color: var(--dark-alt);
    }
}
.prev-button:disabled, .next-button:disabled {
    background-color: gray;
}

h2 {
    display: inline-block;
    position: relative;
    top: -7px;
    width: 250px;
    max-width: 250px;
}
</style>