const express = require('express');
const router = express.Router();
const OpenAI = require('openai');
const MiniStatement = require('../models/MiniStatement');
const Video = require('../models/Video');
const { verifyToken, optionalAuth } = require('../middleware/auth');

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY
});

// Descriptive search using embeddings
router.get('/descriptive', optionalAuth, async (req, res) => {
  try {
    const { q, limit = 20, page = 1 } = req.query;
    
    if (!q || q.trim().length < 3) {
      return res.status(400).json({
        error: 'Search query must be at least 3 characters'
      });
    }
    
    // Generate embedding for search query
    const embeddingResponse = await openai.embeddings.create({
      model: "text-embedding-ada-002",
      input: q
    });
    
    const queryEmbedding = embeddingResponse.data[0].embedding;
    
    // Perform semantic search
    const results = await MiniStatement.semanticSearch(queryEmbedding, {
      limit: parseInt(limit),
      threshold: 0.7
    });
    
    // Format results
    const formattedResults = results.map(result => ({
      video: {
        _id: result.video._id,
        videoUrl: result.video.videoUrl,
        thumbnailUrl: result.video.thumbnailUrl,
        duration: result.video.duration,
        views: result.video.views,
        createdAt: result.video.createdAt
      },
      user: {
        name: result.user.name,
        location: result.user.location,
        building: result.user.building
      },
      miniStatement: result.statement,
      similarity: result.similarity,
      entities: result.entities
    }));
    
    res.json({
      results: formattedResults,
      query: q,
      total: formattedResults.length
    });
  } catch (error) {
    console.error('Descriptive search error:', error);
    res.status(500).json({
      error: 'Search failed',
      message: error.message
    });
  }
});

// Simple text search (fallback)
router.get('/text', optionalAuth, async (req, res) => {
  try {
    const { q, limit = 20 } = req.query;
    
    if (!q || q.trim().length < 3) {
      return res.status(400).json({
        error: 'Search query must be at least 3 characters'
      });
    }
    
    // Search in mini-statements
    const statements = await MiniStatement.find({
      $text: { $search: q }
    })
    .populate('videoId userId')
    .limit(parseInt(limit))
    .sort({ score: { $meta: 'textScore' } });
    
    // Format results
    const results = statements
      .filter(s => s.videoId && s.userId)
      .map(statement => ({
        video: {
          _id: statement.videoId._id,
          videoUrl: statement.videoId.videoUrl,
          thumbnailUrl: statement.videoId.thumbnailUrl,
          duration: statement.videoId.duration,
          views: statement.videoId.views,
          createdAt: statement.videoId.createdAt
        },
        user: {
          name: statement.userId.name,
          location: statement.userId.location,
          building: statement.userId.building
        },
        miniStatement: statement.statement,
        entities: statement.entities
      }));
    
    res.json({
      results,
      query: q,
      total: results.length
    });
  } catch (error) {
    console.error('Text search error:', error);
    res.status(500).json({
      error: 'Search failed',
      message: error.message
    });
  }
});

// Search by category/tag
router.get('/category', optionalAuth, async (req, res) => {
  try {
    const { category, limit = 20, page = 1 } = req.query;
    
    if (!category) {
      return res.status(400).json({
        error: 'Category is required'
      });
    }
    
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Find videos with matching category
    const videos = await Video.find({
      categories: category,
      isPrivate: false,
      status: 'ready',
      isActive: true
    })
    .populate('userId', 'name location building')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));
    
    const total = await Video.countDocuments({
      categories: category,
      isPrivate: false,
      status: 'ready',
      isActive: true
    });
    
    res.json({
      results: videos.map(v => v.toPublicJSON(true)),
      category,
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      hasMore: total > skip + videos.length
    });
  } catch (error) {
    console.error('Category search error:', error);
    res.status(500).json({
      error: 'Search failed',
      message: error.message
    });
  }
});

// Get trending searches
router.get('/trending', async (req, res) => {
  try {
    // In production, you'd track actual search queries
    // For now, return curated trending searches
    const trending = [
      "founders debugging at night",
      "first customer celebration",
      "pivot stories",
      "bootstrapped builders",
      "AI startup challenges",
      "remote team struggles",
      "product launch day",
      "fundraising rejection",
      "10x growth hacks",
      "weekend building sessions"
    ];
    
    res.json({
      trending
    });
  } catch (error) {
    console.error('Trending searches error:', error);
    res.status(500).json({
      error: 'Failed to get trending searches',
      message: error.message
    });
  }
});

// Search suggestions (autocomplete)
router.get('/suggestions', async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q || q.length < 2) {
      return res.json({ suggestions: [] });
    }
    
    // Find mini-statements that start with the query
    const statements = await MiniStatement.find({
      statement: new RegExp(`^${q}`, 'i')
    })
    .limit(5)
    .select('statement');
    
    // Also search in keywords
    const keywordMatches = await MiniStatement.find({
      keywords: new RegExp(`^${q}`, 'i')
    })
    .limit(5)
    .select('keywords');
    
    // Combine and deduplicate suggestions
    const suggestions = new Set();
    
    statements.forEach(s => {
      suggestions.add(s.statement);
    });
    
    keywordMatches.forEach(k => {
      k.keywords.forEach(keyword => {
        if (keyword.toLowerCase().startsWith(q.toLowerCase())) {
          suggestions.add(keyword);
        }
      });
    });
    
    res.json({
      suggestions: Array.from(suggestions).slice(0, 10)
    });
  } catch (error) {
    console.error('Search suggestions error:', error);
    res.status(500).json({
      error: 'Failed to get suggestions',
      message: error.message
    });
  }
});

// Search by location
router.get('/location', optionalAuth, async (req, res) => {
  try {
    const { location, limit = 20, page = 1 } = req.query;
    
    if (!location) {
      return res.status(400).json({
        error: 'Location is required'
      });
    }
    
    const skip = (parseInt(page) - 1) * parseInt(limit);
    
    // Find videos from the location
    const videos = await Video.find({
      location: new RegExp(location, 'i'),
      isPrivate: false,
      status: 'ready',
      isActive: true
    })
    .populate('userId', 'name location building')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(parseInt(limit));
    
    const total = await Video.countDocuments({
      location: new RegExp(location, 'i'),
      isPrivate: false,
      status: 'ready',
      isActive: true
    });
    
    res.json({
      results: videos.map(v => v.toPublicJSON(true)),
      location,
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      hasMore: total > skip + videos.length
    });
  } catch (error) {
    console.error('Location search error:', error);
    res.status(500).json({
      error: 'Search failed',
      message: error.message
    });
  }
});

module.exports = router;