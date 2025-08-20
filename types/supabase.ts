export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.4"
  }
  public: {
    Tables: {
      bank_details: {
        Row: {
          account_holder_name: string
          account_number: string
          account_type: Database["public"]["Enums"]["account_type_enum"]
          additional_banking_info: Json | null
          bank_code: string | null
          bank_name: string
          branch_code: string | null
          country_id: string
          created_at: string | null
          document_number: string
          document_type: Database["public"]["Enums"]["document_type_enum"]
          id: string
          is_active: boolean | null
          is_verified: boolean | null
          profile_id: string
          routing_number: string | null
          swift_code: string | null
          updated_at: string | null
          verification_date: string | null
        }
        Insert: {
          account_holder_name: string
          account_number: string
          account_type?: Database["public"]["Enums"]["account_type_enum"]
          additional_banking_info?: Json | null
          bank_code?: string | null
          bank_name: string
          branch_code?: string | null
          country_id: string
          created_at?: string | null
          document_number: string
          document_type: Database["public"]["Enums"]["document_type_enum"]
          id?: string
          is_active?: boolean | null
          is_verified?: boolean | null
          profile_id: string
          routing_number?: string | null
          swift_code?: string | null
          updated_at?: string | null
          verification_date?: string | null
        }
        Update: {
          account_holder_name?: string
          account_number?: string
          account_type?: Database["public"]["Enums"]["account_type_enum"]
          additional_banking_info?: Json | null
          bank_code?: string | null
          bank_name?: string
          branch_code?: string | null
          country_id?: string
          created_at?: string | null
          document_number?: string
          document_type?: Database["public"]["Enums"]["document_type_enum"]
          id?: string
          is_active?: boolean | null
          is_verified?: boolean | null
          profile_id?: string
          routing_number?: string | null
          swift_code?: string | null
          updated_at?: string | null
          verification_date?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "bank_details_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "bank_details_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      countries: {
        Row: {
          code: string
          created_at: string | null
          default_currency_id: string | null
          id: string
          is_active: boolean | null
          name: string
          phone_prefix: string
          updated_at: string | null
        }
        Insert: {
          code: string
          created_at?: string | null
          default_currency_id?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          phone_prefix: string
          updated_at?: string | null
        }
        Update: {
          code?: string
          created_at?: string | null
          default_currency_id?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          phone_prefix?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "countries_default_currency_id_fkey"
            columns: ["default_currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
        ]
      }
      currencies: {
        Row: {
          code: string
          created_at: string | null
          decimal_places: number | null
          id: string
          is_active: boolean | null
          name: Json
          symbol: string
          updated_at: string | null
        }
        Insert: {
          code: string
          created_at?: string | null
          decimal_places?: number | null
          id?: string
          is_active?: boolean | null
          name: Json
          symbol: string
          updated_at?: string | null
        }
        Update: {
          code?: string
          created_at?: string | null
          decimal_places?: number | null
          id?: string
          is_active?: boolean | null
          name?: Json
          symbol?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      discount_codes: {
        Row: {
          amount: number
          code: string
          created_at: string | null
          discount_code_type: Database["public"]["Enums"]["discount_code_type"]
          end_time: string
          event_id: string
          id: string
          max_usage: number
          quantity: number
          start_time: string
          status: boolean | null
          updated_at: string | null
        }
        Insert: {
          amount: number
          code: string
          created_at?: string | null
          discount_code_type: Database["public"]["Enums"]["discount_code_type"]
          end_time: string
          event_id: string
          id?: string
          max_usage?: number
          quantity?: number
          start_time: string
          status?: boolean | null
          updated_at?: string | null
        }
        Update: {
          amount?: number
          code?: string
          created_at?: string | null
          discount_code_type?: Database["public"]["Enums"]["discount_code_type"]
          end_time?: string
          event_id?: string
          id?: string
          max_usage?: number
          quantity?: number
          start_time?: string
          status?: boolean | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "discount_codes_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      events: {
        Row: {
          add_calendar: boolean | null
          calendar_description: string | null
          category: Json | null
          checkout_time: number | null
          created_at: string | null
          description: string | null
          end_date: string | null
          event_date: string
          event_type: Json | null
          frequency: Database["public"]["Enums"]["frequency_type"] | null
          id: string
          keywords: Json | null
          max_tickets: number | null
          min_tickets: number | null
          name: string
          primary_color: string | null
          privacy: Database["public"]["Enums"]["privacy_type"] | null
          short_description: string | null
          status: Database["public"]["Enums"]["event_status_type"] | null
          theme_mode: Database["public"]["Enums"]["theme_mode_type"] | null
          tickets_left: boolean | null
          timezone: string | null
          updated_at: string | null
        }
        Insert: {
          add_calendar?: boolean | null
          calendar_description?: string | null
          category?: Json | null
          checkout_time?: number | null
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          event_date: string
          event_type?: Json | null
          frequency?: Database["public"]["Enums"]["frequency_type"] | null
          id?: string
          keywords?: Json | null
          max_tickets?: number | null
          min_tickets?: number | null
          name: string
          primary_color?: string | null
          privacy?: Database["public"]["Enums"]["privacy_type"] | null
          short_description?: string | null
          status?: Database["public"]["Enums"]["event_status_type"] | null
          theme_mode?: Database["public"]["Enums"]["theme_mode_type"] | null
          tickets_left?: boolean | null
          timezone?: string | null
          updated_at?: string | null
        }
        Update: {
          add_calendar?: boolean | null
          calendar_description?: string | null
          category?: Json | null
          checkout_time?: number | null
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          event_date?: string
          event_type?: Json | null
          frequency?: Database["public"]["Enums"]["frequency_type"] | null
          id?: string
          keywords?: Json | null
          max_tickets?: number | null
          min_tickets?: number | null
          name?: string
          primary_color?: string | null
          privacy?: Database["public"]["Enums"]["privacy_type"] | null
          short_description?: string | null
          status?: Database["public"]["Enums"]["event_status_type"] | null
          theme_mode?: Database["public"]["Enums"]["theme_mode_type"] | null
          tickets_left?: boolean | null
          timezone?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      events_accessibility: {
        Row: {
          accessible_parking: string | null
          after_entry_instructions: string | null
          contact_email: string | null
          contact_name: string | null
          contact_number: string | null
          contact_prefix: string | null
          created_at: string | null
          entry_instructions: string | null
          event_id: string
          extra_information: Json | null
          features: Json | null
          hazards_information: string | null
          id: string
          toilet_directions: string | null
          updated_at: string | null
        }
        Insert: {
          accessible_parking?: string | null
          after_entry_instructions?: string | null
          contact_email?: string | null
          contact_name?: string | null
          contact_number?: string | null
          contact_prefix?: string | null
          created_at?: string | null
          entry_instructions?: string | null
          event_id: string
          extra_information?: Json | null
          features?: Json | null
          hazards_information?: string | null
          id?: string
          toilet_directions?: string | null
          updated_at?: string | null
        }
        Update: {
          accessible_parking?: string | null
          after_entry_instructions?: string | null
          contact_email?: string | null
          contact_name?: string | null
          contact_number?: string | null
          contact_prefix?: string | null
          created_at?: string | null
          entry_instructions?: string | null
          event_id?: string
          extra_information?: Json | null
          features?: Json | null
          hazards_information?: string | null
          id?: string
          toilet_directions?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "events_accessibility_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: true
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          company_id: string | null
          company_name: string | null
          created_at: string | null
          email: string
          id: string
          last_name: string
          name: string
          phone: string | null
          prefix: string | null
          updated_at: string | null
        }
        Insert: {
          company_id?: string | null
          company_name?: string | null
          created_at?: string | null
          email: string
          id?: string
          last_name: string
          name: string
          phone?: string | null
          prefix?: string | null
          updated_at?: string | null
        }
        Update: {
          company_id?: string | null
          company_name?: string | null
          created_at?: string | null
          email?: string
          id?: string
          last_name?: string
          name?: string
          phone?: string | null
          prefix?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      account_type_enum: "savings" | "checking" | "business" | "other"
      discount_code_type: "percentage" | "fixed_amount"
      document_type_enum:
        | "CC"
        | "CE"
        | "DNI"
        | "RUT"
        | "RFC"
        | "CPF"
        | "PASSPORT"
        | "OTHER"
      event_status_type:
        | "draft"
        | "active"
        | "inactive"
        | "sold_out"
        | "cancelled"
      frequency_type: "single" | "recurring"
      privacy_type: "public" | "private"
      theme_mode_type: "light" | "dark" | "adaptive"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      account_type_enum: ["savings", "checking", "business", "other"],
      discount_code_type: ["percentage", "fixed_amount"],
      document_type_enum: [
        "CC",
        "CE",
        "DNI",
        "RUT",
        "RFC",
        "CPF",
        "PASSPORT",
        "OTHER",
      ],
      event_status_type: [
        "draft",
        "active",
        "inactive",
        "sold_out",
        "cancelled",
      ],
      frequency_type: ["single", "recurring"],
      privacy_type: ["public", "private"],
      theme_mode_type: ["light", "dark", "adaptive"],
    },
  },
} as const
