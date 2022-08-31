<script>

    export let columns;  // MUST BE AN ARRAY OF DICTIONARIES IN THE FORM {header: 'Foo', key: 'foo', datatype: bar}
    export let data;  // MUST BE AN ARRAY OF DICTIONARIES WITH STRING KEYS THAT ARE CONSISTENT WITH THE VALUES OF THE "key" ATTRIBUTES OF THE OBJECTS IN THE COLUMN ARRAY

    let dataOrder = [...Array(data.length).keys()];  // initially set to an array containing integers from 0 to the number of records in data
    let dataFilter = new Array(data.length).fill(true);  // an array with one boolean entry for each record in data, initially all set to true to indicate that all records are to be shown
    $: filteredDataOrder = createFilteredDataOrder(dataOrder, dataFilter); // this will be an array of the indexes of the data array for only the records that pass the filter and in the order they are to be displayed

    let recordsPerPage = 50;
    let tablePage = 1;
    //$: tablePageFirstIndex = (tablePage - 1) * recordsPerPage;
    //$: tablePageLastIndex = (tablePage * recordsPerPage) - 1;
    $: pageRecordIndexes = filteredDataOrder.slice((tablePage - 1) * recordsPerPage, (tablePage * recordsPerPage) - 1);
    
    function createFilteredDataOrder (order, filter) {
        let ret = new Array();
        for (const x of dataOrder) {
            if (dataFilter[x]) ret.push(x);
        }
        return ret;
    }
</script>

<main>
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