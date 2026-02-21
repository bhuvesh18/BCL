-- ============================================
-- BhaiChara Cricket League - RESET & SCHEMA
-- ============================================
-- WARNING: This ERASES ALL DATA and recreates tables
-- Run in Supabase SQL Editor: Dashboard → SQL Editor → New query
-- ============================================

-- STEP 1: Drop existing tables (deletes all data)
-- -----------------------------------------------
DROP TABLE IF EXISTS scores CASCADE;
DROP TABLE IF EXISTS dismissals CASCADE;
DROP TABLE IF EXISTS match_rosters CASCADE;
DROP TABLE IF EXISTS matches CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS teams CASCADE;

-- STEP 2: Create tables
-- -----------------------------------------------
-- Players are a shared pool; no permanent team. Teams are formed per match.
CREATE TABLE players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  photo TEXT
);

CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date TEXT NOT NULL,
  overs INTEGER DEFAULT 5,
  notes TEXT,
  team1 TEXT,
  team2 TEXT,
  match_number INTEGER,
  toss_winner TEXT,
  toss_decision TEXT,
  winner INTEGER
);

-- Which players play for which team in each match (1 = team1, 2 = team2)
CREATE TABLE match_rosters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  team INTEGER NOT NULL CHECK (team IN (1, 2))
);

-- Per-wicket dismissal details (how out, bowler, fielder)
CREATE TABLE dismissals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  innings INTEGER DEFAULT 1,
  batsman_id UUID REFERENCES players(id),
  bowler_id UUID REFERENCES players(id),
  fielder_id UUID REFERENCES players(id),
  dismissal_type TEXT NOT NULL CHECK (dismissal_type IN ('bowled','caught','run_out','stumped','lbw','hit_wicket'))
);

CREATE TABLE scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  innings INTEGER DEFAULT 1,
  player_id UUID REFERENCES players(id) ON DELETE CASCADE,
  runs INTEGER DEFAULT 0,
  balls INTEGER DEFAULT 0,
  fours INTEGER DEFAULT 0,
  sixes INTEGER DEFAULT 0,
  wickets INTEGER DEFAULT 0,
  runs_conceded INTEGER DEFAULT 0,
  balls_bowled INTEGER DEFAULT 0,
  catches INTEGER DEFAULT 0
);

-- STEP 3: Enable RLS & policies
-- -----------------------------------------------

ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_rosters ENABLE ROW LEVEL SECURITY;
ALTER TABLE dismissals ENABLE ROW LEVEL SECURITY;
ALTER TABLE scores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all" ON players FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON matches FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON dismissals FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON match_rosters FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON scores FOR ALL USING (true) WITH CHECK (true);
