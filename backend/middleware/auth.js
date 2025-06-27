const admin = require('firebase-admin');

// For now, we'll use mock authentication
const verifyToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: 'Unauthorized',
        message: 'No token provided'
      });
    }
    
    // Mock user for development
    req.user = {
      uid: 'test-user-123',
      email: 'test@example.com',
      emailVerified: true,
      provider: 'google.com'
    };
    
    next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return res.status(500).json({
      error: 'Internal Server Error',
      message: 'Authentication failed'
    });
  }
};

const optionalAuth = async (req, res, next) => {
  // For optional auth, just continue
  next();
};

module.exports = {
  verifyToken,
  optionalAuth
};