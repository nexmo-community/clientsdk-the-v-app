require('dotenv').config();

const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());
app.use(cors());
app.options('*', cors())

app.use('/', require('./routes/general'));
app.use('/', require('./routes/auth'));
app.use('/', require('./routes/webhooks'));
app.use('/', require('./routes/vonage'));

if (process.env.USE_LOCALTUNNEL === 'FALSE' || process.env.USE_LOCALTUNNEL == null) {
  app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`)
  });
} else {
  app.listen(port);
  const localtunnel = require('localtunnel');
  (async () => {
    const tunnel = await localtunnel({ 
        subdomain: process.env.vonageAppId, 
        port: port
      });
    console.log(`App available at: ${tunnel.url}`);
  })();
}