// Types for producer policies management
export interface ProducerPoliciesRequest {
  producer_id: string;
  terms_and_conditions?: string;
  privacy_policy?: string;
  refund_policy?: string;
}

export interface ProducerPoliciesResponse {
  id: string;
  producer_id: string;
  terms_and_conditions: string | null;
  privacy_policy: string | null;
  refund_policy: string | null;
  created_at: string;
  updated_at: string | null;
}

export interface ProducerPoliciesUpdate {
  terms_and_conditions?: string;
  privacy_policy?: string;
  refund_policy?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: string[];
}

export interface PoliciesFilters {
  producer_id?: string;
  has_terms?: boolean;
  has_privacy?: boolean;
  has_refund?: boolean;
  limit?: number;
  offset?: number;
}

export interface ValidationResult {
  valid: boolean;
  errors: string[];
}

export interface PoliciesStats {
  total_producers: number;
  with_terms: number;
  with_privacy: number;
  with_refund: number;
  complete_policies: number;
  incomplete_policies: number;
}

// Route parameter types
export interface RouteParams {
  producer_id?: string;
}

// HTTP method types
export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE' | 'OPTIONS';

// CORS headers type
export interface CorsHeaders {
  'Access-Control-Allow-Origin': string;
  'Access-Control-Allow-Headers': string;
  'Access-Control-Allow-Methods': string;
  'Content-Type'?: string;
}

// Database table interface (mirrors expected table structure)
export interface ProducerPoliciesTable {
  id?: string;
  producer_id: string;
  terms_and_conditions: string | null;
  privacy_policy: string | null;
  refund_policy: string | null;
  created_at?: string;
  updated_at?: string;
}