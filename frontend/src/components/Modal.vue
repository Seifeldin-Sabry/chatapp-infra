<template>
  <div class="modal-backdrop">
    <div class="modal">
      <header class="modal-header">
        <slot name="header">
          Add a contact
        </slot>
        <button
            type="button"
            class="btn-close"
            @click="close">
          x
        </button>
      </header>

      <section class="modal-body">
        <slot name="body">
          <input @keyup="filterContacts"
                 type="text"
                 placeholder="Search Contacts"
                 class="w-full py-2 pl-10 pr-4 bg-transparent text-right text-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-500"
                 v-model="search"
          >
        </slot>
        <ContactToAdd @add-contact="addContact" v-for="(item, index) in newContacts" :key="index" :name="newContacts[index].name" :customProp="item"/>
      </section>

      <footer class="modal-footer">
        <slot name="footer">
          This is the default footer!
        </slot>
        <button
            type="button"
            class="btn-green"
            @click="close"
        >
          Close Modal
        </button>
      </footer>
    </div>
  </div>
</template>
<script>
import {th} from "@faker-js/faker";
import ContactToAdd from "./ContactToAdd.vue";
import TextBubble from "./TextBubble.vue";

export default {
  name: 'Modal',
  components: {TextBubble, ContactToAdd},
  computed: {
    th() {
      return th
    }
  },
  data() {
    return {
      search: "",
      newContacts: [] ,
    };
  },
  methods: {
    close() {

      this.$emit('close');
    },
    filterContacts(name) {
      console.log("first-filtering")
      console.log(this.search)
      // this.newContacts
      fetch(`/api/users/${this.search}/users`)
          .then(response => response.json())
          .then(data => {
            console.log(data.data.users)
            this.newContacts = data.data.users
          })
          .catch(error => console.log(error))
    },
    addContact(name){
      console.log("modal component")
      console.log(name)
      this.$emit("addContact",name)
    }
  },
};
</script>


<style>
.modal-backdrop {
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: rgba(0, 0, 0, 0.3);
  display: flex;
  justify-content: center;
  align-items: center;
}

.modal {
  background: #FFFFFF;
  box-shadow: 2px 2px 20px 1px;
  overflow-x: auto;
  display: flex;
  flex-direction: column;
}

.modal-header,
.modal-footer {
  padding: 15px;
  display: flex;
}

.modal-header {
  position: relative;
  border-bottom: 1px solid #eeeeee;
  color: #4AAE9B;
  justify-content: space-between;
}

.modal-footer {
  border-top: 1px solid #eeeeee;
  flex-direction: column;
  justify-content: flex-end;
}

.modal-body {
  position: relative;
  padding: 20px 10px;
}

.btn-close {
  position: absolute;
  top: 0;
  right: 0;
  border: none;
  font-size: 20px;
  padding: 10px;
  cursor: pointer;
  font-weight: bold;
  color: #4AAE9B;
  background: transparent;
}

.btn-green {
  color: white;
  background: #4AAE9B;
  border: 1px solid #4AAE9B;
  border-radius: 2px;
}
</style>
