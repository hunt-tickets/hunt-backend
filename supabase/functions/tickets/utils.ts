export class TicketUtils {
  static generateTicketId(): string {
    return `TKT-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`;
  }

  static formatTicketNumber(id: number): string {
    return `HUNT-${id.toString().padStart(6, '0')}`;
  }

  static calculateTicketPrice(type: string, basePrice: number = 50): number {
    const multipliers = {
      'regular': 1,
      'vip': 2.5,
      'backstage': 5
    };
    
    return basePrice * (multipliers[type] || 1);
  }

  static generateQRData(ticketId: string, email: string): string {
    const data = {
      ticket_id: ticketId,
      email: email,
      timestamp: new Date().toISOString(),
      platform: 'hunt-tickets'
    };
    
    return btoa(JSON.stringify(data));
  }

  static validateQRData(qrData: string): boolean {
    try {
      const decoded = JSON.parse(atob(qrData));
      return decoded.ticket_id && decoded.email && decoded.platform === 'hunt-tickets';
    } catch {
      return false;
    }
  }

  static formatDate(date: Date): string {
    return new Intl.DateTimeFormat('es-ES', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: 'America/Bogota'
    }).format(date);
  }

  static generateEmailTemplate(ticketData: any): string {
    return `
      <h2>¡Tu ticket de Hunt Tickets está listo! 🎫</h2>
      <p>Hola ${ticketData.name},</p>
      <p>Tu ticket ha sido confirmado:</p>
      <ul>
        <li><strong>Número:</strong> ${this.formatTicketNumber(ticketData.id)}</li>
        <li><strong>Tipo:</strong> ${ticketData.metadata?.ticket_type || 'Regular'}</li>
        <li><strong>Estado:</strong> ${ticketData.status}</li>
        <li><strong>Fecha:</strong> ${this.formatDate(new Date(ticketData.created_at))}</li>
      </ul>
      <p>¡Nos vemos en el evento!</p>
      <p><small>Hunt Tickets - La mejor plataforma de tickets online</small></p>
    `;
  }

  static logActivity(action: string, details?: any): void {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      action,
      details,
      service: 'hunt-tickets-api'
    }));
  }
}