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
        <button class="gen-sample" @click="generateSample" >
            <span class="material-symbols-outlined">
                autorenew
            </span>
            <span class="text">Generate Sample</span>
        </button>
        <router-link class="sample-doc" to="/" v-for="document in sampleDocuments" :key="document.id" @click="loadDoc(document.id)">
            <span class="material-symbols-outlined">
                description
            </span>
            <span class="text">{{ document.text }} {{ document.id }}</span>
        </router-link>
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
    import { ref } from 'vue'
    import { useCurrentFileStore } from "../stores/currentFile"

    const is_expanded = ref(false)

    const ToggleMenu = () => {
        is_expanded.value = !is_expanded.value
    }

    const store = useCurrentFileStore()
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
    methods: {
        addSampleDocument() {
            this.sampleDocuments.push({ id: id++, text: this.newSampleDocument })
        },
        generateSample() {
            var i = [1,2,3,4,5,6,7,8,9,10];
            i.forEach(number => {
                this.addSampleDocument()
            });
        },
        removeSampleDocument(document) {
            this.sampleDocuments = this.sampleDocuments.filter((t) => t !== document)
        },
        clearSample() {
            this.sampleDocuments.splice(document)
        },
        loadDoc(docID) {
            let docName = "http://localhost:5173/docs/" + docID + ".pdf"
            this.store.currentFile = docName
            console.log("sidebar")
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
        .home-button, .gen-sample, .sample-doc, .clear-sample {
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