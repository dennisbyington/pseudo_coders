<template>
  <div>
    <h1>My Documents App</h1>
    <button v-on:click="getDocuments">Get Documents Data</button>
    <div v-for="documentData in DocumentList" :key="documentData.id" class="document-data">
      <div>
        <div>
          <span>ID: {{documentData.id}}</span>
        </div>
        <div>
          <span>Name: {{documentData.filename}}</span>
        </div>
          <span>Size: {{documentData.size}} bytes</span>
        <div>
          <span>Location: {{documentData.location}}</span>
        </div>
      </div>
    </div>
  </div>
</template>


<script>
  import axios from 'axios';
  export default {
    name: "my_Documents",
    data() {
      return {
        DocumentList: []
      };
    },
    methods: {
      getDocuments() {
        // fetch("documents.json")
        //   .then(response => response.json())
        //   .then(data => (this.DocumentList = data));
      // axios.get("documents.json").then(response => (this.
      axios.get("http://127.0.0.1:3000/api/v0/documents").then(response => (this.
        DocumentList = response.data));
      }
    }
  };
</script>


<style scoped> 
  .document-data {
    display: flex;
    align-items: left;
    text-align: left;
    margin-top: 20px;
    margin-left: 20px;
    border-bottom: 2px solid #ccc;
    padding: 20px;
  }


  button {
      padding:10px;
      background-color: #1aa832;
      color: white;
      border: 1px solid #ccc;
  }
</style>

