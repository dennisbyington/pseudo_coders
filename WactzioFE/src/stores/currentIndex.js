import { defineStore } from "pinia"

export const useCurrentIndexStore = defineStore("currentIndex", {
    state: () => {
        return { currentIndex: -1, arrayLength: 0 } // dummy values for loading initial document
    },
    actions: {
        setIndex(val) {
            this.currentIndex = val
        },
        setLength(val) {
            this.arrayLength = val
        },
    },
});