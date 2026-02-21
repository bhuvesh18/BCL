# BhaiChara Cricket League – Setup & Start

## Step 1: Create Supabase Tables

1. Go to [Supabase Dashboard](https://supabase.com/dashboard) and open your project.
2. Click **SQL Editor** in the left sidebar.
3. Click **New query**.
4. Copy the SQL from `database.sql` and run it, or paste this:

```sql
-- Players
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  photo TEXT,
  team TEXT
);

-- Matches
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date TEXT NOT NULL,
  overs INTEGER DEFAULT 5,
  notes TEXT,
  team1 TEXT,
  team2 TEXT,
  match_number INTEGER
);

-- Scores
CREATE TABLE scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  runs INTEGER DEFAULT 0,
  balls INTEGER DEFAULT 0,
  fours INTEGER DEFAULT 0,
  sixes INTEGER DEFAULT 0,
  wickets INTEGER DEFAULT 0,
  runs_conceded INTEGER DEFAULT 0,
  balls_bowled INTEGER DEFAULT 0
);

-- Enable access (RLS)
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all" ON players FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON matches FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON scores FOR ALL USING (true) WITH CHECK (true);
```

## Step 1b: Migration (if tables already exist)

If you already have tables, add match_rosters and toss columns:

```sql
CREATE TABLE IF NOT EXISTS match_rosters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  team INTEGER NOT NULL CHECK (team IN (1, 2))
);
ALTER TABLE matches ADD COLUMN IF NOT EXISTS toss_winner TEXT;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS toss_decision TEXT;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS winner INTEGER;
ALTER TABLE scores ADD COLUMN IF NOT EXISTS catches INTEGER DEFAULT 0;
ALTER TABLE scores ADD COLUMN IF NOT EXISTS innings INTEGER DEFAULT 1;
ALTER TABLE dismissals ADD COLUMN IF NOT EXISTS innings INTEGER DEFAULT 1;
CREATE TABLE IF NOT EXISTS dismissals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  batsman_id UUID REFERENCES players(id),
  bowler_id UUID REFERENCES players(id),
  fielder_id UUID REFERENCES players(id),
  dismissal_type TEXT CHECK (dismissal_type IN ('bowled','caught','run_out','stumped','lbw','hit_wicket'))
);
ALTER TABLE match_rosters ENABLE ROW LEVEL SECURITY;
ALTER TABLE dismissals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON dismissals FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON match_rosters FOR ALL USING (true) WITH CHECK (true);
```

**Note:** Use `database.sql` for a fresh setup – it creates everything. Players have no permanent team; teams are formed per match.

## Step 2: Start the App

1. Open `index.html` in your browser (double-click the file).
2. **Players** tab: Add all players (shared pool – no team assignment).
3. **Live Score** tab: Create a match – enter Team 1 and Team 2 names, assign players to each team, set overs, then toss (who won, bat/bowl).
4. Enter scores and save.

## If You See "Invalid API Key"

The **Publishable** key may not work with the Supabase JS client. Use the **anon** key instead:

1. Supabase Dashboard → **Project Settings** → **API**.
2. Copy the **anon** key (starts with `eyJ...`).
3. In `index.html`, find `SUPABASE_KEY` near the top of the `<script>` and replace the value with your anon key.

## Optional: Host Online

- **Netlify** or **Vercel**: Drag the BCL folder to deploy.
- **GitHub Pages**: Push the repo and enable Pages in Settings.
