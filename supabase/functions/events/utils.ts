// Utility functions for Events Edge Function

export class EventUtils {
  static validateEventDate(dateString: string): boolean {
    const date = new Date(dateString);
    const now = new Date();
    
    // Check if date is valid and in the future
    return !isNaN(date.getTime()) && date > now;
  }

  static formatEventDate(dateString: string): string {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('es-CO', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: 'America/Bogota'
    }).format(date);
  }

  static calculateOccupancyRate(currentCapacity: number, maxCapacity: number): number {
    if (maxCapacity === 0) return 0;
    return Math.round((currentCapacity / maxCapacity) * 100);
  }

  static determineEventStatus(event: any): string {
    const now = new Date();
    const eventDate = new Date(event.event_date);
    
    // If event is in the past
    if (eventDate < now) {
      return 'completed';
    }
    
    // If sold out
    if (event.current_capacity >= event.max_capacity) {
      return 'sold_out';
    }
    
    // Return current status or default to active
    return event.status || 'active';
  }

  static generateEventSlug(title: string): string {
    return title
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // Remove accents
      .replace(/[^a-z0-9\s-]/g, '') // Remove special chars
      .replace(/\s+/g, '-') // Replace spaces with hyphens
      .replace(/-+/g, '-') // Replace multiple hyphens with single
      .replace(/^-|-$/g, ''); // Remove leading/trailing hyphens
  }

  static formatPrice(price: number, currency: string = 'COP'): string {
    return new Intl.NumberFormat('es-CO', {
      style: 'currency',
      currency: currency,
      minimumFractionDigits: 0
    }).format(price);
  }

  static getEventCapacityInfo(event: any): {
    available: number;
    percentage: number;
    status: 'available' | 'limited' | 'sold_out';
  } {
    const available = event.max_capacity - event.current_capacity;
    const percentage = this.calculateOccupancyRate(event.current_capacity, event.max_capacity);
    
    let status: 'available' | 'limited' | 'sold_out';
    if (available === 0) {
      status = 'sold_out';
    } else if (percentage >= 80) {
      status = 'limited';
    } else {
      status = 'available';
    }
    
    return { available, percentage, status };
  }

  static validateEventData(eventData: any): { valid: boolean; errors: string[] } {
    const errors: string[] = [];
    
    // Required fields
    if (!eventData.title?.trim()) {
      errors.push('Title is required');
    }
    
    if (!eventData.event_date) {
      errors.push('Event date is required');
    } else if (!this.validateEventDate(eventData.event_date)) {
      errors.push('Event date must be in the future and valid');
    }
    
    if (!eventData.location?.trim()) {
      errors.push('Location is required');
    }
    
    // Optional field validations
    if (eventData.max_capacity !== undefined && eventData.max_capacity < 1) {
      errors.push('Max capacity must be at least 1');
    }
    
    if (eventData.price !== undefined && eventData.price < 0) {
      errors.push('Price cannot be negative');
    }
    
    const validCategories = ['concert', 'theater', 'sports', 'conference', 'general'];
    if (eventData.category && !validCategories.includes(eventData.category)) {
      errors.push(`Category must be one of: ${validCategories.join(', ')}`);
    }
    
    return {
      valid: errors.length === 0,
      errors
    };
  }

  static sanitizeEventData(eventData: any): any {
    return {
      ...eventData,
      title: eventData.title?.trim(),
      description: eventData.description?.trim() || null,
      location: eventData.location?.trim(),
      max_capacity: Math.max(1, parseInt(eventData.max_capacity) || 100),
      price: Math.max(0, parseFloat(eventData.price) || 0),
      category: eventData.category || 'general'
    };
  }

  static logEventActivity(action: string, eventId?: number, details?: any): void {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      action,
      event_id: eventId,
      details,
      service: 'hunt-tickets-events-api'
    }));
  }
}