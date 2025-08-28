-- Create authentication tables

-- User table
CREATE TABLE public.user (
  id text NOT NULL,
  name text NOT NULL,
  email text NOT NULL UNIQUE,
  email_verified boolean NOT NULL,
  image text,
  phoneNumber text UNIQUE,
  phoneNumberVerified boolean DEFAULT false,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  is_anonymous boolean,
  CONSTRAINT user_pkey PRIMARY KEY (id)
);

-- Account table (OAuth providers)
CREATE TABLE public.account (
  id text NOT NULL,
  account_id text NOT NULL,
  provider_id text NOT NULL,
  user_id text NOT NULL,
  access_token text,
  refresh_token text,
  id_token text,
  access_token_expires_at timestamp without time zone,
  refresh_token_expires_at timestamp without time zone,
  scope text,
  password text,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  CONSTRAINT account_pkey PRIMARY KEY (id),
  CONSTRAINT account_user_id_user_id_fk FOREIGN KEY (user_id) REFERENCES public.user(id)
);

-- Session table
CREATE TABLE public.session (
  id text NOT NULL,
  expires_at timestamp without time zone NOT NULL,
  token text NOT NULL UNIQUE,
  created_at timestamp without time zone NOT NULL,
  updated_at timestamp without time zone NOT NULL,
  ip_address text,
  user_agent text,
  user_id text NOT NULL,
  CONSTRAINT session_pkey PRIMARY KEY (id),
  CONSTRAINT session_user_id_user_id_fk FOREIGN KEY (user_id) REFERENCES public.user(id)
);

-- Passkey table (WebAuthn)
CREATE TABLE public.passkey (
  id text NOT NULL,
  name text,
  public_key text NOT NULL,
  user_id text NOT NULL,
  credential_i_d text NOT NULL,
  counter integer NOT NULL,
  device_type text NOT NULL,
  backed_up boolean NOT NULL,
  transports text,
  created_at timestamp without time zone NOT NULL,
  aaguid text,
  CONSTRAINT passkey_pkey PRIMARY KEY (id),
  CONSTRAINT passkey_user_id_user_id_fk FOREIGN KEY (user_id) REFERENCES public.user(id)
);

-- Verification table (email/phone verification codes)
CREATE TABLE public.verification (
  id text NOT NULL,
  identifier text NOT NULL,
  value text NOT NULL,
  expires_at timestamp without time zone NOT NULL,
  created_at timestamp without time zone,
  updated_at timestamp without time zone,
  CONSTRAINT verification_pkey PRIMARY KEY (id)
);

-- Enable RLS on all tables
ALTER TABLE public.user ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.account ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.passkey ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.verification ENABLE ROW LEVEL SECURITY;