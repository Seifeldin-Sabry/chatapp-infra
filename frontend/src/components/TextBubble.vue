<script setup>
defineProps({
    text: String,
    sender: String,
    currentUser: String
})
</script>

<template>
    <div class="flex w-full mt-2 space-x-3 max-w-xs"
         v-bind:class="(currentUser===sender)?'justify-end ml-auto':'justify-start'">
        <div>
            <div class=" p-3 "
                 v-bind:class="(currentUser===sender)?'bg-blue-600 rounded-l-lg rounded-br-lg text-white':'rounded-r-lg rounded-bl-lg bg-gray-300'">
                <p class="text-sm">{{ text }}</p>
            </div>
        </div>
    </div>
</template>

<style scoped>

</style>
