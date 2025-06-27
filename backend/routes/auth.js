const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { verifyToken } = require('../middleware/auth');

// Create or update user after authentication
router.post('/users', verifyToken, async (req, res) => {
  try {
    const { uid, email, provider } = req.user;
    const { displayName, photoURL } = req.body;
    
    // Check if user exists
    let user = await User.findByUid(uid);
    
    if (user) {
      // Update last active
      user.lastActiveAt = new Date();
      await user.save();
      
      return res.json({
        message: 'User already exists',
        user: user.toPublicJSON(),
        isNewUser: false
      });
    }
    
    // Create new user
    user = new User({
      uid,
      email,
      provider,
      name: displayName || 'Unknown Builder',
      hasCompletedOnboarding: false
    });
    
    await user.save();
    
    res.status(201).json({
      message: 'User created successfully',
      user: user.toPublicJSON(),
      isNewUser: true
    });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({
      error: 'Failed to create user',
      message: error.message
    });
  }
});

// Get current user profile
router.get('/me', verifyToken, async (req, res) => {
  try {
    const user = await User.findByUid(req.user.uid);
    
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    res.json({
      user: user.toJSON()
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      error: 'Failed to get user',
      message: error.message
    });
  }
});

// Update user profile
router.put('/me', verifyToken, async (req, res) => {
  try {
    const user = await User.findByUid(req.user.uid);
    
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    // Allowed fields to update
    const allowedFields = [
      'name', 'age', 'location', 'building', 
      'miniStatement', 'isPrivate', 'notifications'
    ];
    
    // Update only allowed fields
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        user[field] = req.body[field];
      }
    });
    
    await user.save();
    
    res.json({
      message: 'Profile updated successfully',
      user: user.toJSON()
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({
      error: 'Failed to update user',
      message: error.message
    });
  }
});

// Complete onboarding
router.post('/onboarding/complete', verifyToken, async (req, res) => {
  try {
    const { introVideoUrl } = req.body;
    
    if (!introVideoUrl) {
      return res.status(400).json({
        error: 'Intro video URL is required'
      });
    }
    
    const user = await User.findByUid(req.user.uid);
    
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    user.profileVideoUrl = introVideoUrl;
    user.hasCompletedOnboarding = true;
    await user.save();
    
    res.json({
      message: 'Onboarding completed successfully',
      user: user.toJSON()
    });
  } catch (error) {
    console.error('Complete onboarding error:', error);
    res.status(500).json({
      error: 'Failed to complete onboarding',
      message: error.message
    });
  }
});

module.exports = router;