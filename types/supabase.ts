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
      account: {
        Row: {
          access_token: string | null
          access_token_expires_at: string | null
          account_id: string
          created_at: string
          id: string
          id_token: string | null
          password: string | null
          provider_id: string
          refresh_token: string | null
          refresh_token_expires_at: string | null
          scope: string | null
          updated_at: string
          user_id: string
        }
        Insert: {
          access_token?: string | null
          access_token_expires_at?: string | null
          account_id: string
          created_at: string
          id: string
          id_token?: string | null
          password?: string | null
          provider_id: string
          refresh_token?: string | null
          refresh_token_expires_at?: string | null
          scope?: string | null
          updated_at: string
          user_id: string
        }
        Update: {
          access_token?: string | null
          access_token_expires_at?: string | null
          account_id?: string
          created_at?: string
          id?: string
          id_token?: string | null
          password?: string | null
          provider_id?: string
          refresh_token?: string | null
          refresh_token_expires_at?: string | null
          scope?: string | null
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "account_user_id_user_id_fk"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "user"
            referencedColumns: ["id"]
          },
        ]
      }
      automatic_discounts: {
        Row: {
          amount: number
          applies_to: Json | null
          automatic_type: string
          created_at: string | null
          discount_type: Database["public"]["Enums"]["discount_code_type"]
          end_at: string
          event_id: string
          filter: Json | null
          id: string
          max_usage: number | null
          name: string
          quantity: number | null
          start_at: string
          status: boolean | null
          updated_at: string | null
        }
        Insert: {
          amount: number
          applies_to?: Json | null
          automatic_type: string
          created_at?: string | null
          discount_type: Database["public"]["Enums"]["discount_code_type"]
          end_at: string
          event_id: string
          filter?: Json | null
          id?: string
          max_usage?: number | null
          name: string
          quantity?: number | null
          start_at: string
          status?: boolean | null
          updated_at?: string | null
        }
        Update: {
          amount?: number
          applies_to?: Json | null
          automatic_type?: string
          created_at?: string | null
          discount_type?: Database["public"]["Enums"]["discount_code_type"]
          end_at?: string
          event_id?: string
          filter?: Json | null
          id?: string
          max_usage?: number | null
          name?: string
          quantity?: number | null
          start_at?: string
          status?: boolean | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "automatic_discounts_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      bank_details: {
        Row: {
          account_holder_name: string
          account_number: string
          account_type: Database["public"]["Enums"]["account_type_enum"]
          additional_banking_info: Json | null
          bank_name: string
          country_id: string
          created_at: string | null
          document_number: string
          document_type: Database["public"]["Enums"]["document_type_enum"]
          id: string
          profile_id: string
          updated_at: string | null
        }
        Insert: {
          account_holder_name: string
          account_number: string
          account_type?: Database["public"]["Enums"]["account_type_enum"]
          additional_banking_info?: Json | null
          bank_name: string
          country_id: string
          created_at?: string | null
          document_number: string
          document_type: Database["public"]["Enums"]["document_type_enum"]
          id?: string
          profile_id: string
          updated_at?: string | null
        }
        Update: {
          account_holder_name?: string
          account_number?: string
          account_type?: Database["public"]["Enums"]["account_type_enum"]
          additional_banking_info?: Json | null
          bank_name?: string
          country_id?: string
          created_at?: string | null
          document_number?: string
          document_type?: Database["public"]["Enums"]["document_type_enum"]
          id?: string
          profile_id?: string
          updated_at?: string | null
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
          privacy_policy_url: string | null
          refund_policy_url: string | null
          support_email: string | null
          terms_of_service_url: string | null
          updated_at: string | null
          whatsapp_support_phone: string | null
        }
        Insert: {
          code: string
          created_at?: string | null
          default_currency_id?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          phone_prefix: string
          privacy_policy_url?: string | null
          refund_policy_url?: string | null
          support_email?: string | null
          terms_of_service_url?: string | null
          updated_at?: string | null
          whatsapp_support_phone?: string | null
        }
        Update: {
          code?: string
          created_at?: string | null
          default_currency_id?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          phone_prefix?: string
          privacy_policy_url?: string | null
          refund_policy_url?: string | null
          support_email?: string | null
          terms_of_service_url?: string | null
          updated_at?: string | null
          whatsapp_support_phone?: string | null
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
          applies_to: Json | null
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
          applies_to?: Json | null
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
          applies_to?: Json | null
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
          confirmation_email: string | null
          confirmation_page: string | null
          created_at: string | null
          description: string | null
          end_date: string | null
          event_date: string
          event_type: Json | null
          frequency: Database["public"]["Enums"]["frequency_type"] | null
          id: string
          keywords: Json | null
          language: Database["public"]["Enums"]["language_type"] | null
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
          confirmation_email?: string | null
          confirmation_page?: string | null
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          event_date: string
          event_type?: Json | null
          frequency?: Database["public"]["Enums"]["frequency_type"] | null
          id?: string
          keywords?: Json | null
          language?: Database["public"]["Enums"]["language_type"] | null
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
          confirmation_email?: string | null
          confirmation_page?: string | null
          created_at?: string | null
          description?: string | null
          end_date?: string | null
          event_date?: string
          event_type?: Json | null
          frequency?: Database["public"]["Enums"]["frequency_type"] | null
          id?: string
          keywords?: Json | null
          language?: Database["public"]["Enums"]["language_type"] | null
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
      events_access_code: {
        Row: {
          applies_to: Json | null
          code: string
          created_at: string | null
          event_id: string
          id: string
          quantity: number | null
          status: boolean | null
          updated_at: string | null
        }
        Insert: {
          applies_to?: Json | null
          code: string
          created_at?: string | null
          event_id: string
          id?: string
          quantity?: number | null
          status?: boolean | null
          updated_at?: string | null
        }
        Update: {
          applies_to?: Json | null
          code?: string
          created_at?: string | null
          event_id?: string
          id?: string
          quantity?: number | null
          status?: boolean | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "events_access_code_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
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
      events_adjustments: {
        Row: {
          adjustment_type: Database["public"]["Enums"]["adjustment_type"]
          amount: number
          created_at: string | null
          currency_id: string
          date: string
          event_id: string
          id: string
          updated_at: string | null
        }
        Insert: {
          adjustment_type: Database["public"]["Enums"]["adjustment_type"]
          amount: number
          created_at?: string | null
          currency_id: string
          date: string
          event_id: string
          id?: string
          updated_at?: string | null
        }
        Update: {
          adjustment_type?: Database["public"]["Enums"]["adjustment_type"]
          amount?: number
          created_at?: string | null
          currency_id?: string
          date?: string
          event_id?: string
          id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "events_adjustments_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "events_adjustments_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      events_affiliates: {
        Row: {
          code: string
          created_at: string | null
          discount_codes: Json | null
          event_id: string
          id: string
          status: boolean | null
          updated_at: string | null
          url: string
        }
        Insert: {
          code: string
          created_at?: string | null
          discount_codes?: Json | null
          event_id: string
          id?: string
          status?: boolean | null
          updated_at?: string | null
          url: string
        }
        Update: {
          code?: string
          created_at?: string | null
          discount_codes?: Json | null
          event_id?: string
          id?: string
          status?: boolean | null
          updated_at?: string | null
          url?: string
        }
        Relationships: [
          {
            foreignKeyName: "events_affiliates_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      events_checkout_questions: {
        Row: {
          applies_to: Json | null
          created_at: string | null
          event_id: string
          id: string
          is_active: boolean | null
          is_required: boolean | null
          options: Json | null
          order_index: number
          placeholder: Json | null
          question_text: Json
          question_type_id: string
          updated_at: string | null
        }
        Insert: {
          applies_to?: Json | null
          created_at?: string | null
          event_id: string
          id?: string
          is_active?: boolean | null
          is_required?: boolean | null
          options?: Json | null
          order_index?: number
          placeholder?: Json | null
          question_text: Json
          question_type_id: string
          updated_at?: string | null
        }
        Update: {
          applies_to?: Json | null
          created_at?: string | null
          event_id?: string
          id?: string
          is_active?: boolean | null
          is_required?: boolean | null
          options?: Json | null
          order_index?: number
          placeholder?: Json | null
          question_text?: Json
          question_type_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "events_checkout_questions_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "events_checkout_questions_question_type_id_fkey"
            columns: ["question_type_id"]
            isOneToOne: false
            referencedRelation: "question_types"
            referencedColumns: ["id"]
          },
        ]
      }
      events_payment_settings: {
        Row: {
          created_at: string | null
          event_id: string
          fee_payment: Database["public"]["Enums"]["fee_payment_type"] | null
          fixed_fee: number | null
          id: string
          refund_policy: string | null
          refundable_amount: number | null
          self_refund: boolean | null
          tax: boolean | null
          updated_at: string | null
          variable_fee: number | null
        }
        Insert: {
          created_at?: string | null
          event_id: string
          fee_payment?: Database["public"]["Enums"]["fee_payment_type"] | null
          fixed_fee?: number | null
          id?: string
          refund_policy?: string | null
          refundable_amount?: number | null
          self_refund?: boolean | null
          tax?: boolean | null
          updated_at?: string | null
          variable_fee?: number | null
        }
        Update: {
          created_at?: string | null
          event_id?: string
          fee_payment?: Database["public"]["Enums"]["fee_payment_type"] | null
          fixed_fee?: number | null
          id?: string
          refund_policy?: string | null
          refundable_amount?: number | null
          self_refund?: boolean | null
          tax?: boolean | null
          updated_at?: string | null
          variable_fee?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "events_payment_settings_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: true
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      events_payments: {
        Row: {
          amount: number
          bank_id: string
          created_at: string | null
          currency_id: string
          event_id: string
          id: string
          payment_date: string
          reference: string
          updated_at: string | null
        }
        Insert: {
          amount: number
          bank_id: string
          created_at?: string | null
          currency_id: string
          event_id: string
          id?: string
          payment_date: string
          reference: string
          updated_at?: string | null
        }
        Update: {
          amount?: number
          bank_id?: string
          created_at?: string | null
          currency_id?: string
          event_id?: string
          id?: string
          payment_date?: string
          reference?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "events_payments_bank_id_fkey"
            columns: ["bank_id"]
            isOneToOne: false
            referencedRelation: "bank_details"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "events_payments_currency_id_fkey"
            columns: ["currency_id"]
            isOneToOne: false
            referencedRelation: "currencies"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "events_payments_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: false
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      events_waitlist: {
        Row: {
          applies_to: Json | null
          created_at: string | null
          event_id: string
          id: string
          max_capacity: number | null
          status: boolean | null
          ticket_trigger:
            | Database["public"]["Enums"]["ticket_trigger_type"]
            | null
          tickets_sold_out: boolean | null
          total_capacity: boolean | null
          updated_at: string | null
        }
        Insert: {
          applies_to?: Json | null
          created_at?: string | null
          event_id: string
          id?: string
          max_capacity?: number | null
          status?: boolean | null
          ticket_trigger?:
            | Database["public"]["Enums"]["ticket_trigger_type"]
            | null
          tickets_sold_out?: boolean | null
          total_capacity?: boolean | null
          updated_at?: string | null
        }
        Update: {
          applies_to?: Json | null
          created_at?: string | null
          event_id?: string
          id?: string
          max_capacity?: number | null
          status?: boolean | null
          ticket_trigger?:
            | Database["public"]["Enums"]["ticket_trigger_type"]
            | null
          tickets_sold_out?: boolean | null
          total_capacity?: boolean | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "events_waitlist_event_id_fkey"
            columns: ["event_id"]
            isOneToOne: true
            referencedRelation: "events"
            referencedColumns: ["id"]
          },
        ]
      }
      invoices: {
        Row: {
          company_name: string
          created_at: string
          currency: string
          description: string | null
          id: string
          invoice_to: string
          metadata: Json | null
          paid_at: string | null
          payment_method: string | null
          subtotal: number
          tax: number
          total: number
          updated_at: string
        }
        Insert: {
          company_name: string
          created_at?: string
          currency?: string
          description?: string | null
          id?: string
          invoice_to: string
          metadata?: Json | null
          paid_at?: string | null
          payment_method?: string | null
          subtotal: number
          tax?: number
          total: number
          updated_at?: string
        }
        Update: {
          company_name?: string
          created_at?: string
          currency?: string
          description?: string | null
          id?: string
          invoice_to?: string
          metadata?: Json | null
          paid_at?: string | null
          payment_method?: string | null
          subtotal?: number
          tax?: number
          total?: number
          updated_at?: string
        }
        Relationships: []
      }
      passkey: {
        Row: {
          aaguid: string | null
          backed_up: boolean
          counter: number
          created_at: string
          credential_i_d: string
          device_type: string
          id: string
          name: string | null
          public_key: string
          transports: string | null
          user_id: string
        }
        Insert: {
          aaguid?: string | null
          backed_up: boolean
          counter: number
          created_at: string
          credential_i_d: string
          device_type: string
          id: string
          name?: string | null
          public_key: string
          transports?: string | null
          user_id: string
        }
        Update: {
          aaguid?: string | null
          backed_up?: boolean
          counter?: number
          created_at?: string
          credential_i_d?: string
          device_type?: string
          id?: string
          name?: string | null
          public_key?: string
          transports?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "passkey_user_id_user_id_fk"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "user"
            referencedColumns: ["id"]
          },
        ]
      }
      producers: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          metadata: Json | null
          name: string
          soundcloud: string | null
          spotify: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          metadata?: Json | null
          name: string
          soundcloud?: string | null
          spotify?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          metadata?: Json | null
          name?: string
          soundcloud?: string | null
          spotify?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      producers_social_media: {
        Row: {
          created_at: string | null
          facebook: string | null
          id: string
          instagram: string | null
          linkedin: string | null
          producer_id: string
          tiktok: string | null
          twitter: string | null
          updated_at: string | null
          website: string | null
          x: string | null
          youtube: string | null
        }
        Insert: {
          created_at?: string | null
          facebook?: string | null
          id?: string
          instagram?: string | null
          linkedin?: string | null
          producer_id: string
          tiktok?: string | null
          twitter?: string | null
          updated_at?: string | null
          website?: string | null
          x?: string | null
          youtube?: string | null
        }
        Update: {
          created_at?: string | null
          facebook?: string | null
          id?: string
          instagram?: string | null
          linkedin?: string | null
          producer_id?: string
          tiktok?: string | null
          twitter?: string | null
          updated_at?: string | null
          website?: string | null
          x?: string | null
          youtube?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "producers_social_media_producer_id_fkey"
            columns: ["producer_id"]
            isOneToOne: false
            referencedRelation: "producers"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          birthdate: string | null
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
          birthdate?: string | null
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
          birthdate?: string | null
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
      question_types: {
        Row: {
          created_at: string | null
          display_name: Json
          id: string
          is_active: boolean | null
          name: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          display_name: Json
          id?: string
          is_active?: boolean | null
          name: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          display_name?: Json
          id?: string
          is_active?: boolean | null
          name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      refunds: {
        Row: {
          case_number: string
          created_at: string
          description: string | null
          email: string
          id: string
          name: string
          order_id: string
          payment_method: Json | null
          status: Database["public"]["Enums"]["refund_status"]
          updated_at: string
        }
        Insert: {
          case_number: string
          created_at?: string
          description?: string | null
          email: string
          id?: string
          name: string
          order_id: string
          payment_method?: Json | null
          status?: Database["public"]["Enums"]["refund_status"]
          updated_at?: string
        }
        Update: {
          case_number?: string
          created_at?: string
          description?: string | null
          email?: string
          id?: string
          name?: string
          order_id?: string
          payment_method?: Json | null
          status?: Database["public"]["Enums"]["refund_status"]
          updated_at?: string
        }
        Relationships: []
      }
      session: {
        Row: {
          created_at: string
          expires_at: string
          id: string
          ip_address: string | null
          token: string
          updated_at: string
          user_agent: string | null
          user_id: string
        }
        Insert: {
          created_at: string
          expires_at: string
          id: string
          ip_address?: string | null
          token: string
          updated_at: string
          user_agent?: string | null
          user_id: string
        }
        Update: {
          created_at?: string
          expires_at?: string
          id?: string
          ip_address?: string | null
          token?: string
          updated_at?: string
          user_agent?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "session_user_id_user_id_fk"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "user"
            referencedColumns: ["id"]
          },
        ]
      }
      subscriptions: {
        Row: {
          amount: number
          company: string
          created_at: string
          currency: string
          date: string
          id: string
          metadata: Json | null
          payment_method: string
          receipt_name: string
          service: string
        }
        Insert: {
          amount: number
          company: string
          created_at?: string
          currency: string
          date: string
          id?: string
          metadata?: Json | null
          payment_method: string
          receipt_name: string
          service: string
        }
        Update: {
          amount?: number
          company?: string
          created_at?: string
          currency?: string
          date?: string
          id?: string
          metadata?: Json | null
          payment_method?: string
          receipt_name?: string
          service?: string
        }
        Relationships: []
      }
      user: {
        Row: {
          created_at: string
          email: string
          email_verified: boolean
          id: string
          image: string | null
          is_anonymous: boolean | null
          name: string
          phonenumber: string | null
          phonenumberverified: boolean | null
          updated_at: string
        }
        Insert: {
          created_at: string
          email: string
          email_verified: boolean
          id: string
          image?: string | null
          is_anonymous?: boolean | null
          name: string
          phonenumber?: string | null
          phonenumberverified?: boolean | null
          updated_at: string
        }
        Update: {
          created_at?: string
          email?: string
          email_verified?: boolean
          id?: string
          image?: string | null
          is_anonymous?: boolean | null
          name?: string
          phonenumber?: string | null
          phonenumberverified?: boolean | null
          updated_at?: string
        }
        Relationships: []
      }
      verification: {
        Row: {
          created_at: string | null
          expires_at: string
          id: string
          identifier: string
          updated_at: string | null
          value: string
        }
        Insert: {
          created_at?: string | null
          expires_at: string
          id: string
          identifier: string
          updated_at?: string | null
          value: string
        }
        Update: {
          created_at?: string | null
          expires_at?: string
          id?: string
          identifier?: string
          updated_at?: string | null
          value?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      debug_current_role: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
      delete_orphaned_invoice: {
        Args: { invoice_uuid: string }
        Returns: boolean
      }
      generate_case_number: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
    }
    Enums: {
      account_type_enum: "savings" | "checking" | "business" | "other"
      adjustment_type:
        | "debit"
        | "credit"
        | "refund"
        | "fee"
        | "penalty"
        | "bonus"
      discount_code_type: "percentage" | "fixed_amount"
      discount_type: "percentage" | "fixed_amount" | "free"
      document_type_enum:
        | "CC"
        | "CE"
        | "DNI"
        | "RUT"
        | "RFC"
        | "CPF"
        | "PASSPORT"
        | "OTHER"
      event_language: "en" | "es" | "fr" | "pt" | "it" | "de"
      event_status: "draft" | "published" | "cancelled" | "completed"
      event_status_type:
        | "draft"
        | "active"
        | "inactive"
        | "sold_out"
        | "cancelled"
      fee_payment_type: "absorver_fees" | "dividir_fee" | "pasar_fees"
      frequency_type: "single" | "recurring"
      language_type: "es" | "en" | "pt" | "fr"
      payment_status:
        | "pending"
        | "processing"
        | "succeeded"
        | "failed"
        | "cancelled"
        | "refunded"
      privacy_type: "public" | "private"
      refund_status: "pending" | "accepted" | "rejected"
      theme_mode_type: "light" | "dark" | "adaptive"
      ticket_trigger_type: "automatic" | "manually"
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
      adjustment_type: ["debit", "credit", "refund", "fee", "penalty", "bonus"],
      discount_code_type: ["percentage", "fixed_amount"],
      discount_type: ["percentage", "fixed_amount", "free"],
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
      event_language: ["en", "es", "fr", "pt", "it", "de"],
      event_status: ["draft", "published", "cancelled", "completed"],
      event_status_type: [
        "draft",
        "active",
        "inactive",
        "sold_out",
        "cancelled",
      ],
      fee_payment_type: ["absorver_fees", "dividir_fee", "pasar_fees"],
      frequency_type: ["single", "recurring"],
      language_type: ["es", "en", "pt", "fr"],
      payment_status: [
        "pending",
        "processing",
        "succeeded",
        "failed",
        "cancelled",
        "refunded",
      ],
      privacy_type: ["public", "private"],
      refund_status: ["pending", "accepted", "rejected"],
      theme_mode_type: ["light", "dark", "adaptive"],
      ticket_trigger_type: ["automatic", "manually"],
    },
  },
} as const
