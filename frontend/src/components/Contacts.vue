<script setup>
import Contact from "./Contact.vue";

const contactCount = 10;
const componentList = [
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'john wick', prop2: 'Value 2'},
    {name: 'retard punk', prop2: 'Value 4'}
]
</script>

<template>
<!--    <div class="h-8 bg-orange-600" ></div>-->
    <div class="overflow-y-auto overflow-hidden max-h-full ">
    <contact v-for="(item, index) in componentList" :key="index" :name="componentList[index].name" :customProp="item"/>
    </div>
</template>

<style scoped>

</style>
