<script>
import TextBubble from "./TextBubble.vue";
import {defineComponent} from "vue";

export default defineComponent({
    props: ['chatId', 'userId'],
    components: {TextBubble},
    data() {
        return {
            messages: null,
            text: ''
        }
    },
    async created() {
        //TODO: add the actual user name instead of hardcoding
        if (this.chatId !== 0) {


            const response = await fetch(`http://localhost:3002/api/chats/${this.chatId}/messages`)
            const {data: messages} = await response.json()
            this.messages = messages.messages.reverse()
            // console.log(this.userId)
            // console.log(this.messages)
        }
    },
    methods: {
        sendMessage() {
            if (this.text.length > 0) {
                fetch("http://localhost:3002/api/chats/1/messages", {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        userId: this.userId,
                        message: this.text
                    })
                }).then(response => response.json())
                    .then(data => {
                        this.messages.unshift(data.data.message[0])
                    })
                    .catch((error) => {
                        console.error('Error:', error);
                    });
                this.text = ''
            }
        }
    }
})


</script>

<template>
    <div class="flex flex-col flex-grow w-full h-full bg-gray-700 shadow-xl rounded-lg">
        <div class="flex flex-col-reverse flex-grow h-0 p-4 overflow-auto no-scrollbar ">
            <TextBubble v-for="(item, index) in messages" :key="index" :text="messages[index].message"
                        :current-user="userId" :sender="messages[index].sender" :customProp="item"/>
        </div>
        <div class="bg-orange-800 p-4">
            <input @keyup.enter="sendMessage" v-model="text"
                   class="flex items-center h-10 w-full bg-orange-300 text-right rounded px-3 text-sm" type="text"
                   placeholder="Type your message…">
            You typed: <b>{{ text }}</b>
        </div>
    </div>
</template>

<style scoped>

</style>
