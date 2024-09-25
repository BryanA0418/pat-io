// DEPENDENCIES
const express = require("express");
const responses = express.Router();
const { getAllResponses, getResponse } = require("../queries/response.js");
responses.get("/", async (req, res) => {
  const allResponses = await getAllResponses();
  if (allResponses[0]) {
    res.status(200).json(allResponses);
  } else {
    res.status(500).json({ error: "server error" });
  }
});
responses.get("/:id", async (req, res) => {
  const { id } = req.params;
  const response = await getResponse(id);
  if (response.id) {
    res.json(response);
  } else {
    res.status(404).json({ error: "not found" });
  }
});
module.exports = responses;