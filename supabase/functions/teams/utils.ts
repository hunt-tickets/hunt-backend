export class TeamUtils {
  static generateTeamCode(name: string): string {
    const cleanName = name.trim().replace(/[^a-zA-Z0-9]/g, '').toUpperCase();
    const timestamp = Date.now().toString().slice(-6);
    return `${cleanName.slice(0, 4)}-${timestamp}`;
  }

  static formatTeamName(name: string): string {
    return name.trim().replace(/\s+/g, ' ');
  }

  static logActivity(action: string, details?: any): void {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      action,
      details,
      service: 'hunt-teams-api'
    }));
  }

  static validateTeamSize(memberCount: number, maxSize: number = 50): boolean {
    return memberCount >= 1 && memberCount <= maxSize;
  }

  static generateTeamSlug(name: string): string {
    return name
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-+|-+$/g, '');
  }
}