import { defineStore } from "pinia"

export const useFileMgrStore = defineStore("fileMgr", {
    state: () => {
        return { currentFile: "", currentIndex: -1, arrayLength: 0 }
    },
});