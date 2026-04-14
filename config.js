// Find these values in: Supabase Dashboard → Project Settings → API
const SUPABASE_URL = 'https://qsagqcouijcwnvsxlkmj.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFzYWdxY291aWpjd252c3hsa21qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxMjMxMDQsImV4cCI6MjA5MTY5OTEwNH0.rjmDJziRnbsZoRw_foVSgEuD-zRAQAj-Ldv1bDiVPqY';

const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);