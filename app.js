// DEPENDENCIES
const express = require("express");
const cors = require("cors");
const { OpenAI } = require("openai");
const { SpeechClient } = require("@google-cloud/speech"); // Google Speech-to-Text
const { Translate } = require("@google-cloud/translate").v2; // Google Translation
const textToSpeech = require("@google-cloud/text-to-speech"); // Google Text-to-Speech
const db = require("./db/dbConfig.js");
require("dotenv").config();

// OpenAI setup
const openAIClient = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Google Cloud setup
const speechClient = new SpeechClient(); // Google Speech-to-Text client
const translateClient = new Translate(); // Google Translation client
const ttsClient = new textToSpeech.TextToSpeechClient(); // Google Text-to-Speech client

// CONFIGURATION
const app = express();

// MIDDLEWARE
const corsOptions = {
  origin: 'http://localhost:5173', // Specify the frontend origin
  methods: ['GET', 'POST', 'OPTIONS'], // Allow these methods
  allowedHeaders: ['Content-Type', 'Authorization'], // Allow necessary headers
  credentials: true, // If you're using cookies or authorization headers
  optionsSuccessStatus: 204, // Respond successfully to preflight requests
};

app.use((cors));
app.use(express.json());
// Language code mapping for Google Translation API
const languageNames = {
  "en-US": "English",
  "es-ES": "Spanish",
  "fr-FR": "French",
  "ru-RU": "Russian",
  "it-IT": "Italian",
  "pl-PL": "Polish",
  "el-GR": "Greek",
  yi: "Yiddish",
  "he-IL": "Hebrew",
  "ht-HT": "Haitian Creole",
  "pt-PT": "Portuguese",
  "zh-CN": "Chinese (Simplified)",
  "zh-HK": "Chinese (Traditional)",
  "hi-IN": "Hindi",
  "bn-IN": "Bengali",
  "te-IN": "Telugu",
  "pa-IN": "Punjabi",
  "ta-IN": "Tamil",
  "ko-KR": "Korean",
  "ja-JP": "Japanese",
  "vi-VN": "Vietnamese",
  "ar-SA": "Arabic",
};

// Helper function: Speech-to-Text (Google Cloud Speech-to-Text API)
async function speechToText(audioBuffer, userLanguage) {
  const request = {
    audio: { content: audioBuffer.toString("base64") }, // Assuming audioBuffer is binary
    config: {
      encoding: "LINEAR16", // Adjust based on your audio input
      sampleRateHertz: 16000, // Adjust based on the input sample rate
      languageCode: userLanguage, // Process the audio in the user's language
    },
  };

  try {
    const [response] = await speechClient.recognize(request); // Google API call
    return response.results
      .map((result) => result.alternatives[0].transcript)
      .join("\n");
  } catch (error) {
    console.error("Error with Speech-to-Text:", error.message);
    throw new Error("Failed to convert audio to text.");
  }
}

// Helper function: Text Translation (Google Cloud Translation API)
async function translateText(text, targetLanguage) {
  try {
    if (!targetLanguage) {
      throw new Error(
        "A target language is required to perform a translation."
      );
    }

    // Map the target language code
    const mappedTargetLanguage =
      languageNames[targetLanguage] || targetLanguage;

    // Make the API call to Google Translate
    const [translation] = await translateClient.translate(
      text,
      mappedTargetLanguage
    );
    return translation;
  } catch (error) {
    console.error("Translation Error:", error.message);
    throw error;
  }
}

// Helper function: Text-to-Speech (Google Cloud Text-to-Speech API)
async function textToSpeechConversion(text, languageCode = "en-US") {
  const request = {
    input: { text },
    voice: { languageCode, ssmlGender: "NEUTRAL" },
    audioConfig: { audioEncoding: "MP3" },
  };
  const [response] = await ttsClient.synthesizeSpeech(request);
  return response.audioContent;
}

