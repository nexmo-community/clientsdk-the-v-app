const validateSignupParameters = (name, password, display_name) => {
  const invalid_parameters = [];
  validateName(name, invalid_parameters);
  validatePassword(password, invalid_parameters);
  validateDisplayName(display_name, invalid_parameters);
  return invalid_parameters;
}

const validateLoginParameters = (name, password) => {
  const invalid_parameters = [];
  validateName(name, invalid_parameters);
  validatePassword(password, invalid_parameters);
  return invalid_parameters;
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

module.exports = {
  validateSignupParameters,
  validateLoginParameters
}