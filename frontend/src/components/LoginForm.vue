<script>

export default {
    data() {
        return {
            username: '',
            password: ''
        }
    },
    methods: {
        login(submitEvent) {
            const formData = new FormData(submitEvent.target);
            const data = Object.fromEntries(formData);
            // console.log(data);
            fetch('http://localhost:3002/api/auth/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data),
            })
                .then(response => response.json())
                .then(data => {
                    console.log('Success:', data);
                    if (data.status === 'success') {
                        this.$emit('login', data.data.user);
                    }
                })
                .catch((error) => {
                    console.error('Error:', error);
                });
        }
    }
}


</script>

<template>
    <div class="relative h-full flex-grow grid" id="login-form">
        <div class="flex flex-col sm:flex-row items-center md:items-start justify-center flex-auto min-w-0 ">
            <div class="md:flex md:items-center md:justify-left w-full sm:w-auto md:h-full xl:w-1/2 p-8  md:p-10 lg:p-14 sm:rounded-lg md:rounded-none ">
                <div class="max-w-xl w-full space-y-12">
                    <div class="lg:text-left text-center">
                        <div class="flex items-center justify-center ">
                            <div class="bg-black border-2 border-orange-600 flex flex-col w-80 border border-gray-900 rounded-lg px-8 py-10">
                                <form class="flex flex-col space-y-8 mt-10"  @submit.prevent="login">
                                    <label class="font-bold text-lg text-white " for="name">Username</label>
                                    <input class="border-2 rounded-lg py-3 px-3 bg-black focus:outline-none focus:border-orange-600 text-orange-600"
                                           id="name"
                                           name="name" placeholder="name"
                                           required
                                           type="text">
                                    <label class="font-bold text-lg text-white" for="password">Password</label>
                                    <input class="border-2 rounded-lg py-3 px-3 bg-black focus:outline-none focus:border-orange-600 text-orange-600"
                                           id="password" name="password" placeholder="Password"
                                           required type="password">
                                    <button
                                            class="border-2 hover:border-orange-600 hover:text-orange-600 border-slate-300 bg-black text-slate-300 rounded-lg py-3 font-semibold"
                                            type="submit">Log in
                                    </button>
                                </form>
                            </div>
                        </div>

                    </div>

                </div>
            </div>
        </div>
    </div>
</template>

<style scoped>

</style>
