<template>
  <div class="app">
    <topbar class="top"/>

    <sidebar class="nottop"/>
    <router-view class="nottop"/>
  </div>
</template>

<script setup>
import topbar from './components/Topbar.vue'
import sidebar from './components/Sidebar.vue'
</script>

<style lang="scss">
:root {
  --primary: #4ade80;
  --grey: #64748b;
  --dark: #1e293b;
  --dark-alt: #334155;
  --light: #f1f5f9;
  --topbar-bgcolor: #2a3036;
  --topbar-bgcolor-alt: #464d54;
  --sidebar-width: 300px;
  --topbar-height: 60px;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  //font-family: 'Fira sans', sans-serif;
}

body {
  background: var(--light);
  margin-top: var(--topbar-height);
}

button {
  cursor: pointer;
  appearance: none;
  border: none;
  outline: none;
  background: none;
}

.app {
  display: flex;

  main {
    flex: 1 1 0;
    padding: 2rem;
    
    @media (max-width: 768px) {       //ipad and smaller screens
      padding-left: 6rem;
    }
  }
}

.nottop {
  margin-top: var(--topbar-height);
  width: 100vw;
}

.top {
  z-index: 100;
}

</style>