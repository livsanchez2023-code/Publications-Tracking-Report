CREATE TABLE profiles (
  id        UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email     TEXT,
  full_name TEXT,
  is_admin  BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email) VALUES (NEW.id, NEW.email) ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_read_own_profile" ON profiles FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY "admins_read_all_profiles" ON profiles FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE));
CREATE POLICY "users_update_own_profile" ON profiles FOR UPDATE TO authenticated USING (id = auth.uid());

CREATE TABLE publications (
  id               UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title            TEXT NOT NULL,
  authors          TEXT NOT NULL,
  journal          TEXT,
  year             INTEGER,
  doi              TEXT,
  institution      TEXT,
  publication_type TEXT CHECK (publication_type IN ('Journal Article','Conference Paper','Book Chapter','Other')),
  notes            TEXT,
  submitter_id     UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  submitter_email  TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER publications_updated_at BEFORE UPDATE ON publications FOR EACH ROW EXECUTE FUNCTION update_updated_at();

ALTER TABLE publications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_select_own"    ON publications FOR SELECT TO authenticated USING (submitter_id = auth.uid());
CREATE POLICY "admins_select_all"   ON publications FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE));
CREATE POLICY "users_insert_own"    ON publications FOR INSERT TO authenticated WITH CHECK (submitter_id = auth.uid());
CREATE POLICY "users_update_own"    ON publications FOR UPDATE TO authenticated USING (submitter_id = auth.uid()) WITH CHECK (submitter_id = auth.uid());
CREATE POLICY "admins_update_all"   ON publications FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE));
CREATE POLICY "users_delete_own"    ON publications FOR DELETE TO authenticated USING (submitter_id = auth.uid());
CREATE POLICY "admins_delete_all"   ON publications FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin = TRUE));