import express from 'express';

import auth from './routes/auth.js';
import users from './routes/users.js';
import image from './routes/image.js';
import webhooks from './routes/webhooks.js';

const app = express();
const port = process.env.VCR_PORT || process.env.PORT || 3000;

app.use(express.json());

app.use('/', auth);
app.use('/', users);
app.use('/', image);
app.use('/', webhooks);

app.get('/_/health', async (req, res) => {
  res.sendStatus(200);
});

app.get('/_/metrics', async (req, res) => {
  res.sendStatus(200);
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`)
});