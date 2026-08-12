export type Company = {
  id: string;
  name: string;
  plan: string;
  licenses_total: number;
  licenses_used: number;
  created_at: string;
  updated_at: string;
};

export type Profile = {
  id: string;
  company_id: string | null;
  full_name: string | null;
  role: "gestor" | "colaborador" | string;
  avatar_url: string | null;
  created_at: string;
  updated_at: string;
};

export type ProfileWithCompany = Profile & {
  company: Company | null;
};

export type ApplicationStatus = "draft" | "active" | "closed";

export type ResponseStatus = "started" | "completed" | "abandoned";

export type Response = {
  id: string;
  application_id: string;
  name: string;
  role: string;
  status: ResponseStatus;
  progress: number;
  current_question: number;
  started_at: string;
  completed_at: string | null;
  created_at: string;
};

export type Pillar = {
  id: string;
  number: number;
  name: string;
  description: string | null;
  active: boolean;
  created_at: string;
};

export type Indicator = {
  id: string;
  code: string;
  name: string;
  description: string | null;
  pillar_number: number;
  active: boolean;
  created_at: string;
};

export type AlternativeIndicator = {
  id: string;
  alternative_id: string;
  indicator_id: string;
  evidence_strength: 0 | 1 | 2 | 3;
  created_at: string;
};

// -----------------------------------------------------------
// Motor de Interpretação — Dimensões complementares (Sprint 09)
// -----------------------------------------------------------

export type EvidenceStrength = 0 | 1 | 2 | 3;

export type DiscProfile = {
  id: string;
  code: "D" | "I" | "S" | "C" | string;
  name: string;
  description: string | null;
  active: boolean;
  created_at: string;
};

export type PsychologicalType = {
  id: string;
  code: "EST" | "IDE" | "GUA" | "ART" | string;
  name: string;
  description: string | null;
  active: boolean;
  created_at: string;
};

export type Motivator = {
  id: string;
  code: string;
  name: string;
  description: string | null;
  active: boolean;
  created_at: string;
};

export type OperationalStyle = {
  id: string;
  code: "EXE" | "PLA" | "ANA" | "COL" | string;
  name: string;
  description: string | null;
  active: boolean;
  created_at: string;
};

export type AlternativeDisc = {
  id: string;
  alternative_id: string;
  disc_id: string;
  evidence_strength: EvidenceStrength;
  created_at: string;
};

export type AlternativePsychologicalType = {
  id: string;
  alternative_id: string;
  psychological_type_id: string;
  evidence_strength: EvidenceStrength;
  created_at: string;
};

export type AlternativeMotivator = {
  id: string;
  alternative_id: string;
  motivator_id: string;
  evidence_strength: EvidenceStrength;
  created_at: string;
};

export type AlternativeOperationalStyle = {
  id: string;
  alternative_id: string;
  operational_style_id: string;
  evidence_strength: EvidenceStrength;
  created_at: string;
};

export type Question = {
  id: string;
  order_index: number;
  pillar_number: number | null;
  title: string;
  dimension: string | null;
  active: boolean;
  created_at: string;
};

export type Alternative = {
  id: string;
  question_id: string;
  order_index: number;
  letter: string | null;
  title: string;
  description: string | null;
  created_at: string;
};

export type Answer = {
  id: string;
  response_id: string;
  question_id: string;
  alternative_id: string;
  answered_at: string;
  created_at: string;
};

export type Application = {
  id: string;
  company_id: string;
  name: string;
  token: string;
  status: ApplicationStatus;
  license_limit: number;
  responses_count: number;
  created_at: string;
  updated_at: string;
};
