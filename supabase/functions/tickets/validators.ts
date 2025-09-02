import { TicketRequest } from './types.ts';

export class TicketValidator {
  static validateEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  static validatePhone(phone?: string): boolean {
    if (!phone) return true; // Phone is optional
    const phoneRegex = /^\+?[\d\s\-\(\)]{10,}$/;
    return phoneRegex.test(phone);
  }

  static validateTicketType(type?: string): boolean {
    if (!type) return true; // Optional field
    const validTypes = ['regular', 'vip', 'backstage'];
    return validTypes.includes(type);
  }

  static validateTicketRequest(request: TicketRequest): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    // Required fields
    if (!request.name || request.name.trim().length === 0) {
      errors.push('Name is required');
    }

    if (!request.email || request.email.trim().length === 0) {
      errors.push('Email is required');
    } else if (!this.validateEmail(request.email)) {
      errors.push('Invalid email format');
    }

    // Optional fields validation
    if (request.phone && !this.validatePhone(request.phone)) {
      errors.push('Invalid phone format');
    }

    if (request.ticket_type && !this.validateTicketType(request.ticket_type)) {
      errors.push('Invalid ticket type');
    }

    if (request.event_id && (typeof request.event_id !== 'number' || request.event_id <= 0)) {
      errors.push('Invalid event ID');
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }

  static sanitizeInput(input: string): string {
    return input.trim().replace(/[<>]/g, '');
  }
}