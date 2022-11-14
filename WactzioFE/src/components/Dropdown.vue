<template>
    <button class="menu-button" @click="isOpen = !isOpen">
        <a>
            {{ title }}
        </a>
        <span class="material-symbols-outlined">
            expand_more
        </span>
        <transition name="fade" appear>
            <div class="sub-menu" v-if="isOpen" @mouseleave="isOpen = false">
                <button v-for="(company, i) in items" :key="i" class="menu-button" @click="setCompany(company)">
                    <a>{{ company.title }}</a>
                </button>
            </div>
        </transition>
    </button>
</template>


<script setup>

import { ref } from "vue"
import { computed } from "vue"
import { useCompanyMgrStore } from "../stores/companyMgr.js"

const comp = useCompanyMgrStore()
//const currentIDwatch = computed(() => comp.currentID ) // can't directly watch a store variable, so use computed

</script>

<script dropdown-script>

export default {
    name: 'dropdown',
    props: ['title', 'items'],
    data () {
        return {
            
            isOpen: false
        }
    },
    methods:
    {
        setCompany(company) {
            this.comp.currentCompanyName = company.title;
            this.comp.currentID = company.id;
        }
    }
}
</script>

<style>
.sub-menu {
    position: absolute;
    background-color: var(--topbar-bgcolor);
    top: calc(100% + 3px);
    align-content: center;
}

.sub-menu.menu-button {
    width: 100%;
}

.fade-enter-active, .fade-leave-active {
    transition: all .1s ease-out;
}

.fade-enter-from, .fade-leave-to {
    opacity: 0;
}


</style>