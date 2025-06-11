-- Create holding companies table
CREATE TABLE IF NOT EXISTS holding_companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create subsidiaries table
CREATE TABLE IF NOT EXISTS subsidiaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    holding_company_id UUID NOT NULL REFERENCES holding_companies(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create divisions table
CREATE TABLE IF NOT EXISTS divisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE CASCADE,
    strategic_plan TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create goals table
CREATE TABLE IF NOT EXISTS goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'Not Started',
    target_completion_date DATE,
    related_division_id UUID REFERENCES divisions(id) ON DELETE SET NULL,
    related_subsidiary_id UUID REFERENCES subsidiaries(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (status IN ('Not Started', 'In Progress', 'Completed', 'Needs Review', 'Archived'))
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
    reviewee_id UUID NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
    performance_rating INTEGER CHECK (performance_rating BETWEEN 1 AND 5),
    comments TEXT,
    status TEXT NOT NULL DEFAULT 'Submitted',
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (status IN ('Submitted', 'Acknowledged'))
);

-- Create reports table
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    division_id UUID NOT NULL REFERENCES divisions(id) ON DELETE CASCADE,
    period TEXT NOT NULL,
    content JSONB,
    status TEXT NOT NULL DEFAULT 'pending',
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    submitted_by UUID NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
    CHECK (status IN ('pending', 'approved', 'rejected'))
);

-- Create plan_updates table
CREATE TABLE IF NOT EXISTS plan_updates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    posted_by UUID NOT NULL REFERENCES users(uid) ON DELETE CASCADE,
    content TEXT NOT NULL,
    target_roles user_role[] NOT NULL,
    acknowledged_by UUID[] DEFAULT '{}',
    posted_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(uid) ON DELETE SET NULL,
    action TEXT NOT NULL,
    details JSONB,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add triggers for updated_at columns
CREATE TRIGGER update_holding_companies_updated_at
    BEFORE UPDATE ON holding_companies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subsidiaries_updated_at
    BEFORE UPDATE ON subsidiaries
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_divisions_updated_at
    BEFORE UPDATE ON divisions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_goals_updated_at
    BEFORE UPDATE ON goals
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS on all tables
ALTER TABLE holding_companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE subsidiaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE divisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Create RLS helper functions
CREATE OR REPLACE FUNCTION auth_functions.is_owner_or_admin()
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE uid = auth.uid()
    AND role IN ('owner', 'administrator')
  );
END;
$$;

CREATE OR REPLACE FUNCTION auth_functions.can_access_division(division_id_param uuid)
RETURNS boolean
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN (
    auth_functions.is_owner_or_admin() OR
    EXISTS (
      SELECT 1 FROM users
      WHERE uid = auth.uid()
      AND (
        division_id_param = ANY(division_ids) OR
        EXISTS (
          SELECT 1 FROM divisions d
          JOIN subsidiaries s ON d.subsidiary_id = s.id
          WHERE d.id = division_id_param
          AND s.id = ANY(subsidiary_ids)
        )
      )
    )
  );
END;
$$;

-- RLS Policies for holding_companies
CREATE POLICY "Everyone can view holding companies" ON holding_companies
    FOR SELECT USING (true);

CREATE POLICY "Only owners and admins can modify holding companies" ON holding_companies
    FOR ALL USING (auth_functions.is_owner_or_admin());

-- RLS Policies for subsidiaries
CREATE POLICY "Everyone can view subsidiaries" ON subsidiaries
    FOR SELECT USING (true);

CREATE POLICY "Only owners and admins can modify subsidiaries" ON subsidiaries
    FOR ALL USING (auth_functions.is_owner_or_admin());

-- RLS Policies for divisions
CREATE POLICY "Everyone can view divisions" ON divisions
    FOR SELECT USING (true);

CREATE POLICY "Only owners and admins can modify divisions" ON divisions
    FOR ALL USING (auth_functions.is_owner_or_admin());

-- RLS Policies for goals
CREATE POLICY "Users can view their own goals" ON goals
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can view goals in their divisions" ON goals
    FOR SELECT USING (
        auth_functions.can_access_division(related_division_id)
    );

CREATE POLICY "Users can create goals" ON goals
    FOR INSERT WITH CHECK (
        user_id = auth.uid() AND
        (
            related_division_id IS NULL OR
            auth_functions.can_access_division(related_division_id)
        )
    );

CREATE POLICY "Users can update their own goals" ON goals
    FOR UPDATE USING (user_id = auth.uid());

-- RLS Policies for reviews
CREATE POLICY "Users can view reviews of their goals" ON reviews
    FOR SELECT USING (reviewee_id = auth.uid());

CREATE POLICY "Directors and above can create reviews" ON reviews
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE uid = auth.uid()
            AND role IN ('director', 'owner', 'administrator')
        )
    );

-- RLS Policies for reports
CREATE POLICY "Users can view reports for their divisions" ON reports
    FOR SELECT USING (auth_functions.can_access_division(division_id));

CREATE POLICY "Users can create reports for their divisions" ON reports
    FOR INSERT WITH CHECK (
        auth_functions.can_access_division(division_id) AND
        submitted_by = auth.uid()
    );

-- RLS Policies for plan_updates
CREATE POLICY "Users can view plan updates for their role" ON plan_updates
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE uid = auth.uid()
            AND role = ANY(target_roles)
        )
    );

CREATE POLICY "Only owners can create plan updates" ON plan_updates
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE uid = auth.uid()
            AND role = 'owner'
        )
    );

-- RLS Policies for audit_logs
CREATE POLICY "Only owners and admins can view audit logs" ON audit_logs
    FOR SELECT USING (auth_functions.is_owner_or_admin()); 