export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
  ) {
    super(code);
  }
}

export function errorResponse(error: unknown): Response {
  const apiError = error instanceof ApiError ? error : null;
  const response = Response.json(
    { error: apiError?.code ?? 'internal_error' },
    { status: apiError?.status ?? 500 },
  );
  response.headers.set('cache-control', 'no-store');
  response.headers.set('x-content-type-options', 'nosniff');
  return response;
}

export function methodNotAllowed(allowed: string): Response {
  return new Response(null, {
    status: 405,
    headers: { allow: allowed, 'cache-control': 'no-store' },
  });
}
