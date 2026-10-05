import { checkDatabaseHealth } from './_lib/_handlers.js';
import { ApiError, errorResponse, methodNotAllowed } from './_lib/_errors.js';

export default {
  async fetch(request: Request): Promise<Response> {
    if (request.method !== 'GET') return methodNotAllowed('GET');
    try {
      await checkDatabaseHealth();
      return Response.json(
        { status: 'ok' },
        { headers: { 'cache-control': 'no-store', 'x-content-type-options': 'nosniff' } },
      );
    } catch {
      return errorResponse(new ApiError(503, 'unavailable'));
    }
  },
};
