const express = require('express');
const router = express.Router();
const OpenAI = require('openai');
const Video = require('../models/Video');
const MiniStatement = require('../models/MiniStatement');
const User = require('../models/User');
const { verifyToken } = require('../middleware/auth');

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

// Generate mini-statement from video
router.post('/generate-statement', verifyToken, async (req, res) => {
  try {
    const { videoId, transcript } = req.body;
    
    if (!videoId || !transcript) {
      return res.status(400).json({
        error: 'Video ID and transcript are required'
      });
    }
    
    // Get video and user
    const video = await Video.findById(videoId);
    if (!video) {
      return res.status(404).json({
        error: 'Video not found'
      });
    }
    
    const user = await User.findById(video.userId);
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    // Generate mini-statement using GPT-4
    const completion = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: `You are a concise writer who creates compelling one-line descriptions of builder's video updates. 
          Focus on the emotional journey and specific challenges/wins. 
          Keep it under 100 characters. 
          Capture the essence of what they're building and their current state.
          Examples:
          - "Debugging payment integration at 2am, fueled by determination and instant ramen"
          - "First customer just paid! 6 months of building finally validated"
          - "Pivoting after user feedback - painful but necessary"`
        },
        {
          role: "user",
          content: `Create a mini-statement for this builder update: "${transcript}"`
        }
      ],
      temperature: 0.7,
      max_tokens: 50
    });
    
    const miniStatement = completion.choices[0].message.content.trim();
    
    // Extract entities and mood
    const analysisCompletion = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: `Analyze this builder update and extract:
          1. Technologies mentioned (e.g., React, AWS, Python)
          2. Challenges (e.g., debugging, scaling, fundraising)
          3. Emotions (e.g., frustrated, excited, tired)
          4. Stage (ideation, building, launching, scaling)
          5. Mood (excited, frustrated, hopeful, tired, celebrating, focused, neutral)
          
          Return as JSON only.`
        },
        {
          role: "user",
          content: transcript
        }
      ],
      temperature: 0.3,
      max_tokens: 200
    });
    
    let analysis = {};
    try {
      analysis = JSON.parse(analysisCompletion.choices[0].message.content);
    } catch (e) {
      console.error('Failed to parse analysis:', e);
    }
    
    // Generate embedding for semantic search
    const embeddingResponse = await openai.embeddings.create({
      model: "text-embedding-ada-002",
      input: `${miniStatement} ${transcript}`.substring(0, 8000)
    });
    
    const embedding = embeddingResponse.data[0].embedding;
    
    // Create MiniStatement record
    const miniStatementDoc = new MiniStatement({
      userId: user._id,
      videoId: video._id,
      statement: miniStatement,
      embedding,
      entities: {
        technologies: analysis.technologies || [],
        challenges: analysis.challenges || [],
        emotions: analysis.emotions || [],
        stage: analysis.stage || 'building'
      },
      keywords: [
        ...miniStatement.toLowerCase().split(' '),
        ...user.location.toLowerCase().split(' '),
        user.name.toLowerCase()
      ].filter(k => k.length > 2)
    });
    
    await miniStatementDoc.save();
    
    // Update video with mini-statement and analysis
    video.miniStatement = miniStatement;
    video.categories = analysis.challenges || [];
    video.mood = analysis.mood || 'neutral';
    video.status = 'ready';
    await video.save();
    
    res.json({
      miniStatement,
      analysis,
      message: 'Mini-statement generated successfully'
    });
  } catch (error) {
    console.error('Generate statement error:', error);
    
    // Update video with error status
    if (req.body.videoId) {
      await Video.findByIdAndUpdate(req.body.videoId, {
        status: 'failed',
        processingError: error.message
      });
    }
    
    res.status(500).json({
      error: 'Failed to generate mini-statement',
      message: error.message
    });
  }
});

