<script>
import Contact from "./Contact.vue";
import SearchContact from "./SearchContact.vue";

export default {
  props: ['userId'],
  components: {Contact, SearchContact},
  data() {
    return {
      chats: null
    }
  },
  methods: {
    selectChat(name) {
      // console.log("select chat with name : "+ name)
      this.$emit('select-chat', this.chats, name)
    },
    async filterContacts(name) {
      console.log("filtering")
      console.log(name)
      const response = await fetch(`/api/users/${this.userId}/chats`)
      const {data: chats} = await response.json()
      this.chats = chats.chats.filter((chat)=>{
        return chat.user2.toLowerCase().includes(name.toLowerCase())||chat.user1.toLowerCase().includes(name.toLowerCase())
      })
      console.log(this.filteredContacts)
      console.log("filtering")
    }
  },
  async created() {

    console.log("using user id : " + this.userId)
    const response = await fetch(`/api/users/${this.userId}/chats`)
    const {data: chats} = await response.json()
    this.chats = chats.chats
    console.log(this.chats)


  },
  async updated(){
    if(this.userId!==null){
    const response = await fetch(`/api/users/${this.userId}/chats`)
    const {data: chats} = await response.json()
    this.chats = chats.chats
    }

  }
}
</script>

<template>
  <!--    <div class="h-8 bg-orange-600" ></div>-->
  <div
      class="overflow-y-auto overflow-hidden max-h-full scrollbar-thin scrollbar-thumb-orange-700 scrollbar-track-blue-300">
    <SearchContact @filter="filterContacts"></SearchContact>
    <contact @select-chat="selectChat" v-for="(item, index) in chats" :key="index"
             :name="(chats[index].user2===userId)?chats[index].user1:chats[index].user2" :customProp="item"/>
  </div>
</template>

<style scoped>

</style>
