import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface EventRequest {
  title: string;
  description?: string;
  event_date: string;
  location: string;
  max_capacity?: number;
  price?: number;
  category?: 'concert' | 'theater' | 'sports' | 'conference' | 'general';
  organizer_id?: string;
}

interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

serve(async (req) => {
  const { method, url } = req;
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
  };

  // Handle CORS preflight
  if (method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const { pathname } = new URL(url);
    
    switch (method) {
      case 'GET':
        return handleGet(supabase, pathname, url, corsHeaders);
      case 'POST':
        return handlePost(supabase, req, corsHeaders);
      case 'PUT':
        return handlePut(supabase, pathname, req, corsHeaders);
      case 'DELETE':
        return handleDelete(supabase, pathname, corsHeaders);
      default:
        return new Response(
          JSON.stringify({ success: false, error: 'Method not allowed' }),
          { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
    }

  } catch (error) {
    console.error('Edge Function Error:', error);
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message || 'Internal server error' 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});

async function handleGet(supabase: any, pathname: string, url: string, corsHeaders: any) {
  const urlParams = new URLSearchParams(new URL(url).search);
  
  switch (pathname) {
    case '/':
    case '/events':
      // Get all events with optional filtering
      let query = supabase.from('events').select('*');
      
      // Apply filters
      const status = urlParams.get('status');
      const category = urlParams.get('category');
      const limit = urlParams.get('limit');
      
      if (status) query = query.eq('status', status);
      if (category) query = query.eq('category', category);
      if (limit) query = query.limit(parseInt(limit));
      
      query = query.order('event_date', { ascending: true });
      
      const { data: events, error } = await query;
      
      if (error) throw error;
      
      return new Response(
        JSON.stringify({ 
          success: true, 
          data: events,
          count: events?.length || 0,
          message: 'Events retrieved successfully'
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );

    case '/stats':
      // Get event statistics
      const { data: allEvents, error: statsError } = await supabase
        .from('events')
        .select('status, category, price, max_capacity, current_capacity');
      
      if (statsError) throw statsError;
      
      const stats = {
        total: allEvents?.length || 0,
        by_status: {},
        by_category: {},
        total_capacity: 0,
        total_sold: 0,
        revenue: 0
      };
      
      allEvents?.forEach((event: any) => {
        // Count by status
        stats.by_status[event.status] = (stats.by_status[event.status] || 0) + 1;
        
        // Count by category  
        stats.by_category[event.category] = (stats.by_category[event.category] || 0) + 1;
        
        // Calculate totals
        stats.total_capacity += event.max_capacity || 0;
        stats.total_sold += event.current_capacity || 0;
        stats.revenue += (event.price || 0) * (event.current_capacity || 0);
      });
      
      return new Response(
        JSON.stringify({ 
          success: true, 
          data: stats,
          message: 'Event statistics retrieved successfully'
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );

    default:
      // Try to get specific event by ID
      const eventId = pathname.split('/')[1];
      if (eventId && !isNaN(Number(eventId))) {
        const { data: event, error } = await supabase
          .from('events')
          .select('*')
          .eq('id', eventId)
          .single();
        
        if (error) {
          if (error.code === 'PGRST116') {
            return new Response(
              JSON.stringify({ success: false, error: 'Event not found' }),
              { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
            );
          }
          throw error;
        }
        
        return new Response(
          JSON.stringify({ 
            success: true, 
            data: event,
            message: 'Event retrieved successfully'
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
      
      return new Response(
        JSON.stringify({ success: false, error: 'Route not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
  }
}

async function handlePost(supabase: any, req: Request, corsHeaders: any) {
  const body: EventRequest = await req.json();
  
  // Basic validation
  if (!body.title || !body.event_date || !body.location) {
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: 'Missing required fields: title, event_date, location' 
      }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
  
  // Insert event
  const { data: event, error } = await supabase
    .from('events')
    .insert({
      title: body.title,
      description: body.description || null,
      event_date: body.event_date,
      location: body.location,
      max_capacity: body.max_capacity || 100,
      current_capacity: 0,
      price: body.price || 0,
      category: body.category || 'general',
      organizer_id: body.organizer_id || null,
      status: 'active',
      metadata: {}
    })
    .select()
    .single();
  
  if (error) throw error;
  
  return new Response(
    JSON.stringify({ 
      success: true, 
      data: event,
      message: 'Event created successfully'
    }),
    { 
      status: 201,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
    }
  );
}

async function handlePut(supabase: any, pathname: string, req: Request, corsHeaders: any) {
  const eventId = pathname.split('/')[1];
  
  if (!eventId || isNaN(Number(eventId))) {
    return new Response(
      JSON.stringify({ success: false, error: 'Invalid event ID' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
  
  const body: Partial<EventRequest> = await req.json();
  
  const { data: event, error } = await supabase
    .from('events')
    .update(body)
    .eq('id', eventId)
    .select()
    .single();
  
  if (error) {
    if (error.code === 'PGRST116') {
      return new Response(
        JSON.stringify({ success: false, error: 'Event not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }
    throw error;
  }
  
  return new Response(
    JSON.stringify({ 
      success: true, 
      data: event,
      message: 'Event updated successfully'
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

async function handleDelete(supabase: any, pathname: string, corsHeaders: any) {
  const eventId = pathname.split('/')[1];
  
  if (!eventId || isNaN(Number(eventId))) {
    return new Response(
      JSON.stringify({ success: false, error: 'Invalid event ID' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
  
  const { error } = await supabase
    .from('events')
    .delete()
    .eq('id', eventId);
  
  if (error) throw error;
  
  return new Response(
    JSON.stringify({ 
      success: true, 
      message: 'Event deleted successfully'
    }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}