// Extract user info from intro video
router.post('/extract-user-info', verifyToken, async (req, res) => {
  try {
    const { transcript, videoUrl } = req.body;
    
    if (!transcript) {
      return res.status(400).json({
        error: 'Transcript is required'
      });
    }
    
    // Use GPT-4 to extract user information
    const completion = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: `Extract user information from their introduction video transcript.
          Look for:
          - Name (full name if possible)
          - Age (number only)
          - Location (city, country)
          - What they're building (brief description)
          
          Return as JSON with keys: name, age, location, building
          If any field is not mentioned, use null.`
        },
        {
          role: "user",
          content: transcript
        }
      ],
      temperature: 0.1,
      max_tokens: 200
    });
    
    let userInfo = {};
    try {
      userInfo = JSON.parse(completion.choices[0].message.content);
    } catch (e) {
      console.error('Failed to parse user info:', e);
      return res.status(500).json({
        error: 'Failed to extract user information'
      });
    }
    
    // Generate a mini-statement for the user
    const statementCompletion = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: `Create a one-line description of this builder based on their introduction.
          Keep it under 100 characters. Focus on what makes them unique.
          Examples:
          - "Building AI tools to help farmers in rural India"
          - "Serial founder tackling climate change through software"
          - "Ex-Google engineer bootstrapping a developer tools startup"`
        },
        {
          role: "user",
          content: `Name: ${userInfo.name}, Age: ${userInfo.age}, Location: ${userInfo.location}, Building: ${userInfo.building}`
        }
      ],
      temperature: 0.7,
      max_tokens: 50
    });
    
    userInfo.miniStatement = statementCompletion.choices[0].message.content.trim();
    
    res.json({
      userInfo,
      message: 'User info extracted successfully'
    });
  } catch (error) {
    console.error('Extract user info error:', error);
    res.status(500).json({
      error: 'Failed to extract user info',
      message: error.message
    });
  }
});

// Transcribe video (using Whisper API)
router.post('/transcribe', verifyToken, async (req, res) => {
  try {
    const { videoUrl } = req.body;
    
    if (!videoUrl) {
      return res.status(400).json({
        error: 'Video URL is required'
      });
    }
    
    // For now, return a mock transcript
    // In production, you would:
    // 1. Download video from S3
    // 2. Extract audio
    // 3. Send to Whisper API
    // 4. Return transcript
    
    const mockTranscript = "Hi, I'm a builder working on an AI startup. Today I spent 5 hours debugging our payment integration. Finally got it working after realizing it was a timezone issue. Small win but feels huge!";
    
    res.json({
      transcript: mockTranscript,
      message: 'Video transcribed successfully'
    });
  } catch (error) {
    console.error('Transcribe error:', error);
    res.status(500).json({
      error: 'Failed to transcribe video',
      message: error.message
    });
  }
});

// Process video completely (transcribe + generate statement)
router.post('/process-video', verifyToken, async (req, res) => {
  try {
    const { videoId, videoUrl } = req.body;
    
    if (!videoId || !videoUrl) {
      return res.status(400).json({
        error: 'Video ID and URL are required'
      });
    }
    
    // Update video status
    await Video.findByIdAndUpdate(videoId, { status: 'processing' });
    
    // Step 1: Transcribe (mock for now)
    const transcript = "Hi, I'm a builder working on an AI startup. Today I spent 5 hours debugging our payment integration. Finally got it working after realizing it was a timezone issue. Small win but feels huge!";
    
    // Step 2: Generate mini-statement and analysis
    const statementResponse = await fetch(`http://localhost:${process.env.PORT}/api/ai/generate-statement`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': req.headers.authorization
      },
      body: JSON.stringify({ videoId, transcript })
    });
    
    if (!statementResponse.ok) {
      throw new Error('Failed to generate statement');
    }
    
    const result = await statementResponse.json();
    
    res.json({
      message: 'Video processed successfully',
      transcript,
      miniStatement: result.miniStatement,
      analysis: result.analysis
    });
  } catch (error) {
    console.error('Process video error:', error);
    
    // Update video with error status
    if (req.body.videoId) {
      await Video.findByIdAndUpdate(req.body.videoId, {
        status: 'failed',
        processingError: error.message
      });
    }
    
    res.status(500).json({
      error: 'Failed to process video',
      message: error.message
    });
  }
});

module.exports = router;