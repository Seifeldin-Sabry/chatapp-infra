<script>
import Contacts from "./components/Contacts.vue";
import Chat from "./components/Chat.vue";

import {th} from '@faker-js/faker';
import {defineComponent} from "vue";
import LoginForm from "./components/LoginForm.vue";
import SearchContact from "./components/SearchContact.vue";

export default defineComponent({
  computed: {
    th() {
      return th
    }
  },
  components: {SearchContact, LoginForm, Chat, Contacts},
  data() {
    return {
      chatId: 0,
      userId: "Seif",
      filteredContacts: [],
      connection: null,
      currentContact: null,
      currentMessages:[]
    }
  },
  created() {
  },
  methods: {
    sendMessage: function (message) {
      console.log(this.connection);
      this.connection.send(message);
    },
    selectChat(chats, name) {
      chats.forEach((chat) => {
        if (chat.user2 === name || chat.user1 === name) {
          this.chatId = chat.id;
          this.currentContact=name;
        }

      })
    },
    login(user) {

      this.userId = user.name;
      document.getElementById("login-form-container").hidden = true;
      document.getElementById("contacts").hidden = false;
      document.getElementById("chat").hidden = false;
      this.connectWs()
    },
    register(user) {
      this.userId = user.name;
      document.getElementById("login-form-container").hidden = true;
      document.getElementById("contacts").hidden = false;
      document.getElementById("chat").hidden = false;
      this.connectWs()

    },
    filterContacts(name) {
      console.log("filtering")
      console.log(name)
      this.filteredContacts = this.th.name.findName(name)
      console.log(this.filteredContacts)
      console.log("filtering")
    },
    connectWs(){
      console.log("Starting connection to WebSocket Server")
      this.connection = new WebSocket("ws://localhost:3002?userId=" + this.userId)


      // this.connection.on

      this.connection.onopen = function (event) {
        console.log(event)
        console.log("Successfully connected to the echo websocket server...")
      }
    }
  }
})


</script>

<template>
  <div class="w-screen h-screen flex justify-center content-center items-center" >
    <div class="h-[80vh] w-[80vh] " id="login-form-container" >
      <LoginForm @login="login" @register="register"></LoginForm>
    </div>
    <div class="h-[80vh] w-[20vh] border-2  border-orange-600" id="contacts" hidden>
      <Contacts @select-chat="selectChat" :key="userId" :userId="userId"></Contacts>
    </div>
    <div class="h-[80vh] w-[70vh] border-2  border-orange-600" id="chat" hidden >
      <button v-on:click="sendMessage('gay')">Send Message</button>
      <Chat  :receiver="this.currentContact" :connection="this.connection" :chat-id=this.chatId :user-id="userId" :key="chatId"></Chat>
    </div>
  </div>
</template>

<style scoped>
</style>
