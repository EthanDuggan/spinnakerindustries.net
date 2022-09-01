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

let displayData = installationInstructions;

//let searchQuery = '';

</script>

<main>
    {#await displayData}
        <p>Fetching data...</p>
    {:then Data}
        <DataTable columns={installationInstructionsColumns} data={Data}/>
        <!--<input type="text" placeholder="search..." bind:value={searchQuery}>
        <button on:click={console.log('clicked')}>Search</button>
        <table>
            <thead>
                <tr>
                    <th>5 Mil #</th>
                    <th>L-REMD-i</th>
                    <th>Description</th>
                    <th>Date</th>
                    <th>Notes</th>
                </tr>
            </thead>
            <tbody>
                {#each data as row}
                    <tr>
                        <td>{row['5 Mil #']}</td>
                        <td>{row['L-REMD-i']}</td>
                        <td>{row['Description']}</td>
                        <td>{row['Date']}</td>
                        <td>{row['__EMPTY']}</td>
                    </tr>
                {/each}
            </tbody>
        </table>-->
    {:catch error}
        <p>there was an error</p>
    {/await}
</main>