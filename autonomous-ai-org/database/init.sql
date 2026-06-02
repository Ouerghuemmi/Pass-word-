# Database Schema for Autonomous AI Organization

-- Core Tables
CREATE SCHEMA IF NOT EXISTS aio;

-- Agents Table
CREATE TABLE aio.agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(255) NOT NULL,
    agent_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'inactive',
    version VARCHAR(50),
    capabilities TEXT[],
    performance_score FLOAT DEFAULT 0.0,
    health_status VARCHAR(50) DEFAULT 'unknown',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    retired_at TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT valid_status CHECK (status IN ('inactive', 'active', 'paused', 'error', 'retired'))
);

-- Objectives Table
CREATE TABLE aio.objectives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    priority INTEGER DEFAULT 0,
    created_by UUID REFERENCES aio.agents(id),
    assigned_to UUID REFERENCES aio.agents(id),
    deadline TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT valid_status CHECK (status IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled'))
);

-- Tasks Table
CREATE TABLE aio.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    objective_id UUID REFERENCES aio.objectives(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    task_type VARCHAR(100),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    priority INTEGER DEFAULT 0,
    assigned_to UUID REFERENCES aio.agents(id),
    result TEXT,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    execution_time_ms INTEGER,
    metadata JSONB DEFAULT '{}',
    CONSTRAINT valid_status CHECK (status IN ('pending', 'in_progress', 'completed', 'failed', 'cancelled', 'paused'))
);

-- Decisions Table
CREATE TABLE aio.decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    decision_maker UUID REFERENCES aio.agents(id) NOT NULL,
    context TEXT,
    decision TEXT NOT NULL,
    reasoning TEXT,
    confidence_score FLOAT,
    outcome TEXT,
    success BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    impact_score FLOAT,
    metadata JSONB DEFAULT '{}'
);

-- Market Intelligence Table
CREATE TABLE aio.market_intelligence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(100),
    title VARCHAR(255),
    content TEXT,
    source VARCHAR(255),
    confidence_score FLOAT,
    data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Competitor Data Table
CREATE TABLE aio.competitors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    industry VARCHAR(255),
    market_position VARCHAR(100),
    products TEXT[],
    pricing_data JSONB,
    strategy_analysis TEXT,
    last_analyzed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Performance Metrics Table
CREATE TABLE aio.performance_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES aio.agents(id),
    metric_name VARCHAR(255),
    metric_value FLOAT,
    measured_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Audit Logs Table
CREATE TABLE aio.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES aio.agents(id),
    action VARCHAR(255),
    resource_type VARCHAR(100),
    resource_id VARCHAR(255),
    changes JSONB,
    justification TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Knowledge Storage Table
CREATE TABLE aio.knowledge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255),
    content TEXT,
    category VARCHAR(100),
    tags TEXT[],
    source VARCHAR(255),
    confidence_score FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Short-Term Memory Table (Session-based)
CREATE TABLE aio.session_memory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id VARCHAR(255),
    key VARCHAR(255),
    value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Execution History Table
CREATE TABLE aio.execution_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id UUID REFERENCES aio.tasks(id),
    agent_id UUID REFERENCES aio.agents(id),
    workflow_name VARCHAR(255),
    step_number INTEGER,
    step_name VARCHAR(255),
    status VARCHAR(50),
    input_data JSONB,
    output_data JSONB,
    error_info JSONB,
    duration_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Plans Table
CREATE TABLE aio.plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    objective_id UUID REFERENCES aio.objectives(id),
    plan_type VARCHAR(100),
    title VARCHAR(255),
    goals TEXT[],
    dependencies TEXT[],
    resources JSONB,
    timeline_start DATE,
    timeline_end DATE,
    budget NUMERIC,
    kpis JSONB,
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Create indexes for performance
CREATE INDEX idx_agents_status ON aio.agents(status);
CREATE INDEX idx_agents_role ON aio.agents(role);
CREATE INDEX idx_objectives_status ON aio.objectives(status);
CREATE INDEX idx_objectives_created_at ON aio.objectives(created_at);
CREATE INDEX idx_tasks_status ON aio.tasks(status);
CREATE INDEX idx_tasks_assigned_to ON aio.tasks(assigned_to);
CREATE INDEX idx_decisions_created_at ON aio.decisions(created_at);
CREATE INDEX idx_market_intel_category ON aio.market_intelligence(category);
CREATE INDEX idx_audit_logs_agent_id ON aio.audit_logs(agent_id);
CREATE INDEX idx_session_memory_session_id ON aio.session_memory(session_id);
CREATE INDEX idx_execution_history_task_id ON aio.execution_history(task_id);
