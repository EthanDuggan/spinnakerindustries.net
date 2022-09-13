<script>
import { getContext } from "svelte";
import DataTable from '../components/DataTable.svelte';

// fetch data from the backend
const backend = getContext('backend');
let installationInstructions = fetch(backend + 'installationInstructions').then(res => res.json());
let wiringDiagrams = fetch(backend + 'wiringDiagrams').then(res => res.json());
let installationInstructionsColumns = [
    {header: '5 Mil #', key: '5 Mil #'},
    {header: 'L-REMD-i', key: 'L-REMD-i'},
    {header: 'Description', key: 'Description'},
    {header: 'Date', key: 'Date'},
    {header: 'Notes', key: '__EMPTY'},
];
let wiringDiagramsColumns = [
    {header: 'New DWG #', key: 'NEW DWG#'},
    {header: 'Description', key: ';'},
    {header: 'Original DWG', key: 'ORIGINAL DWG'},
    {header: 'Notes', key: 'MORE INFO'},
    {header: 'Labels', key: 'LABELS'},
];

let currentTab = 'Wiring Diagrams';

</script>

<main>
    <nav class="tab-bar">
        <button id="Wiring-Diagrams-Tab-Button" class="{currentTab == 'Wiring Diagrams' ? 'current-tab-button' : ''}" on:click={() => currentTab = 'Wiring Diagrams'}>Wiring Diagrams</button>
        <button id="Installation-Instructions-Tab-Button" class="{currentTab == 'Installation Instructions' ? 'current-tab-button' : ''}" on:click={() => currentTab = 'Installation Instructions'}>Installation Instructions</button>
    </nav>
    <div class="tab {currentTab == 'Installation Instructions' ? 'current-tab' : ''}">
        {#await installationInstructions}
        <p>Fetching data...</p>
        {:then Data}
            <DataTable columns={installationInstructionsColumns} data={Data}/>
        {:catch error}
            <p>there was an error</p>
        {/await}
    </div>
    <div class="tab {currentTab == 'Wiring Diagrams' ? 'current-tab' : ''}">
        {#await wiringDiagrams}
        <p>Fetching data...</p>
        {:then Data}
            <DataTable columns={wiringDiagramsColumns} data={Data}/>
        {:catch error}
            <p>there was an error</p>
        {/await}
    </div>
    
</main>

<style>
    main {
        background-color: #ddd;
    }
    .tab {
        display: none;
    }
    .tab.current-tab {
        display: block;
    }

    .tab-bar {
        display: flex;
        border-bottom: 2px solid #08f;
        padding: 2px 2px 0 2px;
    }
    .tab-bar button {
        border: none;
        margin: 0;
        border-radius: 0.5em 0.5em 0 0;
        background-color: white;
    }
    .tab-bar button.current-tab-button {
        background-color: #08f;
        color: white;
    }
</style>