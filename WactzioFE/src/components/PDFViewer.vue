<template>
    <div><div id="pspdf" :hidden="this.store.currentFile.length === 0">
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
        <button class="toggle-bboxes-button" @click="toggleBboxesView()">
          <span class="text">Toggle Bounding Boxes</span>
        </button>
        <div class="pdf-container"></div>
    </div>
    <div id="welcome" :hidden="this.store.currentFile.length !== 0">
      <p>Welcome to Wactz.io! To get started, expand the sidebar, click "Generate Sample", and click on 
        one of the generated documents to load it.
      </p>
    </div></div>
</template>

<script setup>
  import PSPDFKit from "pspdfkit";
  import { computed } from "vue";
  import { useFileMgrStore } from "../stores/fileMgr"
  const store = useFileMgrStore()
  const currentFileWatch = computed(() => store.currentFile ) // can't directly watch a store variable, so use computed
  let currInstance = null // store instance for use later

  let bboxes = // not accurate, just to make sure loading works
  [
    [
      [100,100,200,200], // flow 0
      [250,250,350,350], // flow 1
      [400,400,500,500]  // flow 2
    ], // page 0
    [
      [50,50,150,150], // flow 0
    ], // page 1
    [
      [50,50,350,100],   // flow 0
      [375,375,400,400], // flow 1
    ]  // page 2
  ]

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
    async toggleBboxesView() { // for current page only (FIXME?)
      if (this.currInstance) { // make sure instance exists before modifying it
        let currentPage = this.currInstance.viewState.currentPageIndex
        const annotations = await this.currInstance.getAnnotations(currentPage)
        annotations.forEach((annotation) => {
          if (annotation.subject === "bounding-box") {
            this.currInstance.update(annotation.set("noView", !annotation.noView).set("noPrint", !annotation.noPrint))
          }
        })
      }
    },
    prevDoc() {
      this.store.currentIndex--
    },
    nextDoc() {
      this.store.currentIndex++
    },
    loadDoc() { // Will load PDF and its annotations (currenly only loads PDF)
      console.log("PDFViewer.vue: Loading PDF with name",this.store.currentFile)
      PSPDFKit.unload(".pdf-container")
      PSPDFKit.load({
        document: this.store.currentFile,
        container: ".pdf-container",
        disableWebAssemblyStreaming: true,
        isEditableAnnotation: function(annotation) { // prevents editing only the bounding box annotations
          return annotation.subject !== "bounding-box";
        },
      }).then(async (instance) => { // start of annotation loading   
        this.currInstance = instance // store instance for use later
        // create annotations
        for (let page = 0; page < this.bboxes.length; page++) { // iterate through pages
          for (let flow = 0; flow < this.bboxes[page].length; flow++) { // iterate through flows
            // this.bboxes[page][flow] = [xMin, yMin, xMax, yMax]
            const annotation = new PSPDFKit.Annotations.RectangleAnnotation({ // rectangle annotation definition
                pageIndex: page,
                boundingBox: new PSPDFKit.Geometry.Rect({
                  left: this.bboxes[page][flow][0],                                // xMin
                  top: this.bboxes[page][flow][1],                                 // yMin
                  width: this.bboxes[page][flow][2] - this.bboxes[page][flow][0],  // xMax - xMin
                  height: this.bboxes[page][flow][3] - this.bboxes[page][flow][1], // yMax - yMin
                }),
                fillColor: PSPDFKit.Color.BLUE,
                opacity: 0.5,
                isEditable: false,
                subject: "bounding-box"
            }) // end of rectangle annotation definition
            instance.create(annotation) // actually create the annotation
          } // end of iterating through flows
        } // end of iterating through pages
      }) // end of annotation loading
    },
    getFileName() {
      if (this.store.currentFile) {
        let encodedName = this.store.currentFile.substring(this.store.currentFile.lastIndexOf("/")+1,) // Gets a substring of everything after the last "/"
        return encodedName.replaceAll("%20", " ") // Removes the URL encoding "%20"
      }
      return ""
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
.prev-button, .next-button, .toggle-bboxes-button {
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

.text {
        font-family: "Times New Roman", Times, serif;
        font-size: 1.5rem;
        color: var(--light);
        display: block;
}
</style>

