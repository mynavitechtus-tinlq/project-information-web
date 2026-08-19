export type ApiResponse<T = unknown, M = PaginationMeta> = {
  success?: boolean;
  data?: T;
  message?: string;
  error_code?: string;
  errors?: Record<string, string[]>;
  meta: M;
  raw: Response;
};

export type PaginationRequest = {
  page: number;
  limit?: number;
};

export type PaginationMeta = {
  page: number;
  per_page: number;
  total: number;
  total_pages: number;
};
