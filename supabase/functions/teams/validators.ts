import { TeamRequest } from './types.ts';

export class TeamValidator {
  static validateUUID(uuid: string): boolean {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(uuid);
  }

  static validateTeamRequest(request: TeamRequest): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    if (!request.name || request.name.trim().length === 0) {
      errors.push('Name is required');
    }

    if (request.name && request.name.trim().length > 255) {
      errors.push('Name must be less than 255 characters');
    }

    if (!request.producer_id || !this.validateUUID(request.producer_id)) {
      errors.push('Valid producer_id is required');
    }

    if (request.description && request.description.length > 1000) {
      errors.push('Description must be less than 1000 characters');
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