// Helper function: Fetch documents from the database based on visa type
async function getDocumentsFromDatabase(visaType) {
  try {
    const visaQuery = `SELECT id FROM visa_status WHERE name = $1;`;
    const visaResult = await db.query(visaQuery, [visaType]);
    const visaId = visaResult[0].id;

    const documentsQuery = `
      SELECT id_requirements.name, id_requirements.description
      FROM visa_requirements
      JOIN id_requirements ON visa_requirements.id_requirements_id = id_requirements.id
      WHERE visa_requirements.visa_status_id = $1;
    `;
    const documentsResult = await db.query(documentsQuery, [visaId]);

    return documentsResult;
  } catch (error) {
    console.error("Error fetching documents from the database:", error.message);
    throw error;
  }
}

// Function to generate the specific prompt based on user interactions
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

// Function to get chat completion from OpenAI
async function getChatCompletion(
  userMessage,
  userLanguage,
  userInteractions = {}
) {
  try {
    let prompt;
    let documentsNeeded = [];

    if (userInteractions.buttonClicks) {
      const visaType = userInteractions.buttonClicks.visa_type;
      try {
        documentsNeeded = await getDocumentsFromDatabase(visaType);
      } catch (error) {
        console.error("Error fetching documents:", error.message);
        documentsNeeded = [];
      }
      prompt = generatePrompt(userInteractions);
    } else {
      prompt = userMessage;
    }

    // Use the expanded languageNames object, fallback to the language code if not found
    const languageName = languageNames[userLanguage] || userLanguage;

    const chatCompletion = await openAIClient.chat.completions.create({
      model: "gpt-3.5-turbo",
      messages: [
        {
          role: "system",
          content: `You are an AI assistant, your tone should be courteous, friendly, and welcoming, and you must respond in ${languageName}.${documentsNeeded
            .map((doc) => `${doc.name}: ${doc.description}`)
            .join(
              ", "
            )}. Otherwise answer freely, maintaining your tone in ${languageName}.`,
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

app.post("/api/chat", async (req, res) => {
  try {
    const {
      message,
      audioInput,
      userLanguage,
      targetLanguage,
      userInteractions,
    } = req.body;

    console.log("Received data:", {
      message,
      userLanguage,
      targetLanguage,
      userInteractions,
    });

    if (!message && !audioInput) {
      return res
        .status(400)
        .json({ error: "Message or audio input is required." });
    }

    if (!targetLanguage) {
      return res.status(400).json({ error: "Target language is required." });
    }

    let userText = message;

    // Handle audio input if provided
    if (audioInput) {
      try {
        userText = await speechToText(audioInput, userLanguage);
        console.log("Converted speech to text:", userText);
      } catch (error) {
        console.error("Error converting audio to text:", error.message);
        return res
          .status(500)
          .json({ error: "Failed to process audio input." });
      }
    }

    // Get AI response
    let aiResponse;
    try {
      aiResponse = await getChatCompletion(
        userText,
        targetLanguage,
        userInteractions
      );
      console.log("OpenAI response:", aiResponse);
    } catch (error) {
      console.error("Error with OpenAI API:", error.message);
      return res.status(500).json({ error: "Failed to process AI response." });
    }

    // Convert to speech if needed
    let speechResponse = null;
    try {
      speechResponse = await textToSpeechConversion(aiResponse, targetLanguage);
    } catch (error) {
      console.error("Error converting text to speech:", error.message);
    }

    // Return response
    res.json({
      textResponse: aiResponse,
      audioResponse: speechResponse ? speechResponse.toString("base64") : null,
    });
  } catch (error) {
    console.error("Error processing chat request:", error.message);
    if (!res.headersSent) {
      res.status(500).json({
        error:
          error.message || "An error occurred while processing your request.",
      });
    }
  }
});

// Basic route for testing
app.get("/", async (req, res) => {
  try {
    const aiResponse = await getChatCompletion("Hello");
    res.send(`Welcome to Pat.io App<br><br>AI Response: ${aiResponse}`);
  } catch (error) {
    res.status(500).send("Error fetching AI response");
  }
});

module.exports = app;
