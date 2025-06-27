const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Create Express app
const app = express();

// Middleware
app.use(cors({
  origin: '*', // In production, replace with your Flutter app's URL
  credentials: true
}));
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// MongoDB connection - Won't crash if it fails
let isMongoConnected = false;

mongoose.connect(process.env.MONGODB_URI)
.then(() => {
  console.log('✅ Connected to MongoDB Atlas');
  isMongoConnected = true;
})
.catch((error) => {
  console.error('❌ MongoDB connection error:', error.message);
  console.log('⚠️  WARNING: Running without database connection');
  console.log('The server will continue running but database operations will fail');
  // Don't exit - let the server run
});

// Test models compilation
try {
  require('./models/User');
  require('./models/Video');
  require('./models/MiniStatement');
  console.log('✅ All models compiled successfully');
} catch (error) {
  console.error('❌ Model compilation error:', error);
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: isMongoConnected ? 'OK' : 'DEGRADED',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    mongodb: isMongoConnected ? 'connected' : 'disconnected',
    message: isMongoConnected ? 'All systems operational' : 'Running without database'
  });
});

// API routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/videos', require('./routes/videos'));
app.use('/api/ai', require('./routes/ai'));
app.use('/api/search', require('./routes/search'));

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} not found`
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  // MongoDB errors
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: 'Validation Error',
      details: Object.values(err.errors).map(e => e.message)
    });
  }
  
  if (err.name === 'CastError') {
    return res.status(400).json({
      error: 'Invalid ID format'
    });
  }
  
  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      error: 'Invalid token'
    });
  }
  
  // Default error
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`
🚀 Griboul Backend Server Started
📍 Environment: ${process.env.NODE_ENV}
🌐 Server URL: http://localhost:${PORT}
💚 Health Check: http://localhost:${PORT}/health
⏰ Started at: ${new Date().toISOString()}
${!isMongoConnected ? '\n⚠️  WARNING: Server running without database connection!' : ''}
  `);
});