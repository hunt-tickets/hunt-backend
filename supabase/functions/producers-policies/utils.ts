import { ApiResponse, ApiError, CorsHeaders } from './types.ts';

export class ProducerPoliciesUtils {
  
  /**
   * Get CORS headers for all responses
   */
  static getCorsHeaders(): CorsHeaders {
    return {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
    };
  }

  /**
   * Create a success response
   */
  static createSuccessResponse<T>(
    data: T, 
    message?: string,
    status = 200
  ): Response {
    const response: ApiResponse<T> = {
      success: true,
      data,
      message: message || 'Operation completed successfully'
    };

    return new Response(
      JSON.stringify(response),
      {
        status,
        headers: {
          ...this.getCorsHeaders(),
          'Content-Type': 'application/json'
        }
      }
    );
  }

  /**
   * Create an error response
   */
  static createErrorResponse(
    error: string | ApiError,
    status = 400,
    details?: string[]
  ): Response {
    const errorResponse: ApiResponse<null> = {
      success: false,
      error: typeof error === 'string' ? error : error.message
    };

    if (details && details.length > 0) {
      errorResponse.message = details.join(', ');
    }

    return new Response(
      JSON.stringify(errorResponse),
      {
        status,
        headers: {
          ...this.getCorsHeaders(),
          'Content-Type': 'application/json'
        }
      }
    );
  }

  /**
   * Create a CORS preflight response
   */
  static createCorsResponse(): Response {
    return new Response('ok', { 
      headers: this.getCorsHeaders() 
    });
  }

  /**
   * Extract producer ID from URL pathname
   */
  static extractProducerIdFromPath(pathname: string): string | null {
    // Expected patterns: 
    // /producers-policies/:producer_id
    // /:producer_id
    const pathSegments = pathname.split('/').filter(segment => segment.length > 0);
    
    if (pathSegments.length >= 2) {
      // /producers-policies/:producer_id
      return pathSegments[1];
    } else if (pathSegments.length === 1) {
      // /:producer_id
      return pathSegments[0];
    }
    
    return null;
  }

  /**
   * Parse URL parameters into filters object
   */
  static parseQueryFilters(url: URL): any {
    const filters: any = {};
    
    // Get query parameters
    const searchParams = url.searchParams;
    
    // Parse boolean filters
    if (searchParams.has('has_terms')) {
      filters.has_terms = searchParams.get('has_terms') === 'true';
    }
    
    if (searchParams.has('has_privacy')) {
      filters.has_privacy = searchParams.get('has_privacy') === 'true';
    }
    
    if (searchParams.has('has_refund')) {
      filters.has_refund = searchParams.get('has_refund') === 'true';
    }
    
    // Parse numeric filters
    if (searchParams.has('limit')) {
      const limit = parseInt(searchParams.get('limit')!);
      if (!isNaN(limit)) {
        filters.limit = limit;
      }
    }
    
    if (searchParams.has('offset')) {
      const offset = parseInt(searchParams.get('offset')!);
      if (!isNaN(offset)) {
        filters.offset = offset;
      }
    }
    
    // Parse string filters
    if (searchParams.has('producer_id')) {
      filters.producer_id = searchParams.get('producer_id');
    }
    
    return filters;
  }

  /**
   * Log activity with structured format
   */
  static logActivity(action: string, details?: any): void {
    const logEntry = {
      timestamp: new Date().toISOString(),
      service: 'producers-policies-api',
      action,
      details: details || {},
      environment: Deno.env.get('DENO_ENV') || 'development'
    };
    
    console.log(JSON.stringify(logEntry));
  }

  /**
   * Log error with stack trace
   */
  static logError(error: Error, context?: string): void {
    const errorLog = {
      timestamp: new Date().toISOString(),
      service: 'producers-policies-api',
      level: 'error',
      context: context || 'unknown',
      message: error.message,
      stack: error.stack,
      environment: Deno.env.get('DENO_ENV') || 'development'
    };
    
    console.error(JSON.stringify(errorLog));
  }

  /**
   * Generate policy preview (first 200 characters)
   */
  static generatePolicyPreview(content: string | null): string | null {
    if (!content) return null;
    
    // Strip HTML tags for preview
    const plainText = content.replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();
    
    if (plainText.length <= 200) return plainText;
    
    return plainText.substring(0, 197) + '...';
  }

  /**
   * Validate request content type
   */
  static validateContentType(request: Request): boolean {
    const contentType = request.headers.get('content-type');
    return !contentType || contentType.includes('application/json');
  }

  /**
   * Safely parse JSON from request
   */
  static async safeParseJson<T>(request: Request): Promise<{ success: true; data: T } | { success: false; error: string }> {
    try {
      const data = await request.json();
      return { success: true, data };
    } catch (error) {
      return { 
        success: false, 
        error: error instanceof Error ? error.message : 'Invalid JSON format' 
      };
    }
  }

  /**
   * Format date for display
   */
  static formatDate(date: string | Date): string {
    const dateObj = typeof date === 'string' ? new Date(date) : date;
    
    return new Intl.DateTimeFormat('es-ES', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: 'America/Bogota'
    }).format(dateObj);
  }

  /**
   * Check if environment is production
   */
  static isProduction(): boolean {
    return Deno.env.get('DENO_ENV') === 'production';
  }

  /**
   * Generate policy stats summary
   */
  static generatePolicyStatsSummary(stats: any): string {
    const completionRate = stats.total_producers > 0 
      ? Math.round((stats.complete_policies / stats.total_producers) * 100)
      : 0;
      
    return `Policies completion: ${completionRate}% (${stats.complete_policies}/${stats.total_producers} producers)`;
  }

  /**
   * Validate HTTP method for endpoint
   */
  static isMethodAllowed(method: string, allowedMethods: string[]): boolean {
    return allowedMethods.includes(method.toUpperCase());
  }

  /**
   * Extract authorization token from request
   */
  static extractAuthToken(request: Request): string | null {
    const authHeader = request.headers.get('authorization');
    if (!authHeader) return null;
    
    const parts = authHeader.split(' ');
    if (parts.length === 2 && parts[0].toLowerCase() === 'bearer') {
      return parts[1];
    }
    
    return null;
  }

  /**
   * Create rate limiting key for producer
   */
  static createRateLimitKey(producerId: string, action: string): string {
    return `rate_limit:${producerId}:${action}:${Math.floor(Date.now() / 60000)}`; // Per minute
  }

  /**
   * Generate unique request ID
   */
  static generateRequestId(): string {
    return `req_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
  }

  /**
   * Add request ID to response headers
   */
  static addRequestIdHeader(headers: CorsHeaders, requestId: string): CorsHeaders & { 'X-Request-ID': string } {
    return {
      ...headers,
      'X-Request-ID': requestId
    };
  }

  /**
   * Check if URL path is for stats endpoint
   */
  static isStatsEndpoint(pathname: string): boolean {
    return pathname.includes('/stats') || pathname.endsWith('/statistics');
  }

  /**
   * Check if URL path is for health check
   */
  static isHealthEndpoint(pathname: string): boolean {
    return pathname.includes('/health') || pathname === '/ping';
  }
}