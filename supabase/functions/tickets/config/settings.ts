// Simple configuration for tickets function
export const TICKET_CONFIG = {
  MAX_TICKETS_PER_REQUEST: 100,
  DEFAULT_STATUS: 'active',
  VERSION: '1.0.0'
};

export function getConfig(key: string): any {
  return TICKET_CONFIG[key] || null;
}