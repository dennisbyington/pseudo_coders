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
                <button v-for="(company, i) in items" :key="i" class="menu-button">
                    <a>{{ company.title }}</a>
                </button>
            </div>
        </transition>
    </button>
</template>


<script dropdown-script>

import { ref } from "vue"
import { computed } from "vue"
import { useCompanyMgrStore } from "../stores/companyMgr.js"

//const companyStore = useCompanyMgrStore()
//const currentIndexWatch = computed(() => comp.currentID ) // can't directly watch a store variable, so use computed

export default {
    name: 'dropdown',
    props: ['title', 'items'],
    data () {
        return {
            
            isOpen: false
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