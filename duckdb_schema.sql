-- Merchant Risk GPT Suite database schema for DuckDB-style local/Appport prototype.
-- This mirrors backend/app/models.py without requiring SQLAlchemy.
-- Use fake/sample data only unless AmEx approvals are complete.

CREATE SEQUENCE IF NOT EXISTS runs_id_seq START 1;
CREATE TABLE IF NOT EXISTS runs (
    id INTEGER PRIMARY KEY DEFAULT nextval('runs_id_seq'),
    run_month VARCHAR NOT NULL,
    run_type VARCHAR NOT NULL DEFAULT 'monthly_incremental',
    region VARCHAR NOT NULL DEFAULT 'global',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR,
    notes TEXT,
    status VARCHAR NOT NULL DEFAULT 'draft'
);

CREATE SEQUENCE IF NOT EXISTS candidates_id_seq START 1;
CREATE TABLE IF NOT EXISTS candidates (
    id INTEGER PRIMARY KEY DEFAULT nextval('candidates_id_seq'),
    run_id INTEGER NOT NULL,
    canonical_domain VARCHAR NOT NULL,
    candidate_url TEXT NOT NULL,
    business_name_detected VARCHAR,
    suspected_category VARCHAR NOT NULL,
    activity_confidence DOUBLE NOT NULL,
    activity_risk_level VARCHAR NOT NULL,
    status VARCHAR NOT NULL DEFAULT 'new',
    first_seen DATE,
    last_seen DATE,
    source_summary TEXT,
    gpt_discovery_notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (run_id) REFERENCES runs(id)
);

CREATE SEQUENCE IF NOT EXISTS extracted_signals_id_seq START 1;
CREATE TABLE IF NOT EXISTS extracted_signals (
    id INTEGER PRIMARY KEY DEFAULT nextval('extracted_signals_id_seq'),
    candidate_id INTEGER NOT NULL,
    signal_type VARCHAR NOT NULL,
    signal_value TEXT NOT NULL,
    confidence DOUBLE NOT NULL DEFAULT 1.0,
    source_note TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id)
);

CREATE SEQUENCE IF NOT EXISTS evidence_id_seq START 1;
CREATE TABLE IF NOT EXISTS evidence (
    id INTEGER PRIMARY KEY DEFAULT nextval('evidence_id_seq'),
    candidate_id INTEGER NOT NULL,
    evidence_type VARCHAR NOT NULL,
    evidence_level VARCHAR NOT NULL DEFAULT 'none',
    evidence_summary TEXT NOT NULL,
    source_url TEXT,
    artifact_reference TEXT,
    observed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id)
);

CREATE SEQUENCE IF NOT EXISTS acceptance_reviews_id_seq START 1;
CREATE TABLE IF NOT EXISTS acceptance_reviews (
    id INTEGER PRIMARY KEY DEFAULT nextval('acceptance_reviews_id_seq'),
    candidate_id INTEGER NOT NULL,
    amex_acceptance_score DOUBLE NOT NULL,
    highest_evidence_level VARCHAR NOT NULL DEFAULT 'none',
    review_summary TEXT NOT NULL,
    recommended_next_step TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id)
);

CREATE SEQUENCE IF NOT EXISTS internal_linkage_packs_id_seq START 1;
CREATE TABLE IF NOT EXISTS internal_linkage_packs (
    id INTEGER PRIMARY KEY DEFAULT nextval('internal_linkage_packs_id_seq'),
    candidate_id INTEGER NOT NULL,
    priority VARCHAR NOT NULL DEFAULT 'P3',
    exact_search_terms_json TEXT NOT NULL DEFAULT '[]',
    fuzzy_search_terms_json TEXT NOT NULL DEFAULT '[]',
    transactional_search_suggestions_json TEXT NOT NULL DEFAULT '[]',
    extracted_signals_json TEXT NOT NULL DEFAULT '[]',
    match_rationale TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id)
);

-- Keep this table only for local prototype parity.
-- Do not expose internal matching to Custom GPT Actions under Option A.
CREATE SEQUENCE IF NOT EXISTS internal_match_results_id_seq START 1;
CREATE TABLE IF NOT EXISTS internal_match_results (
    id INTEGER PRIMARY KEY DEFAULT nextval('internal_match_results_id_seq'),
    linkage_pack_id INTEGER NOT NULL,
    match_status VARCHAR NOT NULL DEFAULT 'not_checked',
    masked_internal_reference VARCHAR,
    match_score DOUBLE NOT NULL DEFAULT 0.0,
    matched_on_json TEXT NOT NULL DEFAULT '[]',
    masked_profile_json TEXT NOT NULL DEFAULT '{}',
    recommended_action TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (linkage_pack_id) REFERENCES internal_linkage_packs(id)
);

CREATE SEQUENCE IF NOT EXISTS reports_id_seq START 1;
CREATE TABLE IF NOT EXISTS reports (
    id INTEGER PRIMARY KEY DEFAULT nextval('reports_id_seq'),
    run_id INTEGER NOT NULL,
    report_type VARCHAR NOT NULL,
    title VARCHAR NOT NULL,
    summary_json TEXT NOT NULL DEFAULT '{}',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (run_id) REFERENCES runs(id)
);

CREATE INDEX IF NOT EXISTS idx_runs_run_month ON runs(run_month);
CREATE INDEX IF NOT EXISTS idx_candidates_run_id ON candidates(run_id);
CREATE INDEX IF NOT EXISTS idx_candidates_domain ON candidates(canonical_domain);
CREATE INDEX IF NOT EXISTS idx_candidates_status ON candidates(status);
CREATE INDEX IF NOT EXISTS idx_signals_candidate_id ON extracted_signals(candidate_id);
CREATE INDEX IF NOT EXISTS idx_signals_type ON extracted_signals(signal_type);
CREATE INDEX IF NOT EXISTS idx_evidence_candidate_id ON evidence(candidate_id);
CREATE INDEX IF NOT EXISTS idx_reviews_candidate_id ON acceptance_reviews(candidate_id);
CREATE INDEX IF NOT EXISTS idx_linkage_candidate_id ON internal_linkage_packs(candidate_id);
CREATE INDEX IF NOT EXISTS idx_reports_run_id ON reports(run_id);
