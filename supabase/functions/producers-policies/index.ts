import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { ProducerPoliciesDatabase } from './database.ts';
import { ProducerPoliciesValidator } from './validators.ts';
import { ProducerPoliciesUtils } from './utils.ts';
import { 
  ProducerPoliciesRequest, 
  ProducerPoliciesUpdate,
  HttpMethod 
} from './types.ts';

serve(async (req) => {
  const { method, url }: { method: string; url: string } = req;
  const requestId = ProducerPoliciesUtils.generateRequestId();
  
  // Handle CORS preflight requests
  if (method === 'OPTIONS') {
    return ProducerPoliciesUtils.createCorsResponse();
  }

  try {
    // Initialize database
    const db = new ProducerPoliciesDatabase();
    const pathname = new URL(url).pathname;
    
    // Log incoming request
    ProducerPoliciesUtils.logActivity(`${method} ${pathname}`, { 
      requestId,
      userAgent: req.headers.get('user-agent'),
      contentType: req.headers.get('content-type')
    });
    
    // Route handling
    switch (method as HttpMethod) {
      case 'GET':
        return await handleGetRequest(db, url, pathname, requestId);
      
      case 'POST':
        return await handlePostRequest(db, req, requestId);
      
      case 'PUT':
        return await handlePutRequest(db, req, pathname, requestId);
      
      case 'DELETE':
        return await handleDeleteRequest(db, pathname, requestId);
      
      default:
        return ProducerPoliciesUtils.createErrorResponse(
          'Method not allowed',
          405
        );
    }

  } catch (error) {
    ProducerPoliciesUtils.logError(error as Error, `Request ${requestId}`);
    
    return ProducerPoliciesUtils.createErrorResponse(
      ProducerPoliciesUtils.isProduction() 
        ? 'Internal server error' 
        : (error as Error).message,
      500
    );
  }
});

/**
 * Handle GET requests
 */
async function handleGetRequest(
  db: ProducerPoliciesDatabase,
  url: string,
  pathname: string,
  requestId: string
) {
  try {
    const urlObj = new URL(url);
    
    // Health check endpoint
    if (ProducerPoliciesUtils.isHealthEndpoint(pathname)) {
      return ProducerPoliciesUtils.createSuccessResponse({
        status: 'healthy',
        service: 'producers-policies',
        timestamp: new Date().toISOString(),
        requestId
      }, 'Service is healthy');
    }
    
    // Stats endpoint
    if (ProducerPoliciesUtils.isStatsEndpoint(pathname)) {
      const stats = await db.getPoliciesStats();
      const summary = ProducerPoliciesUtils.generatePolicyStatsSummary(stats);
      
      return ProducerPoliciesUtils.createSuccessResponse({
        ...stats,
        summary,
        requestId
      }, 'Policies statistics retrieved successfully');
    }
    
    // Extract producer ID from path
    const producerId = ProducerPoliciesUtils.extractProducerIdFromPath(pathname);
    
    if (producerId) {
      // GET /producers-policies/:producer_id - Get policies for specific producer
      if (!ProducerPoliciesValidator.validateUUID(producerId)) {
        return ProducerPoliciesUtils.createErrorResponse(
          'Invalid producer ID format',
          400
        );
      }
      
      const policies = await db.getPoliciesByProducerId(producerId);
      
      if (!policies) {
        return ProducerPoliciesUtils.createErrorResponse(
          `No policies found for producer ${producerId}`,
          404
        );
      }
      
      // Add policy previews for easier consumption
      const enrichedPolicies = {
        ...policies,
        previews: {
          terms_preview: ProducerPoliciesUtils.generatePolicyPreview(policies.terms_and_conditions),
          privacy_preview: ProducerPoliciesUtils.generatePolicyPreview(policies.privacy_policy),
          refund_preview: ProducerPoliciesUtils.generatePolicyPreview(policies.refund_policy)
        },
        formatted_dates: {
          created_at: ProducerPoliciesUtils.formatDate(policies.created_at),
          updated_at: policies.updated_at ? ProducerPoliciesUtils.formatDate(policies.updated_at) : null
        },
        requestId
      };
      
      return ProducerPoliciesUtils.createSuccessResponse(
        enrichedPolicies,
        'Policies retrieved successfully'
      );
      
    } else {
      // GET /producers-policies - Get all policies with optional filtering
      const filters = ProducerPoliciesUtils.parseQueryFilters(urlObj);
      
      // Validate filters
      const filterValidation = ProducerPoliciesValidator.validateFilters(filters);
      if (!filterValidation.valid) {
        return ProducerPoliciesUtils.createErrorResponse(
          'Invalid query parameters',
          400,
          filterValidation.errors
        );
      }
      
      const allPolicies = await db.getAllPolicies(filters);
      
      // Add metadata
      const response = {
        policies: allPolicies,
        count: allPolicies.length,
        filters_applied: filters,
        requestId
      };
      
      return ProducerPoliciesUtils.createSuccessResponse(
        response,
        `Retrieved ${allPolicies.length} policies`
      );
    }
    
  } catch (error) {
    ProducerPoliciesUtils.logError(error as Error, `GET request ${requestId}`);
    throw error;
  }
}

/**
 * Handle POST requests - Create new policies
 */
