const jwt = require('jsonwebtoken');
const { logger } = require('@librechat/data-schemas');
const { setAuthTokens, registerUser } = require('~/server/services/AuthService');
const { findUser, getUserById, updateUser } = require('~/models');

const ACCOUNTex_JWT_SECRET = process.env.NEXTAUTH_SECRET || 'accountexai-super-secret-jwt-key-change-in-production-32chars';
const ACCOUNTex_JWT_ISSUER = process.env.NEXTAUTH_URL || 'https://accountexai-frontend.vercel.app';

/**
 * External login controller for AccountexAI integration.
 * Accepts an AccountexAI JWT, validates it, and creates a LibreChat session.
 */
const externalLoginController = async (req, res) => {
  try {
    const { externalToken } = req.body;

    if (!externalToken) {
      return res.status(400).json({ message: 'External token is required' });
    }

    // Verify the AccountexAI JWT
    let payload;
    try {
      payload = jwt.verify(externalToken, ACCOUNTex_JWT_SECRET, {
        issuer: ACCOUNTex_JWT_ISSUER,
      });
    } catch (err) {
      logger.error('[externalLoginController] Invalid external token:', err.message);
      return res.status(401).json({ message: 'Invalid or expired external token' });
    }

    const { sub: userId, email, name, role } = payload;

    if (!email) {
      return res.status(401).json({ message: 'Invalid token payload: missing email' });
    }

    // Find or create LibreChat user
    let user = await findUser({ email }, 'email _id username name provider role');

    if (!user) {
      // Create new user with 'external' provider
      logger.info(`[externalLoginController] Creating new LibreChat user for: ${email}`);

      // Use registerUser but without password validation
      const newUserData = {
        email,
        name: name || email.split('@')[0],
        username: email.split('@')[0],
        provider: 'external',
        password: '', // No password - auth via external JWT only
      };

      // We need to create the user directly since registerUser has validation
      const mongoose = require('mongoose');
      const { User } = require('@librechat/data-schemas');

      const existingUser = await User.findOne({ email });
      if (existingUser) {
        user = existingUser;
      } else {
        const isFirstRegisteredUser = (await User.countDocuments({})) === 0;
        const salt = require('bcryptjs').genSaltSync(10);

        const createdUser = await User.create({
          email,
          name: newUserData.name,
          username: newUserData.username,
          provider: 'external',
          password: require('bcryptjs').hashSync(newUserData.password, salt),
          role: isFirstRegisteredUser ? 'admin' : 'user',
          emailVerified: true, // External auth means email is already verified
        });

        user = await getUserById(createdUser._id);
      }
    }

    // Create LibreChat session tokens
    const token = await setAuthTokens(user._id, res);

    // Return user info (excluding sensitive fields)
    const { password: _, __v, ...userInfo } = user.toObject ? user.toObject() : user;
    userInfo.id = userInfo._id.toString();

    return res.status(200).send({ token, user: userInfo });
  } catch (err) {
    logger.error('[externalLoginController] Error:', err);
    return res.status(500).json({ message: 'Something went wrong' });
  }
};

module.exports = {
  externalLoginController,
};
