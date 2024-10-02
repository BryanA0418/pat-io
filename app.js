// DEPENDENCIES
const cors = require("cors");
const express = require("express");
const { OpenAI } = require("openai");
require("dotenv").config();
const db = require("./db/dbConfig.js");
const openAIClient = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// CONFIGURATION
const app = express();

// MIDDLEWARE
app.use(cors());
app.use(express.json());

// ROUTES
app.get("/", async (req, res) => {
  try {
    // const aiResponse = await handleRootRequest(); // Call the new async function
    res.send(`Welcome to Pat.io App<br><br>AI Response: ${aiResponse}`);
  } catch (error) {
    res.status(500).send("Error fetching AI response");
  }
});

app.post("/chat", async (req, res) => {
  try {
    const { message, userInteractions } = req.body;
    console.log("Received message:", message);
    console.log("Received userInteractions:", userInteractions);

    const aiResponse = await getChatCompletion(message, userInteractions);

    res.json({ response: aiResponse });
  } catch (error) {
    console.error("Error:", error);
    res
      .status(500)
      .json({ response: "Sorry, there was an error processing your request." });
  }
});

async function getDocumentsFromDatabase(visaType) {
  try {
    // Query to find the visa status ID based on the visa_type
    const visaQuery = `
      SELECT id FROM visa_status WHERE name = $1;
    `;
    const visaResult = await db.query(visaQuery, [visaType]);

    // Log the entire visaResult to check what is returned
    console.log("Visa Query Result:", visaResult[0].id);
    const visaId = visaResult[0].id;

    // Now, query the required documents for the given visa ID
    const documentsQuery = `
      SELECT id_requirements.name, id_requirements.description
      FROM visa_requirements
      JOIN id_requirements ON visa_requirements.id_requirements_id = id_requirements.id
      WHERE visa_requirements.visa_status_id = $1;
    `;
    const documentsResult = await db.query(documentsQuery, [visaId]);

    // Log the entire documentsResult to check what is returned
    console.log("Documents Query Result:", documentsResult);

    return documentsResult; // Return the list of documents needed for the visa type
  } catch (error) {
    console.error("Error fetching documents from the database:", error.message);
    throw error;
  }
}

// Create the new async function for the "/" route
async function handleRootRequest() {
  try {
    const chatCompletion = await openAIClient.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        { role: "system", content: "You are a helpful assistant." },
        { role: "user", content: "Hello" },
      ],
    });

    return chatCompletion.choices[0].message.content;
  } catch (error) {
    console.error("Error fetching AI response:", error);
    throw error;
  }
}

// Function to generate the specific prompt based on userInteractions
function generatePrompt(userInteractions) {
  const { subject, valid_visa, visa_type, request_info } =
    userInteractions.buttonClicks;

  const validVisaText =
    valid_visa === true
      ? "true"
      : valid_visa === false
      ? "false"
      : "not specified";

  return `I am looking to apply for ${
    subject || "a specific subject"
  }, it is ${validVisaText} that my visa is valid, my visa is ${
    visa_type || "not specified"
  }, and I am looking for ${request_info || "some information"}.`;
}

// Modify the getChatCompletion function to use the specific prompt structure
async function getChatCompletion(userMessage, userInteractions = {}) {
  try {
    let prompt;
    let documentsNeeded = [];

    if (userInteractions.buttonClicks) {
      const visaType = userInteractions.buttonClicks.visa_type;

      try {
        documentsNeeded = await getDocumentsFromDatabase(visaType);
        console.log("Documents Needed:3", documentsNeeded);
      } catch (error) {
        console.error("Error fetching documents:", error.message);
        documentsNeeded = []; // Handle the case where no documents are found or error occurs
      }
      prompt = generatePrompt(userInteractions);
    } else {
      prompt = userMessage;
    }

    console.log("Generated Prompt:3", prompt);
    const chatCompletion = await openAIClient.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        {
          role: "system",
          content: `You are an AI assistant helping migrants get their SSN. Your tone should be courteous, friendly and welcoming.  If a person is asking for documents required for H-1B visa, tell them they need the following documents: ${documentsNeeded
            .map((doc) => `${doc.name}: ${doc.description}`)
            .join(", ")}.`,
        },
        { role: "user", content: prompt || userMessage },
      ],
    });

    return chatCompletion.choices[0].message.content;
  } catch (error) {
    console.error("Error fetching chat completion:", error);
    throw error;
  }
}
module.exports = app;
