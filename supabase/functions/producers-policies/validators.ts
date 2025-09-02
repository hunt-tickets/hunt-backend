import { 
  ProducerPoliciesRequest, 
  ProducerPoliciesUpdate, 
  ValidationResult,
  PoliciesFilters
} from './types.ts';

export class ProducerPoliciesValidator {
  
  /**
   * Validate UUID format
   */
  static validateUUID(uuid: string): boolean {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(uuid);
  }

  /**
   * Validate policy content (basic HTML validation)
   */
  static validatePolicyContent(content?: string): boolean {
    if (!content) return true; // Allow empty/null policies
    
    // Check length (reasonable policy length)
    if (content.length > 50000) return false; // Max 50KB per policy
    if (content.trim().length < 10) return false; // Minimum meaningful content
    
    // Basic HTML validation - check for balanced tags
    const openTags = (content.match(/<[^\/][^>]*>/g) || []).length;
    const closeTags = (content.match(/<\/[^>]*>/g) || []).length;
    const selfClosingTags = (content.match(/<[^>]*\/>/g) || []).length;
    
    // Allow some tolerance for self-closing tags and basic HTML structure
    const tagDifference = Math.abs(openTags - closeTags);
    return tagDifference <= selfClosingTags + 5; // Allow some unmatched tags
  }

  /**
   * Validate policy URL format (if policies are stored as URLs)
   */
  static validatePolicyUrl(url?: string): boolean {
    if (!url) return true; // Optional field
    
    try {
      const urlObj = new URL(url);
      return ['http:', 'https:'].includes(urlObj.protocol);
    } catch {
      return false;
    }
  }

