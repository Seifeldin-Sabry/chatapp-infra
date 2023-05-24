<script>


export default {
  props: ['name'],
  async created() {
    console.log(this.name)
  },
  data() {
    return {
      returnName:null,
    };
  },
  methods:{
    emitAddContact(){
      this.returnName=this.name
      this.$emit('addContact',this.returnName)
    }
  }

}

</script>


<template>
  <div @click="emitAddContact"
       class="text-orange-500 h-16 hover:bg-gray-700 border-orange-600 rounded-8 flex justify-between items-center">
    <span class="pr-2">{{ name }}</span>
  </div>
</template>

<style scoped>

</style>
