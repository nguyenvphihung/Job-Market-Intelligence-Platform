const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: 'postgres.zplfdsvrcudykpuwahms',
  host: 'aws-0-ap-southeast-1.pooler.supabase.com',
  database: 'postgres',
  password: 'hungjsgxsw6',
  port: 5432,
});

// Test connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Lỗi kết nối:', err);
  } else {
    console.log('✅ Kết nối thành công! Thời gian hiện tại:', res.rows);
  }
});

// Error handling for the database connection
pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
  process.exit(-1);
});

// Keep-alive ping to prevent connection timeout
setInterval(() => {
  pool.query('SELECT 1', [], (err) => {
    if (err) {
      console.error('Keep-alive ping failed:', err);
    }
  });
}, 60000); // Ping every 60 seconds

// Global error handling
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  // Keep running despite uncaught exceptions
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Keep running despite unhandled promise rejections
});

// API Endpoints
app.get('/api/overview', async (req, res) => {
  try {
    // First, let's log the total count to verify data exists
    const countQuery = 'SELECT COUNT(*) FROM jobs';
    const countResult = await pool.query(countQuery);
    console.log('Total jobs found:', countResult.rows[0].count);

    const query = `
      SELECT 
        COUNT(*) as total_jobs,
        COUNT(DISTINCT company_name) as total_companies,
        COUNT(DISTINCT skills) as total_skills,
        ROUND(
          AVG(
            CASE 
              WHEN salary ~ '^[0-9,.]+$' 
              THEN CAST(REPLACE(REPLACE(salary, ',', ''), '$', '') AS DECIMAL)
              ELSE NULL 
            END
          )
        ) as avg_salary
      FROM jobs
      WHERE salary IS NOT NULL
    `;

    const result = await pool.query(query);
    console.log('Overview result:', result.rows[0]); // Debug log
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Detailed error:', err);
    res.status(500).json({ 
      error: err.message,
      detail: err.detail,
      hint: err.hint
    });
  }
});

// Add a test endpoint to check raw data
app.get('/api/test-data', async (req, res) => {
  try {
    const query = `
      SELECT 
        job_title,
        company_name,
        salary,
        skills
      FROM jobs
      LIMIT 5
    `;
    const result = await pool.query(query);
    console.log('Sample data:', result.rows);
    res.json(result.rows);
  } catch (err) {
    console.error('Error in test-data:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get all jobs with pagination
app.get('/api/jobs', async (req, res) => {
  try {
    // Get page and limit from query params, default to page 1 and limit 10
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Get total count
    const countQuery = 'SELECT COUNT(*) FROM jobs';
    const countResult = await pool.query(countQuery);
    const totalJobs = parseInt(countResult.rows[0].count);

    // Get jobs with pagination
    const query = `
      SELECT 
        id,
        job_title,
        company_name,
        location,
        salary,
        skills,
        job_description,
        posted_date,
        job_type,
        url
      FROM jobs
      ORDER BY id DESC
      LIMIT $1 OFFSET $2
    `;

    const result = await pool.query(query, [limit, offset]);
    
    console.log(`Fetched ${result.rows.length} jobs from database`);

    res.json({
      total: totalJobs,
      page: page,
      limit: limit,
      totalPages: Math.ceil(totalJobs / limit),
      data: result.rows
    });

  } catch (err) {
    console.error('Error fetching jobs:', err);
    res.status(500).json({
      error: err.message,
      detail: err.detail,
      hint: err.hint
    });
  }
});

// Get single job by ID
app.get('/api/jobs/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const query = 'SELECT * FROM jobs WHERE id = $1';
    const result = await pool.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Job not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Error fetching job:', err);
    res.status(500).json({ error: err.message });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Something broke!',
    message: err.message
  });
});

// Modify your server startup
const server = app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

// Graceful shutdown
process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

function gracefulShutdown() {
  console.log('Received shutdown signal');
  server.close(async () => {
    console.log('Server closed');
    try {
      await pool.end();
      console.log('Database pool closed');
      process.exit(0);
    } catch (err) {
      console.error('Error during shutdown:', err);
      process.exit(1);
    }
  });

  // Force close after 30 seconds
  setTimeout(() => {
    console.error('Could not close connections in time, forcefully shutting down');
    process.exit(1);
  }, 30000);
}


