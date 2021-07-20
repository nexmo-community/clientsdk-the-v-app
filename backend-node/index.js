require('dotenv').config();

const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());

app.use('/', require('./routes/general'));
app.use('/', require('./routes/auth'));
app.use('/', require('./routes/vonage'));
app.use('/', require('./routes/webhooks'));

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
});
