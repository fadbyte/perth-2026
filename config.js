// Supabase connection for the shared travellers list.
// Both values are safe to publish — the passcode check happens inside Supabase.
// Find them in Supabase → Project Settings → API Keys.
// Use the "publishable" key (sb_publishable_…) or the legacy "anon" key.
// Leave them empty and the site shows travellers.json, read-only.
window.TRIP_CONFIG = {
  supabaseUrl: "https://lqwplpsonxghiyeqhekt.supabase.co",
  supabaseAnonKey: ""
};
