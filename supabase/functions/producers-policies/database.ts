import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { 
  ProducerPoliciesRequest, 
  ProducerPoliciesResponse, 
  ProducerPoliciesUpdate,
  PoliciesFilters,
  PoliciesStats,
  ProducerPoliciesTable
} from './types.ts';

export class ProducerPoliciesDatabase {
  private supabase;
  private tableName = 'producers_terms';

  constructor() {
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    
    if (!supabaseUrl || !supabaseKey) {
      throw new Error('Missing required environment variables: SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY');
    }
    
    this.supabase = createClient(supabaseUrl, supabaseKey);
  }

  /**
   * Get policies for a specific producer
   */
  async getPoliciesByProducerId(producer_id: string): Promise<ProducerPoliciesResponse | null> {
    try {
      const { data, error } = await this.supabase
        .from(this.tableName)
        .select('*')
        .eq('producer_id', producer_id)
        .single();

      if (error) {
        if (error.code === 'PGRST116') {
          // No rows found
          return null;
        }
        throw error;
      }

      return data;
    } catch (error) {
      console.error('Error fetching policies by producer ID:', error);
      throw error;
    }
  }

  /**
   * Get all policies with optional filtering
   */
  async getAllPolicies(filters?: PoliciesFilters): Promise<ProducerPoliciesResponse[]> {
    try {
      let query = this.supabase
        .from(this.tableName)
        .select('*')
        .order('created_at', { ascending: false });

      // Apply filters
      if (filters?.producer_id) {
        query = query.eq('producer_id', filters.producer_id);
      }

      if (filters?.has_terms !== undefined) {
        query = filters.has_terms 
          ? query.not('terms_and_conditions', 'is', null)
          : query.is('terms_and_conditions', null);
      }

      if (filters?.has_privacy !== undefined) {
        query = filters.has_privacy 
          ? query.not('privacy_policy', 'is', null)
          : query.is('privacy_policy', null);
      }

      if (filters?.has_refund !== undefined) {
        query = filters.has_refund 
          ? query.not('refund_policy', 'is', null)
          : query.is('refund_policy', null);
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
    } catch (error) {
      console.error('Error fetching all policies:', error);
      throw error;
    }
  }

  /**
   * Create new policies for a producer
   */
  async createPolicies(policies: ProducerPoliciesRequest): Promise<ProducerPoliciesResponse> {
    try {
      // First check if producer exists
      const { data: producerExists, error: producerError } = await this.supabase
        .from('producers')
        .select('id')
        .eq('id', policies.producer_id)
        .single();

      if (producerError || !producerExists) {
        throw new Error(`Producer with ID ${policies.producer_id} does not exist`);
      }

      // Check if policies already exist for this producer
      const existingPolicies = await this.getPoliciesByProducerId(policies.producer_id);
      if (existingPolicies) {
        throw new Error(`Policies already exist for producer ${policies.producer_id}. Use PUT to update.`);
      }

      const insertData: ProducerPoliciesTable = {
        producer_id: policies.producer_id,
        terms_and_conditions: policies.terms_and_conditions || null,
        privacy_policy: policies.privacy_policy || null,
        refund_policy: policies.refund_policy || null
      };

      const { data, error } = await this.supabase
        .from(this.tableName)
        .insert(insertData)
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error creating policies:', error);
      throw error;
    }
  }

  /**
   * Update existing policies for a producer
   */
  async updatePolicies(producer_id: string, updates: ProducerPoliciesUpdate): Promise<ProducerPoliciesResponse> {
    try {
      // Check if policies exist
      const existingPolicies = await this.getPoliciesByProducerId(producer_id);
      if (!existingPolicies) {
        throw new Error(`No policies found for producer ${producer_id}. Use POST to create new policies.`);
      }

      const updateData: Partial<ProducerPoliciesTable> = {
        updated_at: new Date().toISOString()
      };

      // Only update provided fields
      if (updates.terms_and_conditions !== undefined) {
        updateData.terms_and_conditions = updates.terms_and_conditions || null;
      }
      if (updates.privacy_policy !== undefined) {
        updateData.privacy_policy = updates.privacy_policy || null;
      }
      if (updates.refund_policy !== undefined) {
        updateData.refund_policy = updates.refund_policy || null;
      }

      const { data, error } = await this.supabase
        .from(this.tableName)
        .update(updateData)
        .eq('producer_id', producer_id)
        .select()
        .single();

      if (error) throw error;
      return data;
    } catch (error) {
      console.error('Error updating policies:', error);
      throw error;
    }
  }

  /**
   * Delete policies for a producer
   */
  async deletePolicies(producer_id: string): Promise<void> {
    try {
      // Check if policies exist
      const existingPolicies = await this.getPoliciesByProducerId(producer_id);
      if (!existingPolicies) {
        throw new Error(`No policies found for producer ${producer_id}`);
      }

      const { error } = await this.supabase
        .from(this.tableName)
        .delete()
        .eq('producer_id', producer_id);

      if (error) throw error;
    } catch (error) {
      console.error('Error deleting policies:', error);
      throw error;
    }
  }

  /**
   * Get policies statistics
   */
  async getPoliciesStats(): Promise<PoliciesStats> {
    try {
      // Get total producers count
      const { count: totalProducers, error: producersError } = await this.supabase
        .from('producers')
        .select('*', { count: 'exact', head: true });

      if (producersError) throw producersError;

      // Get policies statistics
      const { data, error } = await this.supabase
        .from(this.tableName)
        .select('terms_and_conditions, privacy_policy, refund_policy');

      if (error) throw error;

      const stats: PoliciesStats = {
        total_producers: totalProducers || 0,
        with_terms: 0,
        with_privacy: 0,
        with_refund: 0,
        complete_policies: 0,
        incomplete_policies: 0
      };

      if (data) {
        data.forEach(policy => {
          if (policy.terms_and_conditions) stats.with_terms++;
          if (policy.privacy_policy) stats.with_privacy++;
          if (policy.refund_policy) stats.with_refund++;
          
          // Complete policy has all three fields
          if (policy.terms_and_conditions && policy.privacy_policy && policy.refund_policy) {
            stats.complete_policies++;
          } else {
            stats.incomplete_policies++;
          }
        });
      }

      return stats;
    } catch (error) {
      console.error('Error fetching policies stats:', error);
      throw error;
    }
  }

  /**
   * Check if producer exists
   */
  async producerExists(producer_id: string): Promise<boolean> {
    try {
      const { data, error } = await this.supabase
        .from('producers')
        .select('id')
        .eq('id', producer_id)
        .single();

      return !error && !!data;
    } catch (error) {
      console.error('Error checking producer existence:', error);
      return false;
    }
  }

  /**
   * Upsert policies (create or update)
   */
  async upsertPolicies(policies: ProducerPoliciesRequest): Promise<ProducerPoliciesResponse> {
    try {
      const existingPolicies = await this.getPoliciesByProducerId(policies.producer_id);
      
      if (existingPolicies) {
        // Update existing
        return await this.updatePolicies(policies.producer_id, {
          terms_and_conditions: policies.terms_and_conditions,
          privacy_policy: policies.privacy_policy,
          refund_policy: policies.refund_policy
        });
      } else {
        // Create new
        return await this.createPolicies(policies);
      }
    } catch (error) {
      console.error('Error upserting policies:', error);
      throw error;
    }
  }
}