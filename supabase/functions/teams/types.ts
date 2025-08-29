export interface TeamRequest {
  name: string;
  description?: string;
  producer_id: string;
}

export interface TeamResponse {
  id: string;
  name: string;
  description?: string;
  producer_id: string;
  created_at: string;
  updated_at: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface TeamFilters {
  producer_id?: string;
  limit?: number;
  offset?: number;
}