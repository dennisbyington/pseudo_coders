<template>
  <aside :class="`${is_expanded && 'is-expanded'}`">
    <!--<div class="logo">
        <img src="../assets/logo.svg" alt="Vue">
    </div>-->

    <div class="menu-toggle-wrap">
        <button class="menu-toggle" @click="ToggleMenu">
            <span class="material-symbols-outlined">
                keyboard_double_arrow_right
            </span>
        </button>
    </div>

    <h3>Menu</h3>
    <div class="menu">
        <router-link class="home-button" to="/">
            <span class="material-symbols-outlined">
                home
            </span>
            <span class="text">Home</span>
        </router-link>
        <router-link to="/about" class="about-button">
            <span class="material-symbols-outlined">
                info
            </span>
            <span class="text">About</span>
        </router-link>
        <button class="gen-sample" @click="generateSample" >
            <span class="material-symbols-outlined">
                autorenew
            </span>
            <span class="text">Generate Sample</span>
        </button>
        <button class="random-sample" @click="randomSample" >
            <span class="material-symbols-outlined">
                autorenew
            </span>
            <span class="text">Random Sample</span>
        </button>
        <button class="clear-sample" @click="clearSample(true)" >
            <span class="material-symbols-outlined">
                close
            </span>
            <span class="text">Clear Sample</span>
        </button>
        <button class="sample-doc" v-for="document in sampleDocuments" :key="document.id" @click="setDoc(document.id)">
            <span class="material-symbols-outlined">
                description
            </span>
            <span class="text">{{ document.text }}</span>
        </button>
    </div>
  </aside>
  
</template>

<script setup>
    import { ref } from "vue"
    import { computed } from "vue"
    import { useFileMgrStore } from "../stores/fileMgr"
    import { useCompanyMgrStore } from "../stores/companyMgr.js"
  
    const is_expanded = ref(false)

    const ToggleMenu = () => {
        is_expanded.value = !is_expanded.value
    }

    const store = useFileMgrStore()
    const currentIndexWatch = computed(() => store.currentIndex ) // can't directly watch a store variable, so use computed

    const comp = useCompanyMgrStore()
    const currentCompanyIDWatch = computed(() => comp.currentID ) // can't directly watch a store variable, so use computed

    let dummyArray = []
    
</script>

<script sample-documents>
let id = 1

export default {
    data() {
        return {
        newSampleDocument: 'Document',
        sampleDocuments: [

            ]
        }
    },
    watch: {
        currentIndexWatch(val) { // Store variable currentIndex has changed - load the document from that index in the document array
            if (val >= 0 && val < this.store.arrayLength) { // must be valid index
                console.log("Sidebar.vue has index",val,"- Loading document",val+1)
                let docName = this.dummyArray[this.store.currentIndex][2] // [0] company id, [1] doc ID, [2] URL
                this.store.backendCompanyID = this.dummyArray[this.store.currentIndex][0]
                this.store.backendDocID = this.dummyArray[this.store.currentIndex][1]
                console.log("Sidebar.vue: Setting this.store.currentFile to", docName)
                this.store.currentFile = docName
            }
        },
    },
    methods: {
        addSampleDocument(index, element) {
            this.sampleDocuments.push({ id: index, text: element })
        },
        generateSample() {
            // removes old sample for now (FIXME later?)
            this.clearSample(false) // don't ask for confirmation

            if(this.currentCompanyIDWatch === 0) {
                let currIndex = 0
                this.$axios.get("http://localhost:3000/api/v0/companies/").then( companiesResult => {
                    companiesResult.data.forEach((tempCompany) => {
                        this.$axios.get("http://localhost:3000/api/v0/companies/" + tempCompany.id).then( companyResult => {
                            companyResult.data.urls.forEach((pdf_result) => {
                                console.log("PDF",tempCompany.id,"-",pdf_result[0],"is located at",pdf_result[1])
                                this.dummyArray.push([tempCompany.id, pdf_result[0], pdf_result[1]])
                                this.addSampleDocument(currIndex++, this.formatFileName(pdf_result[1])) // add to sidebar view
                            })
                        })
                    })
                })
            }
            else {
                this.$axios.get("http://localhost:3000/api/v0/companies/" + this.currentCompanyIDWatch).then( companyResult => {
                    companyResult.data.urls.forEach((pdf_result, index) => { // pdf_result[0] is doc ID, pdf_result[1] is the URL
                        console.log("PDF",this.currentCompanyIDWatch,"-",pdf_result[0],"is located at",pdf_result[1])
                        this.dummyArray.push([this.currentCompanyIDWatch, pdf_result[0], pdf_result[1]])
                        this.addSampleDocument(index, this.formatFileName(pdf_result[1])) // add to sidebar view
                    })
                })
            }
        },
        randomSample() {
            // removes old sample for now (FIXME later?)
            this.clearSample(false) // don't ask for confirmation

            alert("Need random sample from backend") // FIXME - need backend to accept random sample request (see format below)
            // if(this.currentCompanyIDWatch === 0) {
            //     alert("Please select a company first.") // currently random sample pulls from only one company (FIXME?) 
            // }
            // else {
            //     this.$axios.get("http://localhost:3000/api/v0/companies/random/" + this.currentCompanyIDWatch).then( companyResult => {
            //         companyResult.data.urls.forEach((pdf_result, index) => { // pdf_result[0] is doc ID, pdf_result[1] is the URL
            //             console.log("PDF",this.currentCompanyIDWatch,"-",pdf_result[0],"is located at",pdf_result[1])
            //             this.dummyArray.push([this.currentCompanyIDWatch, pdf_result[0], pdf_result[1]])
            //             this.addSampleDocument(index, this.formatFileName(pdf_result[1])) // add to sidebar view
            //         })
            //     })
            // }
        },
        removeSampleDocument(document) {
            this.sampleDocuments = this.sampleDocuments.filter((t) => t !== document)
        },
        clearSample(askFirst) {
            if (!askFirst || confirm("Are you sure you want to clear the current sample?")){
                this.dummyArray = []
                this.store.currentIndex = -1
                this.store.arrayLength = 0
                this.sampleDocuments.splice(document)
            }
        },
        async setDoc(docID){ // Sets store variables (arrayLength disables "next" button, currentIndex is tracked - changes trigger loadDoc())
            if (this.$route.path !== "/") { // Need to redirect to main page, then change the index and file
                await this.$router.push("/")
            }
            this.store.arrayLength = this.dummyArray.length // FIXME - currently uses dummy array
            this.store.currentIndex = docID                 // might go from document.id (docID) to currentIndex differently later on
        },
        formatFileName(myFile) { 
             let encodedName = myFile.substring(myFile.lastIndexOf("/")+1,) // removes URL portion: "http://localhost:5173/docs/SAMPLE.pdf" --> "SAMPLE.pdf"
             return encodedName.replaceAll("%20", " ") // Removes the URL encoding "%20"
        }
    }
}
</script>

