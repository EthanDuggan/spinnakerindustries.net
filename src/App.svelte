<script>
	export let name;

	import router from 'page';  //import router object from pages.js module to perform client-side routing with

	//import pages
	import Home from './Home.page.svelte';
	import Test from './Test.page.svelte';
	import UndefinedRoute from './UndefinedRoute.page.svelte';

	//routes
	let page;
	let params;

	router('/', () => page = Home);
	router('/test/:param1',
		(ctx, next) => {
			params = ctx.params;
			next();
		},
		() => page = Test
	);
	router('/*', () => page = UndefinedRoute);

	router.start();
	
</script>


<svelte:component this={page} {params} /> <!-- dynamicly load the svelte page component based on the "page" and "params" variables as they are set by the router -->