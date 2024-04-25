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
    return res.status(401).json({ message: 'No token provided' });
  }

  try {
    const decoded = await jwt.decode(token.replace(/^Bearer\s/, ''), { complete: true, });
    req.userJWT = decoded.payload;

    if (!decoded.payload.user_id) {
      return res.status(401).json({ message: 'Invalid token' });
    }

    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid token' });
  }
};

const Validation = {
  validateSignupParameters,
  validateLoginParameters,
  decodeJWT
}

export default Validation;