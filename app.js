// DEPENDENCIES
const cors = require("cors");
const express = require("express");
const { OpenAI } = require("openai");
require("dotenv").config();
// const morgan = require("morgan");

// CONFIGURATION
const app = express();

// MIDDLEWARE
app.use(cors());
app.use(express.json());
const responsesController = require("./Controllers/responseControllers.js")
// ROUTES
app.get("/", (req, res) => {
    res.send("Welcome to Pat.io App");
  });
app.use("/responses", responsesController);

const openAIClient = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function getChatCompletion() {
  try {
      const chatCompletion = await openAIClient.chat.completions.create({
          model: "gpt-3.5-turbo",
          messages: [
              { role: "system", content: "You are a helpful assistant." },
              { role: "user", content: "Hello!" }
          ],
      });

      console.log(chatCompletion); // Handle the response here
  } catch (error) {
      console.error("Error fetching chat completion:", error);
  }
}

// Call the async function
getChatCompletion();

module.exports = app;