console.log('hello world');

const express = require('express');
const { readFile } = require('fs').promises;

const app = express();

app.get('/', async (req, res) => {

    res.send(await readFile('./helloworld.html', 'utf8')); // without handling the error, if there is an error the app will crash!

});

app.listen(process.env.PORT || 8080, () => console.log(`App available on http://localhost:8080`));