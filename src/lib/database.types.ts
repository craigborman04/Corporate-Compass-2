export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type UserRole = 'owner' | 'administrator' | 'director' | 'manager'
export type UserStatus = 'active' | 'inactive'
export type GoalStatus = 'Not Started' | 'In Progress' | 'Completed' | 'Needs Review' | 'Archived'
export type ReviewStatus = 'Submitted' | 'Acknowledged'
export type ReportStatus = 'pending' | 'approved' | 'rejected'

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          uid: string
          email: string
          first_name: string
          last_name: string
          display_name: string
          position: string
          role: UserRole
          holding_company_id: string | null
          subsidiary_ids: string[]
          division_ids: string[]
          manager_setup_complete: boolean
          status: UserStatus
          created_at: string
          updated_at: string
        }
        Insert: {
          uid?: string
          email: string
          first_name: string
          last_name: string
          display_name: string
          position: string
          role?: UserRole
          holding_company_id?: string | null
          subsidiary_ids?: string[]
          division_ids?: string[]
          manager_setup_complete?: boolean
          status?: UserStatus
          created_at?: string
          updated_at?: string
        }
        Update: {
          uid?: string
          email?: string
          first_name?: string
          last_name?: string
          display_name?: string
          position?: string
          role?: UserRole
          holding_company_id?: string | null
          subsidiary_ids?: string[]
          division_ids?: string[]
          manager_setup_complete?: boolean
          status?: UserStatus
          created_at?: string
          updated_at?: string
        }
      }
      holding_companies: {
        Row: {
          id: string
          name: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          created_at?: string
          updated_at?: string
        }
      }
      subsidiaries: {
        Row: {
          id: string
          name: string
          holding_company_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          holding_company_id: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          holding_company_id?: string
          created_at?: string
          updated_at?: string
        }
      }
      divisions: {
        Row: {
          id: string
          name: string
          subsidiary_id: string
          strategic_plan: string | null
          start_date: string
          end_date: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          subsidiary_id: string
          strategic_plan?: string | null
          start_date: string
          end_date?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          subsidiary_id?: string
          strategic_plan?: string | null
          start_date?: string
          end_date?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      goals: {
        Row: {
          id: string
          user_id: string
          title: string
          description: string | null
          status: GoalStatus
          target_completion_date: string | null
          related_division_id: string | null
          related_subsidiary_id: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          user_id: string
          title: string
          description?: string | null
          status?: GoalStatus
          target_completion_date?: string | null
          related_division_id?: string | null
          related_subsidiary_id?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          title?: string
          description?: string | null
          status?: GoalStatus
          target_completion_date?: string | null
          related_division_id?: string | null
          related_subsidiary_id?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      reviews: {
        Row: {
          id: string
          goal_id: string
          reviewee_id: string
          reviewer_id: string
          performance_rating: number | null
          comments: string | null
          status: ReviewStatus
          submitted_at: string
        }
        Insert: {
          id?: string
          goal_id: string
          reviewee_id: string
          reviewer_id: string
          performance_rating?: number | null
          comments?: string | null
          status?: ReviewStatus
          submitted_at?: string
        }
        Update: {
          id?: string
          goal_id?: string
          reviewee_id?: string
          reviewer_id?: string
          performance_rating?: number | null
          comments?: string | null
          status?: ReviewStatus
          submitted_at?: string
        }
      }
      reports: {
        Row: {
          id: string
          division_id: string
          period: string
          content: Json | null
          status: ReportStatus
          submitted_at: string
          submitted_by: string
        }
        Insert: {
          id?: string
          division_id: string
          period: string
          content?: Json | null
          status?: ReportStatus
          submitted_at?: string
          submitted_by: string
        }
        Update: {
          id?: string
          division_id?: string
          period?: string
          content?: Json | null
          status?: ReportStatus
          submitted_at?: string
          submitted_by?: string
        }
      }
      plan_updates: {
        Row: {
          id: string
          posted_by: string
          content: string
          target_roles: UserRole[]
          acknowledged_by: string[]
          posted_at: string
        }
        Insert: {
          id?: string
          posted_by: string
          content: string
          target_roles: UserRole[]
          acknowledged_by?: string[]
          posted_at?: string
        }
        Update: {
          id?: string
          posted_by?: string
          content?: string
          target_roles?: UserRole[]
          acknowledged_by?: string[]
          posted_at?: string
        }
      }
      audit_logs: {
        Row: {
          id: string
          user_id: string | null
          action: string
          details: Json | null
          timestamp: string
        }
        Insert: {
          id?: string
          user_id?: string | null
          action: string
          details?: Json | null
          timestamp?: string
        }
        Update: {
          id?: string
          user_id?: string | null
          action?: string
          details?: Json | null
          timestamp?: string
        }
      }
    }
    Functions: {
      can_access_division: {
        Args: { division_id_param: string }
        Returns: boolean
      }
      is_owner_or_admin: {
        Args: Record<string, never>
        Returns: boolean
      }
    }
    Enums: {
      user_role: UserRole
      user_status: UserStatus
    }
  }
} 