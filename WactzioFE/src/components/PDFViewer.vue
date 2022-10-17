<template>
    <div id="pspdf">
        <button class="prev-button">
            <span class="material-symbols-outlined" @click="prevTest">
                keyboard_arrow_left
            </span>
        </button>
        <h2>{{getFileName()}}</h2>
        <button class="next-button">
            <span class="material-symbols-outlined" @click="nextTest">
                keyboard_arrow_right
            </span>
        </button>
        <PSPDFKitContainer :pdfFile="pdfFile" @loaded="handleLoaded" />
    </div>
</template>

<script>
import PSPDFKitContainer from "./PSPDFKitContainer.vue";

export default {
  data() {
    return {
      pdfFile: this.pdfFile || "http://localhost:5173/document.pdf",
    };
  },
  /**
   * Render the `PSPDFKitContainer` component.
   */
  components: {
    PSPDFKitContainer,
  },
  methods: {
    handleLoaded(instance) { // Currently just for logging
      console.log("PSPDFKit has loaded: ", instance);
    },

    /**
     * When pdfFile changes, PSPDFKitContainer will automatically load
     * the new document. Testing - will need to provide the correct
     * document based on the button and the current document. (FIXME)
     */
    prevTest() {
      this.pdfFile = "http://localhost:5173/prev.pdf"
    },
    nextTest() {
      this.pdfFile = "http://localhost:5173/next.pdf"
    },
    /**
     * Currently removes the "http://localhost:5173/",
     * will need to change later for different URLS (FIXME)
     */
    getFileName() {
      return this.pdfFile.substr(22,)
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
h2 {
    display: inline;
    position: relative;
    top: -7px;
}
</style>