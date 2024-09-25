const db = require("../db/dbConfig.js");

const getAllResponses = async () => {
  try {
    const getAllResponses = await db.any("SELECT * FROM responses");
    return getAllResponses;
  } catch (error) {
    return error;
  }
};
const getResponse = async (id) => {
  try {
    const oneResponse = await db.one("SELECT * FROM responses WHERE id=$1", id);
    return oneResponse;
  } catch (error) {
    return error;
  }
};

module.exports = { getAllResponses, getResponse };