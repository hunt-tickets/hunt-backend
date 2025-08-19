import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { AuthHelpers } from './auth.ts';
import { CryptoHelpers } from './crypto.ts';
import { Formatters } from './formatters.ts';
import { HUNT_CONSTANTS } from './constants.ts';

serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  };

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const { pathname } = new URL(req.url);

  try {
    switch (pathname) {
      case '/':
      case '/info':
        return new Response(
          JSON.stringify({
            success: true,
            message: "Hunt Tickets Helper Functions API",
            version: HUNT_CONSTANTS.API.VERSION,
            endpoints: {
              '/demo': 'Demonstrations of all helper functions',
              '/auth': 'Authentication utilities demo',
              '/crypto': 'Cryptographic functions demo', 
              '/format': 'Formatting utilities demo',
              '/constants': 'Application constants'
            }
          }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );

      case '/demo':
        const demoData = {
          auth: {
            sessionId: AuthHelpers.generateSessionId(),
            tempToken: AuthHelpers.generateTempToken('user123'),
            isValidUUID: AuthHelpers.isValidUUID('123e4567-e89b-12d3-a456-426614174000')
          },
          crypto: {
            secureId: CryptoHelpers.generateSecureId('ticket'),
            randomString: CryptoHelpers.generateRandomString(12),
            base64Url: CryptoHelpers.encodeBase64Url('Hunt Tickets Demo')
          },
          formatters: {
            currency: Formatters.formatCurrency(50000),
            date: Formatters.formatDate(new Date()),
            relativeTime: Formatters.formatRelativeTime(new Date(Date.now() - 3600000)),
            phone: Formatters.formatPhone('3001234567'),
            maskedEmail: Formatters.maskEmail('user@hunt-tickets.com'),
            slug: Formatters.slugify('Concierto de Rock en Bogotá')
          }
        };

        return new Response(
          JSON.stringify({ success: true, data: demoData }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );

      case '/constants':
        return new Response(
          JSON.stringify({ success: true, data: HUNT_CONSTANTS }),
          { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );

      default:
        return new Response(
          JSON.stringify({ success: false, error: 'Endpoint not found' }),
          { 
            status: 404,
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