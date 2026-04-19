require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const { errorHandler } = require('./middleware/errorHandler');

// ─── Route imports ─────────────────────────────────────────────
const authRouter = require('./routes/auth');
const diseasesRouter = require('./routes/diseases');
const treatmentsRouter = require('./routes/treatments');
const scansRouter = require('./routes/scans');
const communityRouter = require('./routes/community');
const weatherRouter = require('./routes/weather');
const shopsRouter = require('./routes/shops');

// ─── App setup ─────────────────────────────────────────────────
const app = express();
const PORT = process.env.PORT || 3000;

// ─── Middleware ────────────────────────────────────────────────
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(morgan('dev'));

// Rate limiter — 100 requests per 15 minutes per IP
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: { message: 'Too many requests, please try again later.' },
  },
});
app.use('/api/', limiter);

// ─── Health check ──────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: '🌱 CropDoc API is running!',
    version: '1.0.0',
    endpoints: {
      diseases: '/api/diseases',
      treatments: '/api/treatments/:diseaseKey',
      scans: '/api/scans',
      community: '/api/community/alerts',
      weather: '/api/weather',
      shops: '/api/shops',
    },
  });
});

// ─── API Routes ────────────────────────────────────────────────
app.use('/api/auth', authRouter);
app.use('/api/diseases', diseasesRouter);
app.use('/api/treatments', treatmentsRouter);
app.use('/api/scans', scansRouter);
app.use('/api/community', communityRouter);
app.use('/api/weather', weatherRouter);
app.use('/api/shops', shopsRouter);

// ─── 404 handler ───────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: { message: `Route ${req.method} ${req.path} not found` },
  });
});

// ─── Global error handler ──────────────────────────────────────
app.use(errorHandler);

// ─── Start server ──────────────────────────────────────────────
app.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🌱 CropDoc Backend Server`);
  console.log(`   Running on: http://0.0.0.0:${PORT} (Accessible from local network)`);
  console.log(`   Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`   Supabase: ${process.env.SUPABASE_URL ? '✅ configured' : '⚠️  not configured'}`);
  console.log(`\n   API endpoints:`);
  console.log(`   POST /api/auth/register`);
  console.log(`   GET  /api/auth/profile`);
  console.log(`   GET  /api/diseases`);
  console.log(`   GET  /api/diseases/lookup/:crop/:disease`);
  console.log(`   GET  /api/treatments/:diseaseKey`);
  console.log(`   GET  /api/treatments/:diseaseKey/products`);
  console.log(`   GET  /api/treatments/:diseaseKey/schedule`);
  console.log(`   GET  /api/treatments/:diseaseKey/shops`);
  console.log(`   GET  /api/scans`);
  console.log(`   POST /api/scans`);
  console.log(`   PATCH /api/scans/:id`);
  console.log(`   GET  /api/scans/stats`);
  console.log(`   GET  /api/community/alerts`);
  console.log(`   POST /api/community/alerts`);
  console.log(`   GET  /api/community/trends`);
  console.log(`   GET  /api/weather`);
  console.log(`   GET  /api/shops`);
  console.log('');
});

module.exports = app;
