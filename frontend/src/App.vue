<script setup>
import Contacts from "./components/Contacts.vue";
import Chat from "./components/Chat.vue";
</script>

<template>
    <div class="w-screen h-screen flex justify-center content-center items-center">
        <div class="h-[80vh] w-[20vh] border-2  border-orange-600">
            <Contacts></Contacts>
        </div>
        <div class="h-[80vh] w-[70vh] border-2  border-orange-600">
            <Chat></Chat>
        </div>
    </div>
</template>

<style scoped>
</style>
