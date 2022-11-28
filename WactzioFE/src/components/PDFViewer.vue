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
        <div class="pdf-container"></div>
    </div>
    <div id="welcome" :hidden="this.store.currentFile.length !== 0">
      <p>Welcome to Wactz.io! To get started, expand the sidebar, click "Generate Sample", and click on 
        one of the generated documents to load it.
      </p>
    </div></div>
</template>

<script setup>
  import PSPDFKit, { ViewState } from "pspdfkit";
  import { computed } from "vue";
  import { useFileMgrStore } from "../stores/fileMgr"
  const store = useFileMgrStore()
  const currentFileWatch = computed(() => store.currentFile ) // can't directly watch a store variable, so use computed
  let bboxes = []
  let annotationsLoaded = [] // keep track of which pages have annotations loaded
  let storedInstance = null  // need to store for use in toggling bounding box visibility, loading annotations

  const bboxIconVisible = `<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20" fill="cornflowerblue" stroke="cornflowerblue" stroke-width="2"><rect width="20" height="20" /></svg>`
  const bboxIconHidden = `<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20" fill="none" stroke="cornflowerblue" stroke-width="2"><rect width="20" height="20" /></svg>`
  let bboxesItem = { // toolbar button to toggle bounding box visibility
    type: "custom",
    id: "toggle-bboxes",
    title: "Toggle Bounding Boxes",
    icon: bboxIconVisible,
    buttonInstance: null,
    boxesVisible: true,
    visFunction() {
      // console.log("Visibility function not yet set.")
    },
    setInstance(newInstance) {
      this.buttonInstance = newInstance
    },
    setVisFunction(newFunction) {
      this.visFunction = newFunction
    },
    async onPress() {
      if (bboxesItem.buttonInstance) { // make sure instance exists before modifying it
        bboxesItem.boxesVisible = !bboxesItem.boxesVisible                           // keeps track of whether to show/hide annotations
        bboxesItem.visFunction(bboxesItem.buttonInstance.viewState.currentPageIndex, bboxesItem.boxesVisible) // toggle visibility for current page
        // change the button's appearance to match the current visibility of the annotations
        bboxesItem.buttonInstance.setToolbarItems(toolbarItems =>
          toolbarItems.map(tempItem => {
            if (tempItem.id === "toggle-bboxes") {
              tempItem.icon = (tempItem.icon === bboxIconVisible) ? bboxIconHidden : bboxIconVisible
            }
            return tempItem;
          })
        )
      }
    }
  } // end of toolbar button
</script>

<script>

export default {
  mounted() { // currently just for logging
    // console.log("PDFViewer has mounted.")
  },
  beforeUnmount() {
    PSPDFKit.unload(".pdf-container")
    /** Resets store variables to dummy values - otherwise loading a document, leaving main page to about page,
     *  and clicking on the same document will not properly load it: store variables won't change, so the watch won't
     *  trigger (FIXME?)
     * */ 
    this.store.currentFile = ""
    this.store.currentIndex = -1

    // Setting these to default just in case (FIXME?)
    this.store.backendCompanyID = -1
    this.store.backendDocID = -1
  },
  watch: {
    currentFileWatch(val) { // used for loading documents accessed through home page
      if (val) {
        PSPDFKit.unload(".pdf-container") // Hide old PDF
        this.bboxes = [] // Reset bbox array
        this.axiosBboxThenLoad(3) // Try to get bboxes from backend then load document, 3 attempts max
      }
    },
  },
  methods: {
    axiosBboxThenLoad(retries) {
      if (retries <= 0) { // No more attempts, display error
        alert("Error: Unable to load bounding boxes for this document.")
      }
      else {
        this.$axios.get("http://localhost:3000/api/v0/companies/bbox/" + this.store.backendCompanyID + "/" + this.store.backendDocID).then( bboxResult => {
            this.bboxes = bboxResult.data // Store the bbox data
            if (this.bboxes.length > 0) { // Successfully got bbox data
              this.loadDoc()              // Load the PDF
            }
            else { // Failure, try loading again
              this.axiosBboxThenLoad(retries - 1)
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
    createAnnotationsForPage(currPage) { // create annotations for the specified page (if not yet created)
      let minPage = (currPage - 2 >= 0) ? currPage - 2 : 0
      let maxPage = (currPage + 2 <= this.storedInstance.totalPageCount - 1) ? currPage + 2 : this.storedInstance.totalPageCount - 1

      for (let page = minPage; page <= maxPage; page++) { // load pages adjacent to current page to reduce pop-in
        if (this.annotationsLoaded[page] === false) { // if annotations not already loaded
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
            this.storedInstance.create(annotation) // actually create the annotation
          } // end of iterating through flows
          this.annotationsLoaded[page] = true // mark page so annotations not loaded again
        }
      }
    },
    async setAnnotationVisForPage(currPage) { // set visibility of bboxes on page
      let minPage = (currPage - 2 >= 0) ? currPage - 2 : 0
      let maxPage = (currPage + 2 <= this.storedInstance.totalPageCount - 1) ? currPage + 2 : this.storedInstance.totalPageCount - 1
      let visible = this.bboxesItem.boxesVisible // determine whether to show/hide

      for (let page = minPage; page <= maxPage; page++) { // load pages adjacent to current page to reduce pop-in
        if (this.annotationsVisible[page] !== visible) { // if annotations not already shown/hidden
          const annotations = await this.storedInstance.getAnnotations(page)
          annotations.forEach((annotation) => {
            if (annotation.subject === "bounding-box") {
              this.storedInstance.update(annotation.set("noView", !visible).set("noPrint", !visible))
            }
          })
          this.annotationsVisible[page] = visible // mark page so annotations not changed unnecessarily
        } 
      }
    },
    loadDoc() { // Will load PDF and create annotations
      PSPDFKit.load({
        document: this.store.currentFile,
        container: ".pdf-container",
        disableWebAssemblyStreaming: true,
        toolbarItems: [...PSPDFKit.defaultToolbarItems, this.bboxesItem],
        isEditableAnnotation: function(annotation) { // prevents editing only the bounding box annotations
          return annotation.subject !== "bounding-box";
        },
      }).then(async (instance) => { // annotation loading
        this.storedInstance = instance                         // need to store for use in toggling bounding box visibility, loading annotations
        this.bboxesItem.setInstance(this.storedInstance) // needed for toggle to work properly
        this.bboxesItem.setVisFunction(this.setAnnotationVisForPage)

        this.annotationsLoaded = Array(this.storedInstance.totalPageCount).fill(false) // keep track of which pages have annotations loaded
        this.annotationsVisible = Array(this.storedInstance.totalPageCount).fill(true) // keep track of which pages have annotations visible

        // when page changes, create annotations / change annotation visibility if needed
        this.storedInstance.addEventListener("viewState.currentPageIndex.change", this.createAnnotationsForPage)
        this.storedInstance.addEventListener("viewState.currentPageIndex.change", this.setAnnotationVisForPage)

        this.createAnnotationsForPage(0)         // create the annotations for the initial page
      })
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

