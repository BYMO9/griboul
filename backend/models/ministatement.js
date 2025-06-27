const mongoose = require('mongoose');

const miniStatementSchema = new mongoose.Schema({
  // References
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  
  videoId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Video',
    required: true,
    index: true
  },
  
  // The mini-statement text
  statement: {
    type: String,
    required: true,
    maxLength: 200,
    index: 'text'
  },
  
  // Vector embedding for semantic search
  embedding: {
    type: [Number], // Array of floats from OpenAI embeddings
    validate: {
      validator: function(v) {
        return Array.isArray(v) && v.length === 1536; // OpenAI embedding dimension
      },
      message: 'Embedding must be an array of 1536 numbers'
    }
  },
  
  // Extracted entities and metadata
  entities: {
    technologies: [String], // ["React", "AWS", "Node.js"]
    challenges: [String],   // ["deployment", "scaling", "bugs"]
    emotions: [String],     // ["frustrated", "excited", "tired"]
    timeOfDay: String,      // "late night", "early morning", "weekend"
    stage: String          // "ideation", "building", "launching", "scaling"
  },
  
  // Search optimization
  keywords: [{
    type: String,
    lowercase: true
  }],
  
  // Usage stats
  searchHits: {
    type: Number,
    default: 0
  },
  
  // Quality score (for ranking)
  qualityScore: {
    type: Number,
    default: 1.0,
    min: 0,
    max: 10
  }
}, {
  timestamps: true
});

// Indexes for efficient search
miniStatementSchema.index({ 'entities.technologies': 1 });
miniStatementSchema.index({ 'entities.challenges': 1 });
miniStatementSchema.index({ 'entities.stage': 1 });
miniStatementSchema.index({ keywords: 1 });

// Instance methods
miniStatementSchema.methods.incrementSearchHits = function() {
  this.searchHits += 1;
  return this.save();
};

// Static methods for semantic search
miniStatementSchema.statics.semanticSearch = async function(queryEmbedding, options = {}) {
  const {
    limit = 20,
    threshold = 0.7, // Cosine similarity threshold
    filters = {}
  } = options;
  
  // This is a simplified version. In production, you'd use a vector database
  // like Pinecone, Weaviate, or MongoDB Atlas Vector Search
  
  const pipeline = [
    // Add filters if provided
    ...(Object.keys(filters).length > 0 ? [{ $match: filters }] : []),
    
    // Add cosine similarity calculation
    {
      $addFields: {
        similarity: {
          $divide: [
            {
              $reduce: {
                input: { $zip: { inputs: ['$embedding', queryEmbedding] } },
                initialValue: 0,
                in: { $add: ['$$value', { $multiply: ['$$this'] }] }
              }
            },
            {
              $sqrt: {
                $multiply: [
                  { $reduce: {
                    input: '$embedding',
                    initialValue: 0,
                    in: { $add: ['$$value', { $multiply: ['$$this', '$$this'] }] }
                  }},
                  { $reduce: {
                    input: queryEmbedding,
                    initialValue: 0,
                    in: { $add: ['$$value', { $multiply: ['$$this', '$$this'] }] }
                  }}
                ]
              }
            }
          ]
        }
      }
    },
    
    // Filter by similarity threshold
    { $match: { similarity: { $gte: threshold } } },
    
    // Sort by similarity
    { $sort: { similarity: -1 } },
    
    // Limit results
    { $limit: limit },
    
    // Populate video data
    {
      $lookup: {
        from: 'videos',
        localField: 'videoId',
        foreignField: '_id',
        as: 'video'
      }
    },
    { $unwind: '$video' },
    
    // Populate user data
    {
      $lookup: {
        from: 'users',
        localField: 'userId',
        foreignField: '_id',
        as: 'user'
      }
    },
    { $unwind: '$user' }
  ];
  
  return this.aggregate(pipeline);
};

// Find similar videos based on entities
miniStatementSchema.statics.findSimilar = function(miniStatement, limit = 10) {
  const query = {
    _id: { $ne: miniStatement._id },
    $or: [
      { 'entities.technologies': { $in: miniStatement.entities.technologies || [] } },
      { 'entities.challenges': { $in: miniStatement.entities.challenges || [] } },
      { 'entities.stage': miniStatement.entities.stage }
    ]
  };
  
  return this.find(query)
    .populate('videoId userId')
    .limit(limit)
    .sort({ qualityScore: -1, searchHits: -1 });
};

module.exports = mongoose.model('MiniStatement', miniStatementSchema);