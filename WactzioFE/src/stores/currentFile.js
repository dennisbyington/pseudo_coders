import { defineStore } from "pinia";

export const useCurrentFileStore = defineStore("currentFile", {
    state: () => {
        return { currentFile: "abc" };
    },
    actions: {
        set(val) {
            this.currentFile = val;
        },
    },
});