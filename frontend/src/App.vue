<script>
import Contacts from "./components/Contacts.vue";
import Chat from "./components/Chat.vue";

import {faker, th} from '@faker-js/faker';
import {defineComponent} from "vue";
import LoginForm from "./components/LoginForm.vue";

export default defineComponent({
    computed: {
        th() {
            return th
        }
    },
    components: {LoginForm, Chat, Contacts},
    data () {
        return {
            chatId: 0,
            userId: undefined
        }
    },
    methods:{
        selectChat(chats,name){
            // console.log("chats and name")
            // console.log(chats)
            // console.log(name)
            // chats + Seif
            chats.forEach((chat)=>{
                if(chat.user2===name||chat.user1===name){
                    this.chatId=chat.id;
                }

            })
        },
        login(user){
            this.userId=user.name;
            document.getElementById("login-form-container").hidden=true;
            document.getElementById("contacts").hidden=false;
            document.getElementById("chat").hidden=false;
        },
        register(user){
            this.userId=user.name;
            document.getElementById("login-form-container").hidden=true;
            document.getElementById("contacts").hidden=false;
            document.getElementById("chat").hidden=false;
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
            <Contacts @select-chat="selectChat" :key="userId" :userId="userId"></Contacts>
        </div>
        <div class="h-[80vh] w-[70vh] border-2  border-orange-600" id="chat" hidden>
            <Chat :chat-id=this.chatId :user-id="userId" :key="chatId"></Chat>
        </div>
    </div>
</template>

<style scoped>
</style>
