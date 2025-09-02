import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { TicketRequest, TicketResponse, TicketFilters } from './types.ts';

export class TicketDatabase {
  private supabase;

  constructor() {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    this.supabase = createClient(supabaseUrl, supabaseKey);
  }

  async getAllTickets(filters?: TicketFilters): Promise<TicketResponse[]> {
    let query = this.supabase
      .from('test')
      .select('*')
      .order('created_at', { ascending: false });

    // Apply filters
    if (filters?.status) {
      query = query.eq('status', filters.status);
    }

    if (filters?.limit) {
      query = query.limit(filters.limit);
    }

    if (filters?.offset) {
      query = query.range(filters.offset, filters.offset + (filters.limit || 10) - 1);
    }

    const { data, error } = await query;
    
    if (error) throw error;
    return data || [];
  }

  async getTicketById(id: number): Promise<TicketResponse | null> {
    const { data, error } = await this.supabase
      .from('test')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }

  async createTicket(ticket: TicketRequest): Promise<TicketResponse> {
    const { data, error } = await this.supabase
      .from('test')
      .insert({
        name: ticket.name,
        email: ticket.email,
        phone: ticket.phone || null,
        status: 'active',
        metadata: { 
          event_id: ticket.event_id || null,
          ticket_type: ticket.ticket_type || 'regular',
          created_by: 'api',
          version: '1.0'
        }
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async updateTicket(id: number, updates: Partial<TicketRequest>): Promise<TicketResponse> {
    const { data, error } = await this.supabase
      .from('test')
      .update({
        name: updates.name,
        email: updates.email,
        phone: updates.phone,
        metadata: updates.event_id ? { event_id: updates.event_id } : undefined
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async deleteTicket(id: number): Promise<void> {
    const { error } = await this.supabase
      .from('test')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  async getTicketStats(): Promise<any> {
    const { data, error } = await this.supabase
      .from('test')
      .select('status, metadata')
      .not('status', 'is', null);

    if (error) throw error;

    const stats = {
      total: data?.length || 0,
      active: data?.filter(t => t.status === 'active').length || 0,
      inactive: data?.filter(t => t.status !== 'active').length || 0,
      by_type: {
        regular: 0,
        vip: 0,
        backstage: 0
      }
    };

    data?.forEach(ticket => {
      const type = ticket.metadata?.ticket_type || 'regular';
      if (stats.by_type[type] !== undefined) {
        stats.by_type[type]++;
      }
    });

    return stats;
  }
}