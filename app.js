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
app.use(cors());
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
  "ur-PK": "Urdu",
  "tl-PH": "Tagalog",
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

// Function to get location info from OpenAI

async function getLocationBasedCompletion(prompt, userLanguage) {
  try {
    // Ensure we have the nearest office information
    if (!prompt) {
      throw new Error("Nearest office information is required.");
    }

    // Use the language name or fallback to the provided language code
    const languageName = languageNames[userLanguage] || userLanguage;

    console.log("Generated prompt for AI:", prompt);

    // Call OpenAI API to get the chat completion based on the prompt
    const chatCompletion = await openAIClient.chat.completions.create({
      model: "ft:gpt-4o-mini-2024-07-18:personal:patio-v4:AKT8xi0C",
      messages: [
        {
          role: "system",
          content: `"You are Pat.io, a helpful and friendly AI assistant. Your tone should be courteous and respectful. Provide this response in ${languageName}, maintaining a friendly tone, but use the data exactly as provided."`,
        },
        { role: "user", content: prompt },
      ],
    });

    // Return the generated response from the AI
    return chatCompletion.choices[0].message.content;
  } catch (error) {
    console.error("Error in getLocationBasedCompletion:", error);
    throw error; // Rethrow the error so it can be handled by the caller
  }
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
    if (userInteractions.buttonClicks.subject) {
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

    console.log("Prompt:Step 1", prompt);
    const chatCompletion = await openAIClient.chat.completions.create({
      model: "ft:gpt-4o-mini-2024-07-18:personal:patio-v4:AKT8xi0C",
      messages: [
        {
          role: "system",
          content: `"You are Pat.io, a helpful and friendly AI assistant. Your tone should be courteous and respectful. Your primary function is to provide information related to Social Security Numbers (SSN), Individual Taxpayer Identification Numbers (ITIN), and New York City Local Law 30. You may respond to greetings such as 'Hi' or 'Hello' in a friendly manner. However, for all other questions, you must only provide answers based on the data provided during fine-tuning and within the scope of SSN, ITIN, or Local Law 30. If a user asks a question outside this domain, politely decline by saying, 'I can only answer questions related to Social Security Numbers, ITIN, or New York City Local Law 30 and visa's. Please ask a question in this domain.' Always end your reply with 'How can Pat.io assist you further?' Also, remove all * from the response.", And maintaining your tone in ${languageName}. If the user is asking for ${
            userInteractions.buttonClicks.visa_type
          }, response back with the follow as a number list: ${documentsNeeded
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
// Route to handle ssa office location
app.post("/api/location", async (req, res) => {
  try {
    const { zipCode, userLanguage, targetLanguage } = req.body;
    console.log("Received zip code:", zipCode);

    if (!zipCode) {
      return res.status(400).json({ error: "Zip code is required." });
    }

    // 1. Get coordinates from the provided zip code using Zippopotam API
    const geocodingResponse = await fetch(
      `https://api.zippopotam.us/us/${zipCode}`
    );

    if (!geocodingResponse.ok) {
      throw new Error(`Geocoding API error: ${geocodingResponse.status}`);
    }

    const locationData = await geocodingResponse.json();

    if (!locationData.places || locationData.places.length === 0) {
      return res
        .status(404)
        .json({ error: "Location not found for the provided zip code." });
    }

    const place = locationData.places[0];
    const userLat = parseFloat(place["latitude"]);
    const userLon = parseFloat(place["longitude"]);

    // 2. Query the database for the nearest office using Haversine formula
    const nearestOfficeQuery = `
SELECT 
    id, 
    office_code, 
    office_name AS name, 
    address_line_1, 
    address_line_2, 
    address_line_3, 
    city, 
    state, 
    zip_code AS zipcode, 
    phone, 
    fax, 
    monday_open_time, 
    monday_close_time, 
    tuesday_open_time, 
    tuesday_close_time, 
    wednesday_open_time, 
    wednesday_close_time, 
    thursday_open_time, 
    thursday_close_time, 
    friday_open_time, 
    friday_close_time, 
    latitude, 
    longitude, 
    (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) AS distance 
FROM office_open_close_times 
ORDER BY distance 
LIMIT 1;
    `;

    const nearestOffice = await db.query(nearestOfficeQuery, [
      userLat,
      userLon,
    ]);

    console.log("Nearest Office Query Result:", nearestOffice);

    // 4. Generate AI response (assumed to use OpenAI or similar service)
    const prompt = `You are an AI assistant. Your tone should be courteous, friendly, and welcoming. When a user provides a zip code, respond with the following information:

The nearest Social Security Administration office to the provided zip code ${zipCode} is located in ${
      nearestOffice[0].city
    }, ${nearestOffice[0].state}, approximately ${
      Math.round(nearestOffice[0].distance * 10) / 10
    } kilometers away.

The office is named ${nearestOffice[0].name} and is located at:
${nearestOffice[0].address_line_1}, ${
      nearestOffice[0].address_line_2
        ? nearestOffice[0].address_line_2 + ","
        : ""
    } ${
      nearestOffice[0].address_line_3
        ? nearestOffice[0].address_line_3 + ","
        : ""
    } ${nearestOffice[0].city}, ${nearestOffice[0].state}, ${
      nearestOffice[0].zipcode
    }.

You can contact the office via phone at ${nearestOffice[0].phone} or fax at ${
      nearestOffice[0].fax
    }.

Office hours:
- Monday: ${nearestOffice[0].monday_open_time} to ${
      nearestOffice[0].monday_close_time
    }
- Tuesday: ${nearestOffice[0].tuesday_open_time} to ${
      nearestOffice[0].tuesday_close_time
    }
- Wednesday: ${nearestOffice[0].wednesday_open_time} to ${
      nearestOffice[0].wednesday_close_time
    }
- Thursday: ${nearestOffice[0].thursday_open_time} to ${
      nearestOffice[0].thursday_close_time
    }
- Friday: ${nearestOffice[0].friday_open_time} to ${
      nearestOffice[0].friday_close_time
    }

Please feel free to reach out if you need more information.`;
    const aiResponse = await getLocationBasedCompletion(prompt, targetLanguage);

    // 5. Send the response to the client
    console.log("AI Response:", aiResponse);
    res.json({
      textResponse: aiResponse,
    });
  } catch (error) {
    console.error("Error processing location request:", error);
    res.status(500).json({
      error: "An error occurred while processing your location request.",
      details: error.message,
    });
  }
});

// Route to handle the chat request
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