  /**
   * Validate producer policies request
   */
  static validatePoliciesRequest(request: ProducerPoliciesRequest): ValidationResult {
    const errors: string[] = [];

    // Required producer_id validation
    if (!request.producer_id) {
      errors.push('Producer ID is required');
    } else if (!this.validateUUID(request.producer_id)) {
      errors.push('Invalid producer ID format. Must be a valid UUID');
    }

    // Validate policy contents
    if (request.terms_and_conditions !== undefined) {
      if (!this.validatePolicyContent(request.terms_and_conditions)) {
        errors.push('Invalid terms and conditions content. Must be between 10-50000 characters with valid HTML structure');
      }
    }

    if (request.privacy_policy !== undefined) {
      if (!this.validatePolicyContent(request.privacy_policy)) {
        errors.push('Invalid privacy policy content. Must be between 10-50000 characters with valid HTML structure');
      }
    }

    if (request.refund_policy !== undefined) {
      if (!this.validatePolicyContent(request.refund_policy)) {
        errors.push('Invalid refund policy content. Must be between 10-50000 characters with valid HTML structure');
      }
    }

    // Ensure at least one policy is provided
    const hasPolicyContent = !!(
      request.terms_and_conditions || 
      request.privacy_policy || 
      request.refund_policy
    );

    if (!hasPolicyContent) {
      errors.push('At least one policy (terms_and_conditions, privacy_policy, or refund_policy) must be provided');
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }

  /**
   * Validate producer policies update request
   */
  static validatePoliciesUpdate(update: ProducerPoliciesUpdate): ValidationResult {
    const errors: string[] = [];

    // Validate policy contents if provided
    if (update.terms_and_conditions !== undefined) {
      if (!this.validatePolicyContent(update.terms_and_conditions)) {
        errors.push('Invalid terms and conditions content. Must be between 10-50000 characters with valid HTML structure');
      }
    }

    if (update.privacy_policy !== undefined) {
      if (!this.validatePolicyContent(update.privacy_policy)) {
        errors.push('Invalid privacy policy content. Must be between 10-50000 characters with valid HTML structure');
      }
    }

    if (update.refund_policy !== undefined) {
      if (!this.validatePolicyContent(update.refund_policy)) {
        errors.push('Invalid refund policy content. Must be between 10-50000 characters with valid HTML structure');
      }
    }

    // Ensure at least one field is being updated
    const hasUpdateContent = !!(
      update.terms_and_conditions !== undefined || 
      update.privacy_policy !== undefined || 
      update.refund_policy !== undefined
    );

    if (!hasUpdateContent) {
      errors.push('At least one policy field must be provided for update');
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }

  /**
   * Validate filters for policies query
   */
  static validateFilters(filters: PoliciesFilters): ValidationResult {
    const errors: string[] = [];

    // Validate producer_id if provided
    if (filters.producer_id && !this.validateUUID(filters.producer_id)) {
      errors.push('Invalid producer ID format in filters');
    }

    // Validate limit
    if (filters.limit !== undefined) {
      if (!Number.isInteger(filters.limit) || filters.limit <= 0 || filters.limit > 1000) {
        errors.push('Limit must be a positive integer between 1 and 1000');
      }
    }

    // Validate offset
    if (filters.offset !== undefined) {
      if (!Number.isInteger(filters.offset) || filters.offset < 0) {
        errors.push('Offset must be a non-negative integer');
      }
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }

  /**
   * Sanitize HTML content for policies
   */
  static sanitizePolicyContent(content?: string): string | null {
    if (!content) return null;
    
    // Basic HTML sanitization
    let sanitized = content
      .trim()
      // Remove potentially dangerous script tags
      .replace(/<script[^>]*>.*?<\/script>/gis, '')
      // Remove event handlers
      .replace(/\s*on\w+\s*=\s*["'][^"']*["']/gi, '')
      // Remove javascript: links
      .replace(/href\s*=\s*["']javascript:[^"']*["']/gi, '')
      // Limit consecutive whitespace
      .replace(/\s{2,}/g, ' ')
      // Clean up line breaks
      .replace(/\n\s*\n/g, '\n');

    return sanitized;
  }

  /**
   * Validate and sanitize complete request
   */
  static validateAndSanitizeRequest(request: ProducerPoliciesRequest): { 
    valid: boolean; 
    errors: string[]; 
    sanitizedRequest?: ProducerPoliciesRequest;
  } {
    const validation = this.validatePoliciesRequest(request);
    
    if (!validation.valid) {
      return {
        valid: false,
        errors: validation.errors
      };
    }

    const sanitizedRequest: ProducerPoliciesRequest = {
      producer_id: request.producer_id,
      terms_and_conditions: this.sanitizePolicyContent(request.terms_and_conditions),
      privacy_policy: this.sanitizePolicyContent(request.privacy_policy),
      refund_policy: this.sanitizePolicyContent(request.refund_policy)
    };

    return {
      valid: true,
      errors: [],
      sanitizedRequest
    };
  }

  /**
   * Validate and sanitize update request
   */
  static validateAndSanitizeUpdate(update: ProducerPoliciesUpdate): { 
    valid: boolean; 
    errors: string[]; 
    sanitizedUpdate?: ProducerPoliciesUpdate;
  } {
    const validation = this.validatePoliciesUpdate(update);
    
    if (!validation.valid) {
      return {
        valid: false,
        errors: validation.errors
      };
    }

    const sanitizedUpdate: ProducerPoliciesUpdate = {};

    if (update.terms_and_conditions !== undefined) {
      sanitizedUpdate.terms_and_conditions = this.sanitizePolicyContent(update.terms_and_conditions);
    }
    if (update.privacy_policy !== undefined) {
      sanitizedUpdate.privacy_policy = this.sanitizePolicyContent(update.privacy_policy);
    }
    if (update.refund_policy !== undefined) {
      sanitizedUpdate.refund_policy = this.sanitizePolicyContent(update.refund_policy);
    }

    return {
      valid: true,
      errors: [],
      sanitizedUpdate
    };
  }

  /**
   * Check if policy content looks like HTML
   */
  static isHtmlContent(content: string): boolean {
    return /<[^>]+>/.test(content);
  }

  /**
   * Validate content type for policies
   */
  static validateContentType(content?: string, allowPlainText = true): boolean {
    if (!content) return true;
    
    const isHtml = this.isHtmlContent(content);
    
    if (isHtml) {
      return this.validatePolicyContent(content);
    } else {
      // Plain text validation
      return allowPlainText && content.length >= 10 && content.length <= 50000;
    }
  }
}