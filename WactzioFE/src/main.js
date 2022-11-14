import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import axios from 'axios'

const pinia = createPinia()
const app = createApp(App)

app.config.globalProperties.$axios = axios;
app.use(pinia)
app.use(router)
app.mount('#app')

