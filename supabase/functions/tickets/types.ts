// Types for ticket management
export interface TicketRequest {
  name: string;
  email: string;
  phone?: string;
  event_id?: number;
  ticket_type?: 'regular' | 'vip' | 'backstage';
}

export interface TicketResponse {
  id: number;
  name: string;
  email: string;
  phone?: string;
  status: string;
  metadata: any;
  created_at: string;
  updated_at?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface TicketFilters {
  status?: string;
  event_id?: number;
  ticket_type?: string;
  limit?: number;
  offset?: number;
}