import { defineStore } from "pinia"

export const useCompanyMgrStore = defineStore("companyMgr", {
    state: () => {
        return { currentCompanyName: "" }
    },
});