import express from 'express';
import multer from 'multer';

import Storage from '../helpers/storage.js';
import Validation from '../helpers/validation.js';

const imageRoutes = express.Router();

const multerStorage = multer.memoryStorage();
const upload = multer({ storage: multerStorage });

const imageUpload = upload.fields(
    [
        { name: 'image', maxCount: 1 },
    ]
);

imageRoutes.post('/image', Validation.decodeJWT, imageUpload, async (req, res, next) => {
    try {
        const user = await Storage.getUser(req.userJWT.sub);
        if (!user) {
            res.status(403).send({
                "type": "auth:unauthorized",
                "title": "Bad Request",
                "detail": "The request failed due to invalid credentials"
            });
            return;
        }

        const imageFile = req.files.image[0];
        const imageUrl = await Storage.storeImage(imageFile);

        res.json({ imageUrl: imageUrl });
    } catch (e) {
        next(e);
    }
});

export default imageRoutes;