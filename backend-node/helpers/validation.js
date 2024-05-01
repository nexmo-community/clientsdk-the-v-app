import jwt from 'jsonwebtoken';

const validateSignupParameters = (req, res, next) => {
  const { name, password, display_name } = req.body;

  const invalid_parameters = [];

  validateName(name, invalid_parameters);
  validatePassword(password, invalid_parameters);
  validateDisplayName(display_name, invalid_parameters);

  if (invalid_parameters.length > 0) {
    res.status(400).send({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "The request failed due to validation errors",
      invalid_parameters
    });
  }

  next();
};

const validateLoginParameters = (req, res, next) => {
  const { name, password } = req.body;

  const invalid_parameters = [];

  // Perform validation
  validateName(name, invalid_parameters);
  validatePassword(password, invalid_parameters);

  if (invalid_parameters.length > 0) {
    res.status(400).send({
      "type": "data:validation",
      "title": "Bad Request",
      "detail": "The request failed due to validation errors",
      invalid_parameters
    });
  }

  next();
};

const validateName = (name, invalid_parameters) => {
  if (!name) {
    invalid_parameters.push(
      {
        "name": "name",
        "reason": "must exist"
      }
    )
  } else if (name.length < 3) {
    invalid_parameters.push(
      {
        "name": "name",
        "reason": "must be longer than 2 characters"
      }
    )
  }
}

const validatePassword = (password, invalid_parameters) => {
  if (!password) {
    invalid_parameters.push(
      {
        "name": "password",
        "reason": "must exist"
      }
    )
  } else if (password.length < 8) {
    invalid_parameters.push(
      {
        "name": "password",
        "reason": "must be at least 8 characters"
      }
    )
  }
}

const validateDisplayName = (display_name, invalid_parameters) => {
  if (!display_name) {
    invalid_parameters.push(
      {
        "name": "display_name",
        "reason": "must exist"
      }
    )
  } else if (display_name.length < 3) {
    invalid_parameters.push(
      {
        "name": "display_name",
        "reason": "must be longer than 2 characters"
      }
    )
  }
}

const decodeJWT = async (req, res, next) => {
  const token = req.headers.authorization;

  if (!token) {
    return res.status(400).send({
      "type": "auth:missingtoken",
      "title": "Bad Request",
      "detail": "The request failed due to a missing token"
    });
  }

  try {
    const decoded = await jwt.decode(token.replace(/^Bearer\s/, ''), { complete: true, });
    req.userJWT = decoded.payload;

    if (!decoded.payload.user_id) {
      return res.status(400).send({
        "type": "auth:missinguserid",
        "title": "Bad Request",
        "detail": "The request failed due to an incorrect token"
      });
    }

    next();
  } catch (error) {
    return res.status(400).send({
      "type": "auth:badtoken",
      "title": "Bad Request",
      "detail": "The request failed due to an incorrect token"
    });
  }
};

const Validation = {
  validateSignupParameters,
  validateLoginParameters,
  decodeJWT
}

export default Validation;