<style lang="scss" scoped>
aside {
    float: left;
    display: flex;
    flex-direction: column;
    width: calc(2rem + 32px);
    min-height: calc(100vh - var(--topbar-height));
    overflow: hidden;
    padding: 1rem;

    background-color: var(--dark);
    color: var(--light);

    transition: 0.2s ease-out;

    .logo {
        margin-bottom: 1rem;

        img {
            width: 2rem;
        }
    }

    .menu-toggle-wrap {
        display: flex;
        justify-content: flex-end;
        margin-bottom: 1rem;

        position: relative;
        top: 0;
        transition: 0.2s ease-out;

        &:hover {
                .material-symbols-outlined {
                    color: var(--primary);
                    transform: translateX(0.5rem);
                }
            }

        .menu-toggle {
            transition: 0.2s ease-out;

            .material-symbols-outlined {
                font-size: 2rem;
                color: var(--light);
            }

            &:hover {
                .material-symbols-outlined {
                    transition: 0.2s;
                    color: var(--primary);
                    transform: translateX(0.5rem);
                }
            }
            &:not(hover) {
                .material-symbols-outlined {
                    transition: 0.2s;
                }
            }
        }
    }

    .text, h3 {
        font-family: "Times New Roman", Times, serif;
        font-size: 2rem;
        color: var(--light);
        opacity: 0;
        transition: 0.3s ease-out;
    }

    .menu {
        max-height: 75vh;
        overflow-y: auto;
        overflow-x: hidden;
        margin: 0 -1rem;
        .material-symbols-outlined {
            font-size: 2rem;
            color: var(--light);
            transition: 0.2 ease-out;
        }
        .home-button, .about-button, .gen-sample, .random-sample, .sample-doc, .clear-sample {
            display: flex;
            align-items: center;
            text-decoration: none;
            padding: 0.5rem 1rem;
            min-width: 100vw;

            &:hover {
                background-color: var(--dark-alt);
                transition: 0.2s;
            }
            
            &:not(hover) {
                transition: 0.2s;
            }

            .text {
                padding-left: 0.5rem;
            }
        }
    }

    &.is-expanded {
        width: var(--sidebar-width);

        .menu-toggle-wrap {
            //top: -3rem;
            .menu-toggle {
                transform: rotate(-180deg);
            }
        }

        .text, h3 {
            opacity: 1;
        }
    }

    @media (max-width: 768px) {
        position: fixed;
        z-index: 99;
    }
}
</style>
