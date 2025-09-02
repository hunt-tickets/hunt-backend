export class AuthHelpers {
  static extractBearerToken(request: Request): string | null {
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    return authHeader.substring(7);
  }

  static validateApiKey(apiKey: string): boolean {
    const validKeys = [
      Deno.env.get('HUNT_API_KEY'),
      Deno.env.get('SUPABASE_ANON_KEY')
    ].filter(Boolean);
    
    return validKeys.includes(apiKey);
  }

  static generateSessionId(): string {
    return `sess_${Date.now()}_${crypto.randomUUID().replace(/-/g, '')}`;
  }

  static isValidUUID(uuid: string): boolean {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(uuid);
  }

  static hashPassword(password: string): string {
    // Simple hash for demo - in production use proper bcrypt
    const encoder = new TextEncoder();
    const data = encoder.encode(password + 'hunt_salt');
    return Array.from(data).map(byte => byte.toString(16).padStart(2, '0')).join('');
  }

  static generateTempToken(userId: string, expiresIn: number = 3600): string {
    const payload = {
      user_id: userId,
      expires_at: Date.now() + (expiresIn * 1000),
      issued_by: 'hunt-tickets'
    };
    
    return btoa(JSON.stringify(payload));
  }

  static validateTempToken(token: string): { valid: boolean; userId?: string } {
    try {
      const payload = JSON.parse(atob(token));
      
      if (payload.expires_at < Date.now()) {
        return { valid: false };
      }
      
      return { 
        valid: true, 
        userId: payload.user_id 
      };
    } catch {
      return { valid: false };
    }
  }
}