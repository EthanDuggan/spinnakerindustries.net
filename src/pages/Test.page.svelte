<script>
    export let params;
    fetch('http://localhost:8081/installationinstructions')
        .then(res => res.json())
        .then(data => console.log(data));
</script>

<main>
    <h1>Test Page</h1>
    <p>This is a page for testing.</p>
    <h2>The following params were sent to this page:</h2>
    <p>{JSON.stringify(params)}</p>
</main>