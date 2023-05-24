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
      contactsKey: 500,
      chatId: 0,
      userId: null,
      filteredContacts: [],
      connection: null,
      currentContact: null,
      currentMessages: []
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
      console.log("selecting chat")
      chats.forEach((chat) => {
        if (chat.user2 === name || chat.user1 === name) {
          console.log("new chat id" + chat.id)
          this.chatId = chat.id;
          this.currentContact = name;
        }

      })
    },
    login(user) {

      this.userId = user.name;
      this.contactsKey += 1;
      document.getElementById("login-form-container").hidden = true;
      document.getElementById("contacts").hidden = false;
      document.getElementById("chat").hidden = false;
      console.log("logging in with userId" + this.userId)
      this.connectWs()
    },
    register(user) {
      this.userId = user.name;
      this.contactsKey += 1;
      document.getElementById("login-form-container").hidden = true;
      document.getElementById("contacts").hidden = false;
      document.getElementById("chat").hidden = false;
      console.log("registering with userId" + this.userId)
      this.connectWs()

    },
    filterContacts(name) {
      console.log("filtering")
      console.log(name)
      this.filteredContacts = this.th.name.findName(name)
      console.log(this.filteredContacts)
      console.log("filtering")
    },
    connectWs() {
      console.log("Starting connection to WebSocket Server")
      this.connection = new WebSocket("ws:" + window.location.host + "/socket?userId=" + this.userId)

      this.connection.onmessage = (event) => {
        console.log(event)
        console.log(event.data)
        let new_chat=JSON.parse(event.data)
        if (new_chat.type === 'chat') {
          console.log("received chat message")
          this.contactsKey += 1;
        }
        if (new_chat.chatId !== null) {
          if (this.currentContact === new_chat.sender) {
            this.currentMessages.unshift(JSON.parse(event.data))
          }
        }

      }
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
  <div class="w-screen h-screen flex justify-center content-center items-center">
    <div class="h-[80vh] w-[80vh] " id="login-form-container">
      <LoginForm @login="login" @register="register"></LoginForm>
    </div>
    <div class="h-[80vh] w-[20vh] border-2  border-orange-600" id="contacts" hidden>
      <Contacts @select-chat="selectChat" :connection="this.connection" :key="contactsKey" :userId="userId"></Contacts>
    </div>
    <div class="h-[80vh] w-[70vh] border-2  border-orange-600" id="chat" hidden>
      <Chat :receiver="this.currentContact" :messages="currentMessages" :connection="this.connection"
            :chat-id=this.chatId :user-id="userId" :key="chatId"></Chat>
    </div>
  </div>
</template>

<style scoped>
</style>
