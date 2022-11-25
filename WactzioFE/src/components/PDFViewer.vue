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
  import PSPDFKit from "pspdfkit";
  import { computed } from "vue";
  import { useFileMgrStore } from "../stores/fileMgr"
  const store = useFileMgrStore()
  const currentFileWatch = computed(() => store.currentFile ) // can't directly watch a store variable, so use computed
  let bboxes = []

  const bboxIconVisible = `<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20" fill="cornflowerblue" stroke="cornflowerblue" stroke-width="2"><rect width="20" height="20" /></svg>`
  const bboxIconHidden = `<svg xmlns="http://www.w3.org/2000/svg" height="20" width="20" fill="none" stroke="cornflowerblue" stroke-width="2"><rect width="20" height="20" /></svg>`
  let toggleBboxesItem = { // toolbar button to toggle bounding box visibility
    type: "custom",
    id: "toggle-bboxes",
    title: "Toggle Bounding Boxes",
    icon: bboxIconVisible,
    buttonInstance: null,
    setInstance(newInstance) {
      this.buttonInstance = newInstance
    },
    async onPress() {
      let tempInstance = toggleBboxesItem.buttonInstance
      if (tempInstance) { // make sure instance exists before modifying it
        // show/hide the annotations as needed
        for (let page = 0; page < tempInstance.totalPageCount; page++) {
          const annotations = await tempInstance.getAnnotations(page)
          annotations.forEach((annotation) => {
            if (annotation.subject === "bounding-box") {
              tempInstance.update(annotation.set("noView", !annotation.noView).set("noPrint", !annotation.noPrint))
            }
          })
        }
        // change the button's appearance to match the current visibility of the annotations
        tempInstance.setToolbarItems(toolbarItems =>
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

    // Setting these to default just in case (FIXME?)
    this.store.backendCompanyID = -1
    this.store.backendDocID = -1
  },
  watch: {
    currentFileWatch(val) { // used for loading documents accessed through home page
      if (val) {
        PSPDFKit.unload(".pdf-container") // Hide old PDF
        this.axiosBboxThenLoad(3) // try to get bboxes from backend then load document, 3 attempts max
      }
    },
  },
  methods: {
    axiosBboxThenLoad(max_retries) {
      if (max_retries <= 0) { // No more attempts, display error
        alert("Error: Unable to load bounding boxes for this document.")
      }
      else {
        this.$axios.get("http://localhost:3000/api/v0/companies/bbox/" + this.store.backendCompanyID + "/" + this.store.backendDocID).then( bboxResult => {
            this.bboxes = bboxResult.data // Store the bbox data
            if (this.bboxes.length > 0) { // Successfully got bbox data
              this.loadDoc()              // Load the PDF
            }
            else { // Failure, try loading again
              this.axiosBbox(max_retries - 1)
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
    createAnnotations(storedInstance) {
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
          storedInstance.create(annotation) // actually create the annotation
        } // end of iterating through flows
      } // end of iterating through pages
    },
    loadDoc() { // Will load PDF and create annotations
      let storedInstance = null
      PSPDFKit.load({
        document: this.store.currentFile,
        container: ".pdf-container",
        disableWebAssemblyStreaming: true,
        toolbarItems: [...PSPDFKit.defaultToolbarItems, this.toggleBboxesItem],
        isEditableAnnotation: function(annotation) { // prevents editing only the bounding box annotations
          return annotation.subject !== "bounding-box";
        },
      }).then(async (instance) => { // annotation loading   
        storedInstance = instance                         // need to store for use in toggling bounding box visibility, loading annotations
        this.toggleBboxesItem.setInstance(storedInstance) // needed for toggle to work properly
        this.createAnnotations(storedInstance)            // create the annotations
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

