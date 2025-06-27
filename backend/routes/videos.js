const express = require('express');
const router = express.Router();
const AWS = require('aws-sdk');
const Video = require('../models/Video');
const User = require('../models/User');
const { verifyToken, optionalAuth } = require('../middleware/auth');

// Configure AWS
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION
});

// Generate presigned URL for video upload
router.post('/presigned-url', verifyToken, async (req, res) => {
  try {
    const { fileName } = req.body;
    
    if (!fileName) {
      return res.status(400).json({
        error: 'Filename is required'
      });
    }
    
    // Generate unique key
    const key = `videos/${req.user.uid}/${Date.now()}_${fileName}`;
    
    // Generate presigned URL
    const params = {
      Bucket: process.env.S3_BUCKET_NAME,
      Key: key,
      Expires: 300, // URL expires in 5 minutes
      ContentType: 'video/mp4'
    };
    
    const uploadUrl = await s3.getSignedUrlPromise('putObject', params);
    const videoUrl = `https://${process.env.S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
    
    res.json({
      uploadUrl,
      videoUrl,
      key
    });
  } catch (error) {
    console.error('Presigned URL error:', error);
    res.status(500).json({
      error: 'Failed to generate upload URL',
      message: error.message
    });
  }
});

// Confirm video upload and create video record
router.post('/upload-complete', verifyToken, async (req, res) => {
  try {
    const { videoUrl, duration, prompt, isPrivate, location } = req.body;
    
    if (!videoUrl || !duration) {
      return res.status(400).json({
        error: 'Video URL and duration are required'
      });
    }
    
    // Get user
    const user = await User.findByUid(req.user.uid);
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    // Create video record
    const video = new Video({
      userId: user._id,
      videoUrl,
      duration,
      prompt: prompt || null,
      isPrivate: isPrivate || false,
      location: location || user.location || 'Unknown',
      status: 'processing'
    });
    
    await video.save();
    
    // Increment user's video count
    user.videoCount += 1;
    await user.save();
    
    res.json({
      message: 'Video uploaded successfully',
      video: video.toPublicJSON(),
      videoId: video._id
    });
  } catch (error) {
    console.error('Upload complete error:', error);
    res.status(500).json({
      error: 'Failed to complete upload',
      message: error.message
    });
  }
});

// Get video feed (world/near)
router.get('/feed', optionalAuth, async (req, res) => {
  try {
    const { filter = 'world', page = 1, limit = 20 } = req.query;
    
    let location = null;
    let userId = null;
    
    // If authenticated, get user's location
    if (req.user) {
      const user = await User.findByUid(req.user.uid);
      if (user) {
        location = user.location;
        userId = user._id;
      }
    }
    
    const feed = await Video.getFeed({
      filter,
      location,
      page: parseInt(page),
      limit: parseInt(limit),
      userId
    });
    
    res.json(feed);
  } catch (error) {
    console.error('Get feed error:', error);
    res.status(500).json({
      error: 'Failed to get feed',
      message: error.message
    });
  }
});

// Get specific video
router.get('/:videoId', optionalAuth, async (req, res) => {
  try {
    const video = await Video.findById(req.params.videoId)
      .populate('userId', 'name location miniStatement');
    
    if (!video || !video.isActive) {
      return res.status(404).json({
        error: 'Video not found'
      });
    }
    
    // Check if video is private
    if (video.isPrivate && (!req.user || req.user.uid !== video.userId.uid)) {
      return res.status(403).json({
        error: 'This video is private'
      });
    }
    
    // Increment views
    await video.incrementViews();
    
    res.json({
      video: video.toPublicJSON(true)
    });
  } catch (error) {
    console.error('Get video error:', error);
    res.status(500).json({
      error: 'Failed to get video',
      message: error.message
    });
  }
});

// Update video status (after AI processing)
router.put('/:videoId/status', verifyToken, async (req, res) => {
  try {
    const { status, miniStatement, transcript, categories, mood, processingError } = req.body;
    
    const video = await Video.findById(req.params.videoId);
    
    if (!video) {
      return res.status(404).json({
        error: 'Video not found'
      });
    }
    
    // Verify ownership
    const user = await User.findByUid(req.user.uid);
    if (!user || !video.userId.equals(user._id)) {
      return res.status(403).json({
        error: 'You can only update your own videos'
      });
    }
    
    // Update fields
    if (status) video.status = status;
    if (miniStatement) video.miniStatement = miniStatement;
    if (transcript) video.transcript = transcript;
    if (categories) video.categories = categories;
    if (mood) video.mood = mood;
    if (processingError) video.processingError = processingError;
    
    await video.save();
    
    res.json({
      message: 'Video updated successfully',
      video: video.toPublicJSON()
    });
  } catch (error) {
    console.error('Update video error:', error);
    res.status(500).json({
      error: 'Failed to update video',
      message: error.message
    });
  }
});

// Delete video
router.delete('/:videoId', verifyToken, async (req, res) => {
  try {
    const video = await Video.findById(req.params.videoId);
    
    if (!video) {
      return res.status(404).json({
        error: 'Video not found'
      });
    }
    
    // Verify ownership
    const user = await User.findByUid(req.user.uid);
    if (!user || !video.userId.equals(user._id)) {
      return res.status(403).json({
        error: 'You can only delete your own videos'
      });
    }
    
    // Soft delete
    video.isActive = false;
    await video.save();
    
    // Update user's video count
    user.videoCount = Math.max(0, user.videoCount - 1);
    await user.save();
    
    res.json({
      message: 'Video deleted successfully'
    });
  } catch (error) {
    console.error('Delete video error:', error);
    res.status(500).json({
      error: 'Failed to delete video',
      message: error.message
    });
  }
});

// Get daily prompt
router.get('/prompt/daily', verifyToken, async (req, res) => {
  try {
    const prompts = [
      "What's the hardest problem you faced today?",
      "Show us what you're building right now",
      "What small win are you celebrating?",
      "What's keeping you up at night?",
      "Share your workspace and current challenge",
      "What did you learn today?",
      "Show us your latest prototype",
      "What feedback did you get today?",
      "What's your biggest obstacle right now?",
      "Share a moment of clarity you had",
    ];
    
    // Use date to consistently show same prompt for the day
    const today = new Date();
    const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / 86400000);
    const promptIndex = dayOfYear % prompts.length;
    
    res.json({
      prompt: prompts[promptIndex],
      date: today.toISOString().split('T')[0]
    });
  } catch (error) {
    console.error('Get prompt error:', error);
    res.status(500).json({
      error: 'Failed to get daily prompt',
      message: error.message
    });
  }
});

module.exports = router;