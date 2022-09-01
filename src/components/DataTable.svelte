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

        //split the query into its space-separated words (tokens)
        let tokens = searchQuery.split(/[\s]+/);
        //create a copy of the tokens array where the tokens are in all lowercase, this is done hear so that the toLowerCase method doesn't need to be run on every token each for each record we check, thus increasing performance at the cost of a tiny bit of extra memory usage
        let lowerCaseTokens = [];
        tokens.forEach((token, i) => {
            lowerCaseTokens[i] = token.toLowerCase();
        });
        //create the ranks array with one entry per record in "data", initialize each rank to 0
        let ranks = new Array(data.length).fill(0);
        
        //for each record in data, check all of its fields for occurances of the search tokens and add to its rank accordingly
        for (let i = 0; i < data.length; i++) {
            const record = data[i];
            for (const col of columns) {
                let recordValue = record[col.key];
                if (recordValue !== undefined) {
                    recordValue += ''; //forces the type to be string and is apparently faster than doing recordValue = recordValue.toString()
                    const lowerCaseRecordValue = recordValue.toLowerCase();
                    //for each token, if it exists in the recordValue, add 10 to the current record's rank, otherwise, check if it exists in a case-insensitive maner, in which case add 9 to the rank
                    for (let t = 0; t < tokens.length; t++) {
                        if (recordValue.includes(tokens[t])) ranks[i] += 10;
                        else if (lowerCaseRecordValue.includes(lowerCaseTokens[t])) ranks[i] += 9;
                    }
                }
            }
            dataFilter[i] = ranks[i] > 0 ? true : false; //if the record's rank is greater than 0, meaning that at least one of the tokens was matched to at least one of its fields, show the record in the search results, otherwise, don't
        }

        dataOrder = dataOrder.sort(function(a, b) {return ranks[b] - ranks[a];}); //use JS's built-in array quicksort method to order the records based on rank
    }

</script>

<main>
    <form on:submit={filterRecordsOnSearch}>  
        <input type="text" placeholder="search..." bind:value={searchQuery} />
        <input type="submit" value="Search" />
    </form>

    <span>items-per-page:
        <select on:change={(ev) => {recordsPerPage = ev.target.value; tablePage = 1;}}> <!--using bind:value={recordsPerPage} here resulted in a weird bug where the dropdown would display blank when the page first loaded, so instead I set recordsPerPage in the callback-->
            <option value=25>25</option>
            <option value=50 selected>50</option>
            <option value=100>100</option>
            <option value=250>250</option>
            <option value=1000>1000</option>
        </select>
    </span>
    <span>page {tablePage} of {numPages}</span>
    <button on:click={() => tablePage = tablePage > 1 ? tablePage - 1 : 1}>prev</button>
    <button on:click={() => tablePage = tablePage < numPages ? tablePage + 1 : numPages}>next</button>
    
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