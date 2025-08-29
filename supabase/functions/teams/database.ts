import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { TeamRequest, TeamResponse, TeamFilters } from './types.ts';

export class TeamDatabase {
  private supabase;

  constructor() {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    this.supabase = createClient(supabaseUrl, supabaseKey);
  }

  async getAllTeams(filters?: TeamFilters): Promise<TeamResponse[]> {
    let query = this.supabase
      .from('teams')
      .select('*')
      .order('created_at', { ascending: false });

    if (filters?.producer_id) {
      query = query.eq('producer_id', filters.producer_id);
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

  async getTeamById(id: string): Promise<TeamResponse | null> {
    const { data, error } = await this.supabase
      .from('teams')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }

  async createTeam(team: TeamRequest): Promise<TeamResponse> {
    const { data, error } = await this.supabase
      .from('teams')
      .insert({
        name: team.name,
        description: team.description || null,
        producer_id: team.producer_id
      })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async updateTeam(id: string, updates: Partial<TeamRequest>): Promise<TeamResponse> {
    const { data, error } = await this.supabase
      .from('teams')
      .update({
        name: updates.name,
        description: updates.description,
        producer_id: updates.producer_id
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async deleteTeam(id: string): Promise<void> {
    const { error } = await this.supabase
      .from('teams')
      .delete()
      .eq('id', id);

    if (error) throw error;
  }

  async getTeamsByProducer(producerId: string): Promise<TeamResponse[]> {
    const { data, error } = await this.supabase
      .from('teams')
      .select('*')
      .eq('producer_id', producerId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data || [];
  }
}