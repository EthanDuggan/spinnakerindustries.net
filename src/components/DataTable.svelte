<script>

    export let columns;  // MUST BE AN ARRAY OF DICTIONARIES IN THE FORM {header: 'Foo', key: 'foo', datatype: 'bar', width: <number be interpreted as a percentage>, width: <number be interpreted as a percentage>, width: <number be interpreted as a percentage>}
    export let data;  // MUST BE AN ARRAY OF DICTIONARIES WITH STRING KEYS THAT ARE CONSISTENT WITH THE VALUES OF THE "key" ATTRIBUTES OF THE OBJECTS IN THE COLUMN ARRAY
    
    const maxColumnWidth = 64;
    const minColumnWidth = 4;
    const softMaxColumnWidth = 16; //this is the maximum column width for which if there is a value in the column with this many or fewer characters, then the width will be set to at least this value
    calculateDefaultColumnWidths();

    let dataOrder;
    let dataFilter;
    resetTable(); //this function sets dataOrder and dataFilter to their default states
    $: filteredDataOrder = createFilteredDataOrder(dataOrder, dataFilter); // this will be an array of the indexes of the data array for only the records that pass the filter and in the order they are to be displayed

    let recordsPerPage = 50;
    let tablePage = 1;
    $: numPages = Math.ceil(filteredDataOrder.length / recordsPerPage);

    $: pageRecordIndexes = filteredDataOrder.slice((tablePage - 1) * recordsPerPage, (tablePage * recordsPerPage) - 1);
    
    function createFilteredDataOrder(order, filter) {
        let ret = new Array();
        for (const x of order) {
            if (filter[x]) ret.push(x);
        }
        return ret;
    }

    function resetTable() {
        //this function sets dataOrder and dataFilter to their default states
        dataOrder = [...Array(data.length).keys()];  // initially set to an array containing integers from 0 to the number of records in data
        dataFilter = [...Array(data.length).fill(true)];  // an array with one boolean entry for each record in data, initially all set to true to indicate that all records are to be shown
    };

    // Searchbar Functionality
    
    let searchQuery = ''; //This value is bound to the value of the table's searchbar, so when a user types there the value of this variable is automatically updated
    
    function filterRecordsOnSearch(event) {
        //since this function is a callback for a form submission and submitting a form reloads the page by default.  This line prevents the page from reloading.
        event.preventDefault();

        //check if the search query is empty
        if (searchQuery.trim().length == 0) {
            resetTable();
            return;
        }

        //split the query into its space-separated words (tokens)
        let tokens = searchQuery.split(/[\s]+/);
        //create a copy of the tokens array where the tokens are in all lowercase, this is done hear so that the toLowerCase method doesn't need to be run on every token each for each record we check, thus increasing performance at the cost of a tiny bit of extra memory usage
        let lowerCaseTokens = [];
        tokens.forEach((token, i) => lowerCaseTokens[i] = token.toLowerCase());
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

    function changePage(ev) {
        const newPage = ev.target.value;
        if (newPage < 1) {
            tablePage = 1;
            ev.target.value = 1;
        } else if(newPage > numPages) {
            tablePage = numPages;
            ev.target.value = numPages;
        } else {
            tablePage = newPage;
        }
    }

    function calculateDefaultColumnWidths() {
        for (const col of columns) {
            if (col.width === undefined){
                let columnCellDataLengths = data.map((row) => row[col.key] === undefined ? 0 : row[col.key].toString().length);
                columnCellDataLengths.sort((a,b) => b - a);
                col.width = Math.min(softMaxColumnWidth, columnCellDataLengths[0]);  //set the column width to the minimum, will (possibly) be overidden by next section
                if (columnCellDataLengths[0] <= minColumnWidth) {
                    col.width = minColumnWidth;
                } else {
                    for (let i = 0; i < columnCellDataLengths.length; i++) {
                        let L = columnCellDataLengths[i];
                        let P = i / columnCellDataLengths.length;
                        if (L <= softMaxColumnWidth) {
                            break;
                        } else if ((maxColumnWidth / L) * P >= 0.5) {
                            col.width = Math.min(L, maxColumnWidth);
                            break;
                        }
                    }
                }
                
            }
        }
    }

</script>

<main class="datatable">

    <header class="table-toolbar">
        
        <span>showing 
            <select on:change={(ev) => {recordsPerPage = ev.target.value; tablePage = 1;}}> <!--using bind:value={recordsPerPage} here resulted in a weird bug where the dropdown would display blank when the page first loaded, so instead I set recordsPerPage in the callback-->
                <option value=25>25</option>
                <option value=50 selected>50</option>
                <option value=100>100</option>
                <option value=250>250</option>
                <option value=1000>1000</option>
            </select>
             of {filteredDataOrder.length} items per page
        </span>

        <span class="table-page-selector">page 
            <input type="number" value="{tablePage}" min="1" max="{numPages}" on:change={changePage}/>
            of {numPages}
        </span>

        <form class="table-searchbar" on:submit={filterRecordsOnSearch}>  
            <input type="text" placeholder="search..." bind:value={searchQuery} />
            <input type="submit" value="Search" />
        </form>

    </header>
    <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    {#each columns as col}
                    <th style="width: {col.width}rem">{col.header}</th>
                    {/each}
                </tr>
            </thead>
            <tbody>
                {#each pageRecordIndexes as record_index}
                <tr>
                    {#each columns as col}
                    <td>{#if data[record_index][col.key] !== undefined}{data[record_index][col.key]}{/if}</td>
                    {/each}
                </tr>
                {/each}
            </tbody>
        </table>
    </div>
</main>

<style>

    .table-toolbar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        height: 3rem;
        background-color: white;
        position: sticky;
        width: 100%;
        top: 0;
    }

    .table-toolbar * {
        margin: 0;
        padding: 0;
    }
    .table-toolbar > * {
        flex: 1;
        text-align: center;
    }
    .table-toolbar > :first-child {
        text-align: left;
    }
    .table-toolbar > :last-child {
        text-align: right;
    }
    .table-toolbar input,
    .table-toolbar button {
        padding: 0 0.25em 0.1em 0.25em;
    }

    .table-page-selector input {
        text-align: center;
        width: 3em;
    }

    .table-searchbar {
        display: inline-block;
    }

    table {
        table-layout: fixed;
        width: 100%;
        border-spacing: 0;
        
    }

    tbody tr:nth-child(odd) {
        background-color: white;
    }
    tbody tr:nth-child(even) {
        background-color: whitesmoke;
    }

    thead {
        position: sticky;
        top: 0;
        background-color: white;
    }

    th {
        padding: 2px 0;
        border-bottom: 2px solid grey;
        border-left: 1px solid grey;
        border-right: 1px solid grey;
    }

    td {
        padding: 0 8px;
    }
    .table-wrapper {
        overflow: auto;
        max-height: calc(100vh - 3em);
    }

    /*table, thead, tbody {
        display: block;
    }
    .table {
        overflow: auto;
    }
    tr {
        display: flex;
        
    }
    td, th {
        display: inline-block;
        width: 1000em;
    }*/

    tbody td {
        overflow-wrap: break-word;
    }

</style>