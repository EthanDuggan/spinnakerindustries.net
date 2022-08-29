<script>
	export let name;

	import { setContext } from "svelte";

	setContext('backend', 'http://localhost:8081/');

	import router from 'page';  //import router object from pages.js module to perform client-side routing with

	//import pages
	import Home from './pages/Home.page.svelte';
	import Test from './pages/Test.page.svelte';
	import UndefinedRoute from './pages/UndefinedRoute.page.svelte';
	import QueryInstallationInstructionsAndWiringDiagrams from './pages/QueryInstallationInstructionsAndWiringDiagrams.page.svelte'

	//routes
	let page;
	let params;

	router('/', () => page = Home);
	router('/test', () => page = Test);
	/*router('/test/:param1',
		(ctx, next) => {
			params = ctx.params;
			next();
		},
		() => page = Test
	);*/
	router('/QueryInstallationInstructionsAndWiringDiagrams', () => page = QueryInstallationInstructionsAndWiringDiagrams);
	router('/*', () => page = UndefinedRoute);

	router.start();
	
</script>


<svelte:component this={page} {params} /> <!-- dynamicly load the svelte page component based on the "page" and "params" variables as they are set by the router -->