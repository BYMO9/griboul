const mongoose = require('mongoose');

const videoSchema = new mongoose.Schema({
  // Owner
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  
  // Video Files
  videoUrl: {
    type: String,
    required: true
  },
  
  thumbnailUrl: {
    type: String
  },
  
  // Video Info
  duration: {
    type: Number, // in seconds
    required: true,
    min: 1,
    max: 300 // 5 minutes max
  },
  
  // AI-Generated Content
  miniStatement: {
    type: String,
    maxLength: 200,
    index: 'text'
  },
  
  transcript: {
    type: String
  },
  
  // Daily Prompt (if applicable)
  prompt: {
    type: String
  },
  
  // Privacy
  isPrivate: {
    type: Boolean,
    default: false,
    index: true
  },
  
  // Location (copied from user at time of posting)
  location: {
    type: String,
    index: true
  },
  
  // Stats
  views: {
    type: Number,
    default: 0
  },
  
  likes: {
    type: Number,
    default: 0
  },
  
  // Metadata
  recordedAt: {
    type: Date,
    default: Date.now
  },
  
  // Processing Status
  status: {
    type: String,
    enum: ['processing', 'ready', 'failed'],
    default: 'processing',
    index: true
  },
  
  processingError: {
    type: String
  },
  
  // Moderation
  isReported: {
    type: Boolean,
    default: false
  },
  
  isActive: {
    type: Boolean,
    default: true
  },
  
  // Categories (AI-detected)
  categories: [{
    type: String,
    enum: ['building', 'debugging', 'launched', 'pivot', 'struggle', 'win', 'update']
  }],
  
  // Mood (AI-detected)
  mood: {
    type: String,
    enum: ['excited', 'frustrated', 'hopeful', 'tired', 'celebrating', 'focused', 'neutral']
  }
}, {
  timestamps: true
});

// Compound indexes for efficient queries
videoSchema.index({ userId: 1, createdAt: -1 });
videoSchema.index({ location: 1, createdAt: -1 });
videoSchema.index({ isPrivate: 1, status: 1, createdAt: -1 });
videoSchema.index({ categories: 1, createdAt: -1 });

// Virtual for formatted duration
videoSchema.virtual('formattedDuration').get(function() {
  const minutes = Math.floor(this.duration / 60);
  const seconds = this.duration % 60;
  return `${minutes}:${seconds.toString().padLeft(2, '0')}`;
});

// Instance methods
videoSchema.methods.incrementViews = function() {
  this.views += 1;
  return this.save();
};

videoSchema.methods.toPublicJSON = function(includeUser = false) {
  const video = {
    _id: this._id,
    videoUrl: this.videoUrl,
    thumbnailUrl: this.thumbnailUrl,
    duration: this.duration,
    miniStatement: this.miniStatement,
    location: this.location,
    views: this.views,
    likes: this.likes,
    categories: this.categories,
    mood: this.mood,
    createdAt: this.createdAt
  };
  
  if (includeUser && this.userId) {
    video.user = this.userId;
  }
  
  return video;
};

// Static methods
videoSchema.statics.getFeed = async function(options = {}) {
  const {
    filter = 'world', // world or near
    location = null,
    page = 1,
    limit = 20,
    userId = null
  } = options;
  
  const query = {
    isPrivate: false,
    status: 'ready',
    isActive: true
  };
  
  // Filter by location for "near" feed
  if (filter === 'near' && location) {
    query.location = new RegExp(location, 'i');
  }
  
  // Exclude user's own videos if userId provided
  if (userId) {
    query.userId = { $ne: userId };
  }
  
  const skip = (page - 1) * limit;
  
  const videos = await this.find(query)
    .populate('userId', 'name location miniStatement')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);
    
  const total = await this.countDocuments(query);
  const hasMore = total > skip + videos.length;
  
  return {
    videos,
    page,
    limit,
    total,
    hasMore
  };
};

videoSchema.statics.getUserVideos = function(userId, includePrivate = false) {
  const query = { userId, isActive: true };
  
  if (!includePrivate) {
    query.isPrivate = false;
  }
  
  return this.find(query)
    .sort({ createdAt: -1 })
    .select('-transcript');
};

videoSchema.statics.searchByDescription = async function(searchQuery, limit = 20) {
  return this.find({
    $text: { $search: searchQuery },
    isPrivate: false,
    status: 'ready',
    isActive: true
  })
  .populate('userId', 'name location miniStatement')
  .limit(limit)
  .sort({ score: { $meta: 'textScore' } });
};

module.exports = mongoose.model('Video', videoSchema);