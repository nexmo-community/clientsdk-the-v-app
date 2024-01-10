require('dotenv').config();

const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.VCR_PORT ||process.env.PORT || 3000;

app.use(express.json());
app.use(cors());

// app.use('/', require('./routes/auth'));
// app.use('/', require('./routes/webhooks'));
// app.use('/', require('./routes/vonage'));

app.get('/_/health', async (req, res) => {
  res.sendStatus(200);
});

app.get('/_/metrics', async (req, res) => {
  res.sendStatus(200);
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`)
});
