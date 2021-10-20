require('dotenv').config();

const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(cors());

app.use('/', require('./routes/general'));
app.use('/', require('./routes/auth'));
app.use('/', require('./routes/vonage'));
app.use('/', require('./routes/webhooks'));

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`)
});
