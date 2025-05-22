// A very basic Node.js file
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from your Node.js project!');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});

console.log("Project started successfully.");
