const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  // Firebase Auth UID (primary identifier)
  uid: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  
  // Basic Info
  email: {
    type: String,
    required: true,
    lowercase: true,
    trim: true
  },
  
  // Profile Info (extracted from intro video)
  name: {
    type: String,
    required: true,
    trim: true
  },
  
  age: {
    type: Number,
    min: 13,
    max: 120
  },
  
  location: {
    type: String,
    trim: true
  },
  
  building: {
    type: String,
    trim: true,
    maxLength: 500
  },
  
  // Profile Video
  profileVideoUrl: {
    type: String
  },
  
  // Mini Statement (AI-generated description)
  miniStatement: {
    type: String,
    maxLength: 200
  },
  
  // Auth Provider - Fixed to accept 'google.com'
  provider: {
    type: String,
    enum: ['google', 'google.com', 'apple', 'apple.com', 'email', 'password'],
    default: 'google'
  },
  
  // Onboarding Status
  hasCompletedOnboarding: {
    type: Boolean,
    default: false
  },
  
  // Privacy Settings
  isPrivate: {
    type: Boolean,
    default: false
  },
  
  // Stats
  videoCount: {
    type: Number,
    default: 0
  },
  
  totalViews: {
    type: Number,
    default: 0
  },
  
  connectionCount: {
    type: Number,
    default: 0
  },
  
  // Notification Settings
  notifications: {
    dailyReminder: {
      type: Boolean,
      default: true
    },
    messages: {
      type: Boolean,
      default: true
    },
    emailUpdates: {
      type: Boolean,
      default: false
    }
  },
  
  // Account Status
  isActive: {
    type: Boolean,
    default: true
  },
  
  lastActiveAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true // Adds createdAt and updatedAt automatically
});

// Indexes for efficient queries
userSchema.index({ location: 1 });
userSchema.index({ createdAt: -1 });
userSchema.index({ miniStatement: 'text' });

// Instance methods
userSchema.methods.toPublicJSON = function() {
  return {
    uid: this.uid,
    name: this.name,
    location: this.location,
    building: this.building,
    miniStatement: this.miniStatement,
    videoCount: this.videoCount,
    connectionCount: this.connectionCount,
    createdAt: this.createdAt
  };
};

// Update last active timestamp
userSchema.methods.updateLastActive = function() {
  this.lastActiveAt = new Date();
  return this.save();
};

// Static methods
userSchema.statics.findByUid = function(uid) {
  return this.findOne({ uid });
};

userSchema.statics.findNearbyUsers = function(location, limit = 20) {
  return this.find({ 
    location: new RegExp(location, 'i'),
    isActive: true,
    isPrivate: false
  })
  .limit(limit)
  .select('name location building miniStatement profileVideoUrl');
};

module.exports = mongoose.model('User', userSchema);