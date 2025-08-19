// Hunt Tickets Constants and Configuration
export const HUNT_CONSTANTS = {
  // API Configuration
  API: {
    VERSION: '1.0.0',
    BASE_URL: 'https://api.hunt-tickets.com',
    TIMEOUT: 30000,
    RATE_LIMIT: {
      REQUESTS_PER_MINUTE: 60,
      BURST_LIMIT: 10
    }
  },

  // Ticket Types and Pricing
  TICKETS: {
    TYPES: {
      REGULAR: 'regular',
      VIP: 'vip',
      BACKSTAGE: 'backstage'
    },
    STATUS: {
      ACTIVE: 'active',
      CANCELLED: 'cancelled',
      USED: 'used',
      EXPIRED: 'expired'
    },
    BASE_PRICE: 50000, // COP
    MULTIPLIERS: {
      regular: 1,
      vip: 2.5,
      backstage: 5
    }
  },

  // Event Categories
  EVENTS: {
    CATEGORIES: {
      CONCERT: 'concert',
      THEATER: 'theater',
      SPORTS: 'sports',
      CONFERENCE: 'conference',
      FESTIVAL: 'festival'
    },
    MAX_CAPACITY: 50000,
    MIN_CAPACITY: 50
  },

  // User Roles and Permissions
  USERS: {
    ROLES: {
      ADMIN: 'admin',
      ORGANIZER: 'organizer',
      USER: 'user',
      GUEST: 'guest'
    },
    PERMISSIONS: {
      CREATE_EVENT: 'create_event',
      MANAGE_TICKETS: 'manage_tickets',
      VIEW_ANALYTICS: 'view_analytics',
      MANAGE_USERS: 'manage_users'
    }
  },

  // Payment and Currency
  PAYMENT: {
    CURRENCY: 'COP',
    METHODS: {
      CREDIT_CARD: 'credit_card',
      PSE: 'pse',
      NEQUI: 'nequi',
      DAVIPLATA: 'daviplata'
    },
    PROCESSING_FEE: 0.029, // 2.9%
    MINIMUM_AMOUNT: 5000
  },

  // Email Templates
  EMAILS: {
    TEMPLATES: {
      TICKET_CONFIRMATION: 'ticket_confirmation',
      EVENT_REMINDER: 'event_reminder',
      REFUND_NOTICE: 'refund_notice',
      PASSWORD_RESET: 'password_reset'
    },
    FROM_ADDRESS: 'noreply@hunt-tickets.com',
    SUPPORT_ADDRESS: 'support@hunt-tickets.com'
  },

  // File Upload Limits
  UPLOADS: {
    MAX_FILE_SIZE: 10 * 1024 * 1024, // 10MB
    ALLOWED_TYPES: {
      IMAGES: ['jpg', 'jpeg', 'png', 'webp'],
      DOCUMENTS: ['pdf', 'doc', 'docx']
    }
  },

  // Cache Configuration
  CACHE: {
    TTL: {
      SHORT: 300,    // 5 minutes
      MEDIUM: 1800,  // 30 minutes
      LONG: 3600,    // 1 hour
      VERY_LONG: 86400 // 24 hours
    }
  },

  // Validation Rules
  VALIDATION: {
    EMAIL_REGEX: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
    PHONE_REGEX: /^\+?[\d\s\-\(\)]{10,}$/,
    PASSWORD_MIN_LENGTH: 8,
    NAME_MIN_LENGTH: 2,
    NAME_MAX_LENGTH: 100
  },

  // Error Messages
  ERRORS: {
    VALIDATION: {
      REQUIRED_FIELD: 'Este campo es requerido',
      INVALID_EMAIL: 'Email no válido',
      INVALID_PHONE: 'Teléfono no válido',
      PASSWORD_TOO_SHORT: 'La contraseña debe tener al menos 8 caracteres'
    },
    AUTH: {
      UNAUTHORIZED: 'No autorizado',
      FORBIDDEN: 'Acceso denegado',
      TOKEN_EXPIRED: 'Token expirado'
    },
    SYSTEM: {
      INTERNAL_ERROR: 'Error interno del servidor',
      SERVICE_UNAVAILABLE: 'Servicio no disponible',
      RATE_LIMIT_EXCEEDED: 'Límite de solicitudes excedido'
    }
  },

  // Success Messages
  SUCCESS: {
    TICKET_CREATED: 'Ticket creado exitosamente',
    PAYMENT_PROCESSED: 'Pago procesado correctamente',
    EMAIL_SENT: 'Email enviado',
    ACCOUNT_CREATED: 'Cuenta creada exitosamente'
  }
} as const;