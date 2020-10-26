
const validateSignupParameters = (username, password, name) => {
  const invalid_parameters = [];
  validateUsername(username, invalid_parameters);
  validatePassword(password, invalid_parameters);
  validateName(name, invalid_parameters);
  return invalid_parameters;
}

const validateLoginParameters = (username, password) => {
  const invalid_parameters = [];
  validateUsername(username, invalid_parameters);
  validatePassword(password, invalid_parameters);
  return invalid_parameters;
}

const validateUsername = (username, invalid_parameters) => {
  if (!username) {
    invalid_parameters.push(
      {
        "name": "username",
        "reason": "must exist"
      }
    )
  } else if (username.length < 3) {
    invalid_parameters.push(
      {
        "name": "username",
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

module.exports = {
  validateSignupParameters,
  validateLoginParameters
}