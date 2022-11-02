<template>
  <div class="pdf-container"></div>
</template>

<script>
import PSPDFKit from "pspdfkit";

/**
 * PSPDFKit for Web example component.
 */
export default {
  name: "PSPDFKit",
  /**
	 * The component receives `pdfFile` as a prop, which is type of `String` and is required.
	 */
  props: {
    pdfFile: {
      type: String,
      required: true,
    },
  },
  /**
	 * We watch for `pdfFile` prop changes and trigger unloading and loading when there's a new document to load.
	 */
  watch: {
    pdfFile(val) {
      if (val) {
        console.log("PSPDFKitContainer.vue: this.pdfFile has changed.")
        console.log("PSPDFKitContainer.vue: Loading PDF with name",this.pdfFile)
        this.loadPSPDFKit()
      }
    },
  },
  /**
	 * Our component has the `loadPSPDFKit` method. This unloads and cleans up the component and triggers document loading.
	 */
  methods: {
    async loadPSPDFKit() {
      PSPDFKit.unload(".pdf-container")
      return PSPDFKit.load({
        // access the pdfFile from props
        document: this.pdfFile,
        container: ".pdf-container",
        disableWebAssemblyStreaming: true,
      });
    },
  },

  /**
	 * Clean up when the component is unmounted so it's ready to load another document (not needed in this example).
	 */
  beforeUnmount() {
    PSPDFKit.unload(".pdf-container")
  },
};
</script>


<style scoped>
.pdf-container {
  height: 75vh;
}
</style>