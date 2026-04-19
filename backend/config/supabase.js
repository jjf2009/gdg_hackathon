const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey || supabaseUrl.includes('your-project-id')) {
  console.warn(
    '\n⚠️  Supabase credentials not configured!\n' +
    '   Copy .env.example to .env and fill in your Supabase URL and keys.\n' +
    '   The server will start but database operations will fail.\n'
  );
}

const supabase = createClient(
  supabaseUrl || 'https://placeholder.supabase.co',
  supabaseKey || 'placeholder-key',
  {
    auth: { persistSession: false },
  }
);

module.exports = supabase;
