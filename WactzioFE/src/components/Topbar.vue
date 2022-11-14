<template>
    <nav>
        <!--<button class="menu-button">
            <a>Select Company</a>
            <span class="material-symbols-outlined">
                expand_more
            </span>
        </button>-->
        <div class="wactz" >
            <span class="material-symbols-sharp">
                done_all
            </span>
            <text>ACTZ.IO</text>
        </div>
        <!--<dropdown title="Companies" :items="companies" @click.once="axiosGetCompanies" />-->
        <dropdown :title="this.comp.currentCompanyName" :items="companies" @click.once="axiosGetCompanies" />
    </nav>
</template>

<script setup>


import { ref } from "vue"
import { computed } from "vue"
import { useCompanyMgrStore } from "../stores/companyMgr.js"

const comp = useCompanyMgrStore()

</script>


<script drop>
import axios from 'axios';
import Dropdown from './Dropdown.vue';

export default {
    name: 'topbar',
    components: { Dropdown },
    data () {
        return {
            isEmpty: true,
            companies: [ ]
        }
    },
    methods: {
        axiosGetCompanies() {
            console.log("AXIOS GET COMPANIES")
            this.$axios.get("http://localhost:3000/api/v0/companies/").then( companiesResult => {
                companiesResult.data.forEach((tempCompany) => {
                    this.companies.push({ title: tempCompany.name,  id: tempCompany.id })
                })
            })
            this.isEmpty = false;
        },
    }
}
</script>

<style lang="scss">

nav {
    display: flex;
    width: 100vw;
    background-color: var(--topbar-bgcolor);
    position: fixed;
    padding: 1rem;
    height: var(--topbar-height);
    align-items: center;
    justify-content: right;

    .wactz {
        color: var(--primary);
        font-family: "Times New Roman", Times, serif;
        position: absolute;
        left: 1rem;
        display: flex;
        align-items: center;
        

        .material-symbols-sharp {
            font-size: 3.5rem;
        }

        text {
            font-size: 2rem;
        }
    }

    .menu-button {
        color: var(--light);
        padding: 1rem 1.5rem;
        position: relative;
        transition: 0.2s;
        align-items: center;
        border-bottom: 3px solid transparent;
        justify-content: center;
        display: flex;
    }

    .menu-button a, .menu-button.material-symbols-outlined{
        color: inherit;
        text-decoration: none;
        font-family: "Times New Roman", Times, serif;
        font-size: 1.3rem;
        color: var(--light);
        transition: 0.3s ease-out;
    }

    .menu-button a {
        padding-right: .7rem;
    }

    .menu-button.active,
    .menu-button:hover {
        background-color: var(--topbar-bgcolor-alt);
        border-bottom-color: var(--primary);
    }
}




</style>