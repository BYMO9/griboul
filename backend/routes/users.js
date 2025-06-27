const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Video = require('../models/Video');
const { verifyToken, optionalAuth } = require('../middleware/auth');

// Get user by UID
router.get('/:uid', optionalAuth, async (req, res) => {
  try {
    const user = await User.findByUid(req.params.uid);
    
    if (!user || !user.isActive) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    // Return public info only unless it's the user themselves
    const isOwnProfile = req.user && req.user.uid === req.params.uid;
    
    if (isOwnProfile) {
      res.json({
        user: user.toJSON(),
        hasCompletedOnboarding: user.hasCompletedOnboarding
      });
    } else {
      res.json({
        user: user.toPublicJSON()
      });
    }
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      error: 'Failed to get user',
      message: error.message
    });
  }
});

// Update user profile (same as auth/me but using uid)
router.put('/:uid', verifyToken, async (req, res) => {
  try {
    // Only allow users to update their own profile
    if (req.user.uid !== req.params.uid) {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only update your own profile'
      });
    }
    
    const user = await User.findByUid(req.params.uid);
    
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    // Allowed fields to update
    const allowedFields = [
      'name', 'age', 'location', 'building', 
      'miniStatement', 'isPrivate', 'notifications',
      'hasCompletedOnboarding'
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

// Get user's videos
router.get('/:uid/videos', optionalAuth, async (req, res) => {
  try {
    const { uid } = req.params;
    const { page = 1, limit = 20 } = req.query;
    
    const user = await User.findByUid(uid);
    
    if (!user || !user.isActive) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    // Check if requesting own videos (can see private ones)
    const isOwnProfile = req.user && req.user.uid === uid;
    
    const query = {
      userId: user._id,
      isActive: true,
      status: 'ready'
    };
    
    // Only show public videos unless it's the user's own profile
    if (!isOwnProfile) {
      query.isPrivate = false;
    }
    
    const skip = (page - 1) * limit;
    
    const videos = await Video.find(query)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .select('-transcript');
    
    const total = await Video.countDocuments(query);
    
    res.json({
      videos: videos.map(v => v.toPublicJSON()),
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        hasMore: total > skip + videos.length
      }
    });
  } catch (error) {
    console.error('Get user videos error:', error);
    res.status(500).json({
      error: 'Failed to get user videos',
      message: error.message
    });
  }
});

// Get nearby builders
router.get('/nearby/:location', verifyToken, async (req, res) => {
  try {
    const { location } = req.params;
    const { limit = 20 } = req.query;
    
    const users = await User.findNearbyUsers(location, parseInt(limit));
    
    res.json({
      users: users.map(u => u.toPublicJSON()),
      location,
      count: users.length
    });
  } catch (error) {
    console.error('Get nearby users error:', error);
    res.status(500).json({
      error: 'Failed to get nearby users',
      message: error.message
    });
  }
});

// Delete user account
router.delete('/:uid', verifyToken, async (req, res) => {
  try {
    // Only allow users to delete their own account
    if (req.user.uid !== req.params.uid) {
      return res.status(403).json({
        error: 'Forbidden',
        message: 'You can only delete your own account'
      });
    }
    
    const user = await User.findByUid(req.params.uid);
    
    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }
    
    // Soft delete - just mark as inactive
    user.isActive = false;
    await user.save();
    
    // Also deactivate all user's videos
    await Video.updateMany(
      { userId: user._id },
      { isActive: false }
    );
    
    res.json({
      message: 'Account deleted successfully'
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      error: 'Failed to delete account',
      message: error.message
    });
  }
});

module.exports = router;