<template>
    <div id="pspdf" :hidden="this.store.currentIndex < 0">
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
        <div class="pdf-container"></div>
    </div>
    <div id="welcome" :hidden="this.store.currentIndex >= 0">
      <p>Welcome to Factz.io! To get started, expand the sidebar, click "Generate Sample", and click on 
        one of the generated documents to load it.
      </p>
    </div>
</template>

<script setup>
  import PSPDFKit from "pspdfkit";
  import { computed } from "vue";
  import { useFileMgrStore } from "../stores/fileMgr"
  const store = useFileMgrStore()
  const currentFileWatch = computed(() => store.currentFile ) // can't directly watch a store variable, so use computed
</script>

<script>

export default {
  mounted() { // currently just for logging
    console.log("PDFViewer has mounted.")
  },
  beforeUnmount() {
    PSPDFKit.unload(".pdf-container")
    /** Resets store variables to dummy values - otherwise loading a document, leaving main page to about page,
     *  and clicking on the same document will not properly load it: store variables won't change, so the watch won't
     *  trigger (FIXME?)
     * */ 
    this.store.currentFile = ""
    this.store.currentIndex = -1
  },
  watch: {
    currentFileWatch(val) { // used for loading documents accessed through home page
      if (val) {
        this.loadDoc()
      }
    },
  },
  methods: {
    async loadPSPDFKit() {
      PSPDFKit.unload(".pdf-container")
      // return statement present: in loadDoc(), put this.loadPSPDFKit().then(async (instance) => { annotation stuff })
      // or remove return statement: in this function, put PSPDFKit.load(stuff).then(async (instance) => { annotation stuff})
      return PSPDFKit.load({
        document: this.store.currentFile,
        container: ".pdf-container",
        disableWebAssemblyStreaming: true,
        //initialViewState: new PSPDFKit.ViewState({ readOnly: true }), // prevents editing annotations
      })
    },
    prevDoc() {
      this.store.currentIndex--
    },
    nextDoc() {
      this.store.currentIndex++
    },
    loadDoc() {
      if (this.store.currentFile) { // needs to have a file to load
        console.log("PDFViewer.vue: Loading PDF with name",this.store.currentFile)
        this.loadPSPDFKit().then(async (instance) => { // start of then   

          // create annotations
          // [1,2].forEach(async (item) => {
          //   const annotation = new PSPDFKit.Annotations.RectangleAnnotation({
          //       pageIndex: 0,
          //       boundingBox: new PSPDFKit.Geometry.Rect({
          //         left: 100*item,
          //         top: 100*item,
          //         width: 50,
          //         height: 50,
          //       }),
          //       fillColor: PSPDFKit.Color.BLUE,
          //       opacity: 0.5,
          //       isEditable: false,
          //   })
          //   const [createdAnnotation] = await instance.create(annotation);
          //   console.log(createdAnnotation.id); // => '01BS964AM5Z01J9MKBK64F22BQ'
          // })
 
          // import annotations
          // instance.applyOperations([ // start of import annotations block
          //   {
          //     type: "applyInstantJson",
          //     instantJson: {
          //       annotations: [
          //         {
          //           bbox: [100, 150, 200, 75],
          //           blendMode: "normal",
          //           createdAt: "1970-01-01T00:00:00Z",
          //           id: "01F73GJ4RPENTCMFSCJ5CSFT5G",
          //           name: "01F73GJ4RPENTCMFSCJ5CSFT5G",
          //           fillColor: "#2293FB",
          //           opacity: 0.5,
          //           pageIndex: 0,
          //           strokeColor: "#2293FB",
          //           strokeWidth: 5,
          //           type: "pspdfkit/shape/rectangle",
          //           updatedAt: "1970-01-01T00:00:00Z",
          //           v: 1
          //         },
          //         {
          //           bbox: [200, 250, 200, 75],
          //           blendMode: "normal",
          //           createdAt: "1970-01-01T00:00:00Z",
          //           id: "01F73GJ4RPENTCMFSCJ5CSFT5H",
          //           name: "01F73GJ4RPENTCMFSCJ5CSFT5H",
          //           fillColor: "#2293FB",
          //           opacity: 0.5,
          //           pageIndex: 0,
          //           strokeColor: "#2293FB",
          //           strokeWidth: 5,
          //           type: "pspdfkit/shape/rectangle",
          //           updatedAt: "1970-01-01T00:00:00Z",
          //           v: 1
          //         }
          //       ],
          //       format: "https://pspdfkit.com/instant-json/v1"
          //     }
          //   }
          // ]) // end of import annotations block

        }) // end of then
      }
    },
    getFileName() { // Gets a substring of everything after the last "/", might need to change later for different URLS (FIXME)
      if (this.store.currentIndex >= 0 && this.store.currentIndex < this.store.arrayLength) {
        return this.store.currentFile.substring(this.store.currentFile.lastIndexOf("/")+1,)
      }
      return "" // handle invalid or dummy indexes (see FIXME in beforeUnmount())
    },
    isMinIndex() { // determines whether to disable previous button (can't go further back)
      if (this.store.currentIndex <= 0) {
        return true
      }
      return false
    },
    isMaxIndex() { // determines whether to disable next button (can't go further forward)
      if (this.store.currentIndex >= this.store.arrayLength - 1) {
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
.pdf-container {
  height: 75vh;
}
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

#welcome {
  padding: 1.5rem;
}

h2 {
    display: inline-block;
    position: relative;
    top: -7px;
    width: 250px;
    max-width: 250px;
}
</style>