# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hunt Tickets is a ticket management platform built with Supabase as the primary backend. The architecture is serverless-first, using Supabase's database, authentication, and Edge Functions for all backend logic.

## Architecture

### Database-First Approach
- **Database**: PostgreSQL via Supabase Cloud
- **Schema Management**: Version-controlled SQL migrations in `supabase/migrations/`
- **Type Safety**: Auto-generated TypeScript types from database schema
- **Security**: Row Level Security (RLS) policies on all tables

### Edge Functions Architecture
- **Runtime**: Deno-based serverless functions
- **Structure**: Modular approach with separate concerns
- **Deployment**: Direct API deployment (no Docker required)

Key Edge Functions:
- `tickets/`: Main API with modular structure (database, validators, utils, types)
- `helpers/`: Utility functions for auth, crypto, formatting, and constants

### Core Tables
- `test`: Development/testing table with user data and metadata
- `events`: Event management with capacity, pricing, and categorization  
- `roles`: Role-based access control with permissions stored as JSONB

## Development Commands

### Database Operations
```bash
# Deploy migrations to Supabase Cloud (via GitHub)
git add . && git commit -m "Add migration" && git push origin main

# Generate TypeScript types from remote database
supabase gen types typescript --project-id hlmezmcbsffebqltbagg > types/supabase.ts

# Create new migration
supabase migration new <migration_name>
```

### Edge Functions
```bash
# Deploy single function using Management API (no Docker)
supabase functions deploy <function_name> --use-api

# Deploy all functions  
supabase functions deploy --use-api

# List deployed functions
supabase functions list
```

### Project Setup
```bash
# Link to existing Supabase project
supabase link --project-ref hlmezmcbsffebqltbagg

# Initialize new Supabase project structure  
supabase init
```

## Key Development Patterns

### Migration Strategy
- **GitHub-Driven**: All migrations deploy automatically via GitHub push
- **No Local Docker**: Development connects directly to Supabase Cloud
- **Character Encoding**: Avoid special characters (accents) in migration SQL to prevent UTF-8 encoding issues

### Edge Function Structure
```
functions/<function_name>/
├── index.ts          # Main handler with routing
├── types.ts          # TypeScript interfaces  
├── database.ts       # Database operations
├── validators.ts     # Input validation
├── utils.ts          # Helper functions
├── config/           # Configuration files
└── lib/              # Shared utilities
```

### Function Routing
All routes must be explicitly defined in `index.ts` - nested files are not automatically exposed as endpoints. Use pathname-based routing within the main handler.

### Environment Variables
- Stored in `.env` (gitignored)
- Template available in `.env.example`  
- Required: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`

### RLS Policies
- Enabled by default on all tables
- Avoid circular dependencies (don't reference tables that don't exist yet)
- Use `service_role` for admin operations
- Implement progressive restrictions (start permissive, then tighten)

## Important Constraints

### Deployment Model
- Database changes: GitHub → Supabase Cloud (automatic)
- Edge Functions: Manual deployment via CLI with `--use-api` flag
- No local Docker environment - development happens against cloud database

### Function Limitations  
- Must use Deno imports (https://deno.land/std, https://esm.sh/)
- Function names cannot contain forward slashes
- All routes must be explicitly handled in index.ts
- CORS headers required for web client access

### Migration Gotchas
- PostgreSQL rejects malformed UTF-8 sequences
- Foreign key references must exist before creating policies
- Migrations run in timestamp order - ensure dependencies are created first