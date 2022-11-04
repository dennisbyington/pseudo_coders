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
        <button class="sample-doc" v-for="document in sampleDocuments" :key="document.id" @click="setDoc(document.id)">
            <span class="material-symbols-outlined">
                description
            </span>
            <span class="text">{{ document.text }}</span>
        </button>
        <button class="clear-sample" @click="clearSample" >
            <span class="material-symbols-outlined">
                close
            </span>
            <span class="text">Clear Sample</span>
        </button>
    </div>
  </aside>
  
</template>

<script setup>
    import { ref } from "vue"
    import { computed } from "vue"
    import { useFileMgrStore } from "../stores/fileMgr"
  
    const is_expanded = ref(false)

    const ToggleMenu = () => {
        is_expanded.value = !is_expanded.value
    }

    const store = useFileMgrStore()
    const currentIndexWatch = computed(() => store.currentIndex ) // can't directly watch a store variable, so use computed

    // FIXME - Hardcoded array of document URLs, would need to get from backend
    // instead (and probably move declaration somewhere else)
    let dummyArray = [
        "http://localhost:5173/docs/armadillo.pdf", "http://localhost:5173/docs/cat.pdf", "http://localhost:5173/docs/fish.pdf",
        "http://localhost:5173/docs/word.pdf", "http://localhost:5173/docs/understanding.pdf", "http://localhost:5173/docs/a.pdf",
        "http://localhost:5173/docs/4901.pdf", "http://localhost:5173/docs/hello world.pdf", "http://localhost:5173/docs/1-2-3.pdf",
        "http://localhost:5173/docs/loooooooooooooooong.pdf"
    ]
    let myA = []
    
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
                console.log("HERE")
                console.log("Sidebar.vue has index",val,"- Loading document",val+1)
                let docName = this.dummyArray[this.store.currentIndex] // FIXME - currently uses dummy array
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
            this.sampleDocuments.splice(document) // removes old sample for now (FIXME)
            this.dummyArray.forEach((element, index) => {
                this.addSampleDocument(index, this.formatFileName(element))
            })
        },
        removeSampleDocument(document) {
            this.sampleDocuments = this.sampleDocuments.filter((t) => t !== document)
        },
        clearSample() {
            this.store.currentIndex = -1
            this.store.arrayLength = 0
            this.sampleDocuments.splice(document)
        },
        async setDoc(docID){ // Sets store variables (arrayLength disables "next" button, currentIndex is tracked - changes trigger loadDoc())
            if (this.$route.path !== "/") { // Need to redirect to main page, then change the index and file
                await this.$router.push("/")
            }
            this.store.arrayLength = this.dummyArray.length // FIXME - currently uses dummy array
            this.store.currentIndex = docID                 // might go from document.id (docID) to currentIndex differently later on
        },
        formatFileName(myFile) { // removes URL portion: "http://localhost:5173/docs/SAMPLE.pdf" --> "SAMPLE.pdf"
             return myFile.substring(myFile.lastIndexOf("/")+1,)
        }
    }
}
</script>

<style lang="scss" scoped>
aside {
    display: flex;
    flex-direction: column;
    width: calc(2rem + 32px);
    min-height: 100vh;
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
                    color: var(--primary);
                    transform: translateX(0.5rem);
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
        margin: 0 -1rem;
        .material-symbols-outlined {
            font-size: 2rem;
            color: var(--light);
            transition: 0.2 ease-out;
        }
        .home-button, .about-button, .gen-sample, .sample-doc, .clear-sample {
            display: flex;
            align-items: center;
            text-decoration: none;
            padding: 0.5rem 1rem;
            min-width: 100vw;

            &:hover {
                background-color: var(--dark-alt);
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