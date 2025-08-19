// Event-related TypeScript interfaces for Hunt Tickets

export interface Event {
  id: number;
  title: string;
  description?: string;
  event_date: string;
  location: string;
  max_capacity: number;
  current_capacity: number;
  price: number;
  status: 'active' | 'inactive' | 'sold_out' | 'cancelled';
  category: 'concert' | 'theater' | 'sports' | 'conference' | 'general';
  organizer_id?: string;
  metadata: Record<string, any>;
  created_at: string;
  updated_at: string;
}

export interface EventCreateRequest {
  title: string;
  description?: string;
  event_date: string;
  location: string;
  max_capacity?: number;
  price?: number;
  category?: 'concert' | 'theater' | 'sports' | 'conference' | 'general';
  organizer_id?: string;
}

export interface EventUpdateRequest {
  title?: string;
  description?: string;
  event_date?: string;
  location?: string;
  max_capacity?: number;
  current_capacity?: number;
  price?: number;
  status?: 'active' | 'inactive' | 'sold_out' | 'cancelled';
  category?: 'concert' | 'theater' | 'sports' | 'conference' | 'general';
  organizer_id?: string;
  metadata?: Record<string, any>;
}

export interface EventFilters {
  status?: string;
  category?: string;
  limit?: number;
  offset?: number;
  date_from?: string;
  date_to?: string;
  location?: string;
  organizer_id?: string;
}

export interface EventStats {
  total: number;
  by_status: Record<string, number>;
  by_category: Record<string, number>;
  total_capacity: number;
  total_sold: number;
  revenue: number;
  occupancy_rate: number;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  count?: number;
}