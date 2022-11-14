<template>
  <div>
    <h1>Companies</h1>
    <button v-on:click="getCompanies">Get Company Data</button>
    <div v-for="companyData in CompanyList" :key="companyData.id" class="company-data">
      <div>
        <div>
          <span>ID: {{companyData.id}}</span>
        </div>
        <div>
          <span>Name: {{companyData.name}}</span>
        </div>
      </div>
    </div>
  </div>
</template>


<script>
  import axios from 'axios';
  export default {
    name: "my_Companies",
    data() {
      return {
        CompanyList: []
      };
    },
    methods: {
      getCompanies() {
        // fetch("documents.json")
        //   .then(response => response.json())
        //   .then(data => (this.DocumentList = data));
      // axios.get("documents.json").then(response => (this.
      axios.get("http://127.0.0.1:3000/api/v0/companies").then(response => (this.
        CompanyList = response.data));
      }
    }
  };
</script>


<style scoped> 
  .company-data {
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

