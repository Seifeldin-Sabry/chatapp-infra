<template>
  <div class="relative">
    <input @change="filterContacts" @keyup="filterContacts"
        type="text"
        placeholder="Search Contacts"
        class="w-full py-2 pl-10 pr-4 bg-transparent text-right text-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-500"
        v-model="search"
    >
  </div>
</template>

<script>
export default {
  name: "SearchContact",
  data() {
    return {
      search: "",
    };
  },
  methods: {
    filterContacts() {
      this.$emit("filter", this.search);
    },
  },
}
</script>

<style scoped>

</style>
