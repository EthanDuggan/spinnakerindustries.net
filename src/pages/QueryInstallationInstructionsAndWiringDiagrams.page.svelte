<script>
import { getContext } from "svelte";

// fetch data from the backend
const backend = getContext('backend');
console.log(backend + 'installationInstructions');
console.log('hello!!!');
let installationInstructions = fetch(backend + 'installationInstructions').then(res => res.json());
let wiringDiagrams = fetch(backend + 'wiringDiagrams').then(res => res.json());

</script>

<main>
    <h1>Page Title</h1>
    {#await installationInstructions}
        <p>Fetching data...</p>
    {:then data}
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
        </table>
    {:catch error}
        <p>there was an error</p>
    {/await}
</main>