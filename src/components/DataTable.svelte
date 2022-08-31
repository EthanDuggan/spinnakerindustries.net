<script>

    export let columns;  // MUST BE AN ARRAY OF DICTIONARIES IN THE FORM {header: 'Foo', key: 'foo', datatype: bar}
    export let data;  // MUST BE AN ARRAY OF DICTIONARIES WITH STRING KEYS THAT ARE CONSISTENT WITH THE VALUES OF THE "key" ATTRIBUTES OF THE OBJECTS IN THE COLUMN ARRAY

    let dataOrder = [...Array(data.length).keys()];  // initially set to an array containing integers from 0 to the number of records in data
    let dataFilter = new Array(data.length).fill(true);  // an array with one boolean entry for each record in data, initially all set to true to indicate that all records are to be shown
    $: filteredDataOrder = createFilteredDataOrder(dataOrder, dataFilter); // this will be an array of the indexes of the data array for only the records that pass the filter and in the order they are to be displayed

    let recordsPerPage = 50;
    let tablePage = 1;
    $: numPages = Math.ceil(filteredDataOrder.length / recordsPerPage);

    $: pageRecordIndexes = filteredDataOrder.slice((tablePage - 1) * recordsPerPage, (tablePage * recordsPerPage) - 1);
    
    function createFilteredDataOrder(order, filter) {
        let ret = new Array();
        for (const x of dataOrder) {
            if (dataFilter[x]) ret.push(x);
        }
        return ret;
    }

    // Searchbar functionality
    
    let searchQuery = ''; //This value is bound to the value of the table's searchbar, so when a user types there the value of this variable is automatically updated
    
    function filterRecordsOnSearch(event) {
        //since this function is a callback for a form submission and submitting a form reloads the page by default.  This line prevents the page from reloading.
        event.preventDefault();

        let tokens = searchQuery.split(/[\s]+/);
        let ranks = new Array(data.length).fill(0);
        
        for (let i = 0; i < data.length; i++) {
            for (const col of columns) {
                const record = data[i];
                for (const token of tokens) {
                    const recordValue = record[col.key];
                    if (recordValue !== undefined && recordValue.toString().includes(token)) ranks[i] += 10;
                }
            }
        }

        dataOrder = dataOrder.sort(function(a, b) {return ranks[b] - ranks[a];});        
    }

</script>

<main>
    <form on:submit={filterRecordsOnSearch}>  
        <input type="text" placeholder="search..." bind:value={searchQuery} />
        <input type="submit" value="Search" />
    </form>

    <button on:click={() => tablePage = tablePage > 1 ? tablePage - 1 : 1}>prev</button>
    <button on:click={() => tablePage = tablePage < numPages ? tablePage + 1 : numPages}>next</button>
    <span>page {tablePage} of {numPages}</span>
    
    <table>
        <thead>
            <tr>
                {#each columns as col}
                <th>{col.header}</th>
                {/each}
            </tr>
        </thead>
        <tbody>
            {#each pageRecordIndexes as record_index}
            <tr>
                {#each columns as col}
                <td>{data[record_index][col.key]}</td>
                {/each}
            </tr>
            {/each}
        </tbody>
    </table>
</main>