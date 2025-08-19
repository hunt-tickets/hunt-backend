import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { TicketDatabase } from './database.ts';
import { TicketValidator } from './validators.ts';
import { TicketUtils } from './utils.ts';
import { TicketRequest, ApiResponse, TicketFilters } from './types.ts';
import { runTest } from './test.ts';
import { sayHello, getCurrentTime } from './lib/simple.ts';
import { getConfig } from './config/settings.ts';

serve(async (req) => {
  const { method, url } = req;
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
  };

  // Handle CORS preflight
  if (method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Initialize database and utils
    const db = new TicketDatabase();
    const pathname = new URL(url).pathname;
    
    TicketUtils.logActivity(`${method} ${pathname}`);
    
    switch (method) {
      case 'GET':
        // Handle different GET routes
        switch (pathname) {
          case '/':
          case '/tickets':
            // Get all tickets with optional filtering
            const urlParams = new URL(url).searchParams;
            const filters: TicketFilters = {
              status: urlParams.get('status') || undefined,
              limit: urlParams.get('limit') ? parseInt(urlParams.get('limit')!) : undefined
            };
            
            const tickets = await db.getAllTickets(filters);

            return new Response(
              JSON.stringify({ 
                success: true, 
                data: tickets,
                message: 'Tickets retrieved successfully'
              }),
              { 
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
              }
            );

          case '/test':
            // Test route using test.ts
            const testResult = runTest();
            return new Response(
              JSON.stringify({ 
                success: true, 
                data: testResult,
                message: 'Test completed'
              }),
              { 
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
              }
            );

          case '/hello':
            // Simple hello route from lib/simple.ts
            return new Response(
              JSON.stringify({ 
                success: true, 
                data: {
                  message: sayHello(),
                  timestamp: getCurrentTime(),
                  config: getConfig('VERSION')
                }
              }),
              { 
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
              }
            );

          case '/config':
            // Config route from config/settings.ts
            return new Response(
              JSON.stringify({ 
                success: true, 
                data: {
                  version: getConfig('VERSION'),
                  maxTickets: getConfig('MAX_TICKETS_PER_REQUEST'),
                  defaultStatus: getConfig('DEFAULT_STATUS')
                }
              }),
              { 
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
              }
            );

          default:
            return new Response(
              JSON.stringify({ 
                success: false, 
                error: 'Route not found'
              }),
              { 
                status: 404,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
              }
            );
        }

      case 'POST':
        // Create new ticket with validation
        const body: TicketRequest = await req.json();
        
        // Validate input
        const validation = TicketValidator.validateTicketRequest(body);
        if (!validation.valid) {
          return new Response(
            JSON.stringify({ 
              success: false, 
              error: 'Validation failed',
              details: validation.errors
            }),
            { 
              status: 400, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          );
        }

        // Sanitize input
        body.name = TicketValidator.sanitizeInput(body.name);
        body.email = TicketValidator.sanitizeInput(body.email);
        
        const newTicket = await db.createTicket(body);
        
        TicketUtils.logActivity('ticket_created', { 
          ticket_id: newTicket.id, 
          email: newTicket.email 
        });

        return new Response(
          JSON.stringify({ 
            success: true, 
            data: newTicket,
            message: 'Ticket created successfully'
          }),
          { 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );

      default:
        return new Response(
          JSON.stringify({ 
            success: false, 
            error: 'Method not allowed' 
          }),
          { 
            status: 405, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );
    }

  } catch (error) {
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