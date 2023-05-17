<script>
import Contact from "./Contact.vue";

export default {
    props: ['userId'],
    components: {Contact},
    data() {
        return {
            chats: null
        }
    },
    methods:{
      selectChat(name){
          // console.log("select chat with name : "+ name)
          this.$emit('select-chat',this.chats,name)
      }
    },
    async created() {

        const response = await fetch(`http://localhost:3002/api/users/${this.userId}/chats`)
        const {data: chats} = await response.json()
        this.chats = chats.chats
    }
}
</script>

<template>
  <!--    <div class="h-8 bg-orange-600" ></div>-->
    <div class="overflow-y-auto overflow-hidden max-h-full scrollbar-thin scrollbar-thumb-orange-700 scrollbar-track-blue-300">
        <contact @select-chat="selectChat" v-for="(item, index) in chats" :key="index"
                 :name="(chats[index].user2===userId)?chats[index].user1:chats[index].user2" :customProp="item"/>
    </div>
</template>

<style scoped>

</style>
