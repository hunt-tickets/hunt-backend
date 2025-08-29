import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { TeamDatabase } from './database.ts';
import { TeamValidator } from './validators.ts';
import { TeamUtils } from './utils.ts';
import { TeamRequest, TeamFilters } from './types.ts';

serve(async (req) => {
  const { method, url } = req;
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, GET, PUT, DELETE, OPTIONS'
  };

  if (method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const db = new TeamDatabase();
    const pathname = new URL(url).pathname;
    const urlParams = new URL(url).searchParams;
    
    TeamUtils.logActivity(`${method} ${pathname}`);
    
    switch (method) {
      case 'GET':
        switch (pathname) {
          case '/':
          case '/teams':
            const filters: TeamFilters = {
              producer_id: urlParams.get('producer_id') || undefined,
              limit: urlParams.get('limit') ? parseInt(urlParams.get('limit')!) : undefined,
              offset: urlParams.get('offset') ? parseInt(urlParams.get('offset')!) : undefined
            };
            
            const teams = await db.getAllTeams(filters);

            return new Response(
              JSON.stringify({ 
                success: true, 
                data: teams,
                message: 'Teams retrieved successfully'
              }),
              { 
                headers: { ...corsHeaders, 'Content-Type': 'application/json' }
              }
            );

          default:
            const teamId = pathname.split('/')[1];
            if (teamId && TeamValidator.validateUUID(teamId)) {
              const team = await db.getTeamById(teamId);
              if (!team) {
                return new Response(
                  JSON.stringify({ 
                    success: false, 
                    error: 'Team not found'
                  }),
                  { 
                    status: 404,
                    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                  }
                );
              }

              return new Response(
                JSON.stringify({ 
                  success: true, 
                  data: team,
                  message: 'Team retrieved successfully'
                }),
                { 
                  headers: { ...corsHeaders, 'Content-Type': 'application/json' }
                }
              );
            }

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
        const body: TeamRequest = await req.json();
        
        const validation = TeamValidator.validateTeamRequest(body);
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

        body.name = TeamValidator.sanitizeInput(body.name);
        if (body.description) {
          body.description = TeamValidator.sanitizeInput(body.description);
        }
        
        const newTeam = await db.createTeam(body);
        
        TeamUtils.logActivity('team_created', { 
          team_id: newTeam.id, 
          producer_id: newTeam.producer_id 
        });

        return new Response(
          JSON.stringify({ 
            success: true, 
            data: newTeam,
            message: 'Team created successfully'
          }),
          { 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );

      case 'PUT':
        const updateTeamId = pathname.split('/')[1];
        if (!updateTeamId || !TeamValidator.validateUUID(updateTeamId)) {
          return new Response(
            JSON.stringify({ 
              success: false, 
              error: 'Invalid team ID'
            }),
            { 
              status: 400,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          );
        }

        const updateBody: Partial<TeamRequest> = await req.json();
        const updateValidation = TeamValidator.validateTeamRequest(updateBody as TeamRequest);
        if (!updateValidation.valid) {
          return new Response(
            JSON.stringify({ 
              success: false, 
              error: 'Validation failed',
              details: updateValidation.errors
            }),
            { 
              status: 400, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          );
        }

        if (updateBody.name) {
          updateBody.name = TeamValidator.sanitizeInput(updateBody.name);
        }
        if (updateBody.description) {
          updateBody.description = TeamValidator.sanitizeInput(updateBody.description);
        }

        const updatedTeam = await db.updateTeam(updateTeamId, updateBody);

        TeamUtils.logActivity('team_updated', { 
          team_id: updatedTeam.id 
        });

        return new Response(
          JSON.stringify({ 
            success: true, 
            data: updatedTeam,
            message: 'Team updated successfully'
          }),
          { 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        );

      case 'DELETE':
        const deleteTeamId = pathname.split('/')[1];
        if (!deleteTeamId || !TeamValidator.validateUUID(deleteTeamId)) {
          return new Response(
            JSON.stringify({ 
              success: false, 
              error: 'Invalid team ID'
            }),
            { 
              status: 400,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          );
        }

        await db.deleteTeam(deleteTeamId);

        TeamUtils.logActivity('team_deleted', { 
          team_id: deleteTeamId 
        });

        return new Response(
          JSON.stringify({ 
            success: true, 
            message: 'Team deleted successfully'
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