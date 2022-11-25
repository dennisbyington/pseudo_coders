import { defineStore } from "pinia"

export const useFileMgrStore = defineStore("fileMgr", {
    state: () => {
        return { currentFile: "", backendCompanyID: -1, backendDocID: -1, currentIndex: -1, arrayLength: 0 }
    },
});