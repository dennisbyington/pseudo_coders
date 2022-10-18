<!-- <template>
    <main class="documents-page">
        <h1>Documents</h1>
        <p>This is the documents page</p>
    </main>
</template> -->

<template>
  <div id="app">
    <Documents />
  </div>
</template>

<script>
import Documents from '../components/Documents.vue'

export default {
  name: 'app',
  components: {
    Documents
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
