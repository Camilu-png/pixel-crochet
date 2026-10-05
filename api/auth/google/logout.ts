import { getAuthHandlers } from '../../_lib/_handlers.js';
import { errorResponse } from '../../_lib/_errors.js';

export default {
  async fetch(request: Request): Promise<Response> {
    try {
      return await getAuthHandlers().logout(request);
    } catch (error) {
      return errorResponse(error);
    }
  },
};
