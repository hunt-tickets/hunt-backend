export class CryptoHelpers {
  static generateSecureId(prefix: string = ''): string {
    const uuid = crypto.randomUUID();
    return prefix ? `${prefix}_${uuid}` : uuid;
  }

  static generateRandomString(length: number = 16): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    
    return result;
  }

  static async hashString(input: string): Promise<string> {
    const encoder = new TextEncoder();
    const data = encoder.encode(input);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
  }

  static generateHMAC(message: string, secret: string): Promise<string> {
    return this.hashString(`${message}.${secret}`);
  }

  static encodeBase64Url(data: string): string {
    return btoa(data)
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
  }

  static decodeBase64Url(encoded: string): string {
    // Add padding if needed
    let padded = encoded;
    while (padded.length % 4) {
      padded += '=';
    }
    
    const base64 = padded.replace(/-/g, '+').replace(/_/g, '/');
    return atob(base64);
  }

  static generateSignature(payload: any, secret: string): string {
    const message = typeof payload === 'string' ? payload : JSON.stringify(payload);
    return this.encodeBase64Url(`${message}.${secret}`);
  }

  static validateSignature(payload: any, signature: string, secret: string): boolean {
    const expectedSignature = this.generateSignature(payload, secret);
    return signature === expectedSignature;
  }

  static createJWT(payload: any, secret: string, expiresIn: number = 3600): string {
    const header = { alg: 'HS256', typ: 'JWT' };
    const now = Math.floor(Date.now() / 1000);
    
    const jwtPayload = {
      ...payload,
      iat: now,
      exp: now + expiresIn
    };
    
    const encodedHeader = this.encodeBase64Url(JSON.stringify(header));
    const encodedPayload = this.encodeBase64Url(JSON.stringify(jwtPayload));
    const signature = this.generateSignature(`${encodedHeader}.${encodedPayload}`, secret);
    
    return `${encodedHeader}.${encodedPayload}.${signature}`;
  }
}