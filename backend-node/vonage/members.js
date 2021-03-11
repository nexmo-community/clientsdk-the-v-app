const getConfig = (jwt) => {
  return {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${jwt}`
    }
  };
}

// const create = async (name, display_name) => {
//   let vonageUser;
//   let error;

//   try {
//     const body = { name, display_name };
//     const config = getConfig(JWT.getAdminJWT());

//     const response = await axios.post(`${vonageAPIUrl}/users`, body, config);

//     if (response) {
//       if(response.status === 201) {
//         vonageUser = response.data;
//       } else {
//         error = "Unexpected error";
//       }
//     }

//   }
//   catch (err) {
//     // console.log(err.response.status);
//     // console.log(err.response.data);
//     // console.log(err.response.data.detail);
//     error = err.response.data || err;
//   }

//   return { vonageUser, error};
// }

// const getAll = async () => {
//   let users;

//   try {

//     const config = getConfig(JWT.getAdminJWT());
//     const response = await axios.get(`${vonageAPIUrl}/users?page_size=100`, config);

//     if (response && response.data) {
//       users = [
//         ...response.data._embedded.users.map(m => {
//           return {
//             vonage_id: m.id,
//             name: m.name,
//             display_name: m.display_name || m.name
//           }
//         })
//       ]
//     }
//   }
//   catch (err) {
//     console.log(err);
//   }

//   return users;
// }



module.exports = {
  // create,
  // getAll
}
