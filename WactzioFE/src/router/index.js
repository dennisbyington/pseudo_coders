import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import About from '../views/About.vue'
import Documents from '../views/Documents.vue'
import Companies from '../views/Companies.vue'

const router = createRouter({
    history: createWebHistory(),
    routes: [
        {
            path: '/',
            component: Home
        },
        {
            path: '/about',
            component: About
        },
        {
            path: '/documents',
            component: Documents
        },
        {
            path: '/companies',
            component: Companies
        }
    ]
})

export default router
