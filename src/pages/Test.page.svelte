<script>
    //export let params;

    //this demonstrates that shit be working nice baby
    let installationInstructions = 'waiting';
    setTimeout(
        () => fetch('http://localhost:8081/installationinstructions')
        .then(res => res.json())
        .then(data => installationInstructions = JSON.stringify(data)),
        2000
    );
    
</script>

<main>
    <h1>Test Page</h1>
    <p>This is a page for testing.</p>
    
    <p>{installationInstructions}</p>
</main>