async function handlePostRequest(
  db: ProducerPoliciesDatabase,
  req: Request,
  requestId: string
) {
  try {
    // Validate content type
    if (!ProducerPoliciesUtils.validateContentType(req)) {
      return ProducerPoliciesUtils.createErrorResponse(
        'Content-Type must be application/json',
        400
      );
    }
    
    // Parse request body
    const parseResult = await ProducerPoliciesUtils.safeParseJson<ProducerPoliciesRequest>(req);
    if (!parseResult.success) {
      return ProducerPoliciesUtils.createErrorResponse(
        `Invalid JSON: ${parseResult.error}`,
        400
      );
    }
    
    const body = parseResult.data;
    
    // Validate and sanitize request
    const validation = ProducerPoliciesValidator.validateAndSanitizeRequest(body);
    if (!validation.valid) {
      return ProducerPoliciesUtils.createErrorResponse(
        'Validation failed',
        400,
        validation.errors
      );
    }
    
    const sanitizedRequest = validation.sanitizedRequest!;
    
    // Check if producer exists
    const producerExists = await db.producerExists(sanitizedRequest.producer_id);
    if (!producerExists) {
      return ProducerPoliciesUtils.createErrorResponse(
        `Producer with ID ${sanitizedRequest.producer_id} does not exist`,
        404
      );
    }
    
    // Create policies
    const newPolicies = await db.createPolicies(sanitizedRequest);
    
    ProducerPoliciesUtils.logActivity('policies_created', {
      requestId,
      producer_id: newPolicies.producer_id,
      policies_id: newPolicies.id
    });
    
    const response = {
      ...newPolicies,
      requestId
    };
    
    return ProducerPoliciesUtils.createSuccessResponse(
      response,
      'Policies created successfully',
      201
    );
    
  } catch (error) {
    if ((error as Error).message.includes('already exist')) {
      return ProducerPoliciesUtils.createErrorResponse(
        (error as Error).message,
        409 // Conflict
      );
    }
    
    ProducerPoliciesUtils.logError(error as Error, `POST request ${requestId}`);
    throw error;
  }
}

/**
 * Handle PUT requests - Update existing policies
 */
async function handlePutRequest(
  db: ProducerPoliciesDatabase,
  req: Request,
  pathname: string,
  requestId: string
) {
  try {
    // Extract producer ID from path
    const producerId = ProducerPoliciesUtils.extractProducerIdFromPath(pathname);
    
    if (!producerId) {
      return ProducerPoliciesUtils.createErrorResponse(
        'Producer ID is required in the URL path',
        400
      );
    }
    
    if (!ProducerPoliciesValidator.validateUUID(producerId)) {
      return ProducerPoliciesUtils.createErrorResponse(
        'Invalid producer ID format',
        400
      );
    }
    
    // Validate content type
    if (!ProducerPoliciesUtils.validateContentType(req)) {
      return ProducerPoliciesUtils.createErrorResponse(
        'Content-Type must be application/json',
        400
      );
    }
    
    // Parse request body
    const parseResult = await ProducerPoliciesUtils.safeParseJson<ProducerPoliciesUpdate>(req);
    if (!parseResult.success) {
      return ProducerPoliciesUtils.createErrorResponse(
        `Invalid JSON: ${parseResult.error}`,
        400
      );
    }
    
    const body = parseResult.data;
    
    // Validate and sanitize update
    const validation = ProducerPoliciesValidator.validateAndSanitizeUpdate(body);
    if (!validation.valid) {
      return ProducerPoliciesUtils.createErrorResponse(
        'Validation failed',
        400,
        validation.errors
      );
    }
    
    const sanitizedUpdate = validation.sanitizedUpdate!;
    
    // Update policies
    const updatedPolicies = await db.updatePolicies(producerId, sanitizedUpdate);
    
    ProducerPoliciesUtils.logActivity('policies_updated', {
      requestId,
      producer_id: producerId,
      updated_fields: Object.keys(sanitizedUpdate)
    });
    
    const response = {
      ...updatedPolicies,
      requestId
    };
    
    return ProducerPoliciesUtils.createSuccessResponse(
      response,
      'Policies updated successfully'
    );
    
  } catch (error) {
    if ((error as Error).message.includes('No policies found')) {
      return ProducerPoliciesUtils.createErrorResponse(
        (error as Error).message,
        404
      );
    }
    
    ProducerPoliciesUtils.logError(error as Error, `PUT request ${requestId}`);
    throw error;
  }
}

/**
 * Handle DELETE requests - Delete policies
 */
async function handleDeleteRequest(
  db: ProducerPoliciesDatabase,
  pathname: string,
  requestId: string
) {
  try {
    // Extract producer ID from path
    const producerId = ProducerPoliciesUtils.extractProducerIdFromPath(pathname);
    
    if (!producerId) {
      return ProducerPoliciesUtils.createErrorResponse(
        'Producer ID is required in the URL path',
        400
      );
    }
    
    if (!ProducerPoliciesValidator.validateUUID(producerId)) {
      return ProducerPoliciesUtils.createErrorResponse(
        'Invalid producer ID format',
        400
      );
    }
    
    // Delete policies
    await db.deletePolicies(producerId);
    
    ProducerPoliciesUtils.logActivity('policies_deleted', {
      requestId,
      producer_id: producerId
    });
    
    const response = {
      producer_id: producerId,
      deleted: true,
      timestamp: new Date().toISOString(),
      requestId
    };
    
    return ProducerPoliciesUtils.createSuccessResponse(
      response,
      'Policies deleted successfully'
    );
    
  } catch (error) {
    if ((error as Error).message.includes('No policies found')) {
      return ProducerPoliciesUtils.createErrorResponse(
        (error as Error).message,
        404
      );
    }
    
    ProducerPoliciesUtils.logError(error as Error, `DELETE request ${requestId}`);
    throw error;
  }
}