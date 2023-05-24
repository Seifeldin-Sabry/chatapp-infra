<script>
import Contact from "./Contact.vue";
import SearchContact from "./SearchContact.vue";
import Modal from "./Modal.vue";

export default {
  props: ['userId','connection'],
  components: {Modal,Contact, SearchContact},
  data() {
    return {
      chats: null,
      isModalVisible: false,
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
      this.chats = chats.chats.filter((chat) => {
        return chat.user2.toLowerCase().includes(name.toLowerCase()) || chat.user1.toLowerCase().includes(name.toLowerCase())
      })
      console.log(this.filteredContacts)
      console.log("filtering")
    },
    addContact(name) {
      fetch("/api/chats", {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          user1: this.userId,
          user2: name
        })
      }).then(response => response.json())
          .then(data => {
            console.log("response to post chat")
            console.log(data)
            this.chats.push(data.chat[0])
            const messageData = {type:"newChat",receiver:name,sender: this.userId};
            this.connection.send(JSON.stringify(messageData))
          })
          .catch((error) => {
            console.error('Error:', error);
          });

    },
    showModal() {
      console.log("modal is true")
      this.isModalVisible = true;
    },
    closeModal() {
      this.isModalVisible = false;
    },
  },
  async created() {

    console.log("using user id : " + this.userId)
    const response = await fetch(`/api/users/${this.userId}/chats`)
    const {data: chats} = await response.json()
    this.chats = chats.chats
    console.log(this.chats)
  }

  // },
  // async updated() {
  //   if (this.userId !== null) {
  //     const response = await fetch(`/api/users/${this.userId}/chats`)
  //     const {data: chats} = await response.json()
  //     this.chats = chats.chats
  //   }
  //
  // }
}
</script>

<template>
  <!--    <div class="h-8 bg-orange-600" ></div>-->
  <div
      class="overflow-y-auto overflow-hidden max-h-full scrollbar-thin scrollbar-thumb-orange-700 scrollbar-track-blue-300">
    <button type="button" class="bg-orange-500 hover:bg-orange-700 text-white font-bold py-2 px-4 rounded"
            @click="showModal">Add Contact!
    </button>
    <Modal @add-contact="addContact" v-show="isModalVisible" @close="closeModal"/>
    <SearchContact @filter="filterContacts"></SearchContact>
    <contact @select-chat="selectChat" v-for="(item, index) in chats" :key="index"
             :name="(chats[index].user2===userId)?chats[index].user1:chats[index].user2" :customProp="item"/>
  </div>
</template>

<style scoped>

</style>
