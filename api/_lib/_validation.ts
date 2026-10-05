import { ApiError } from './_errors.js';

export async function readJsonBody<T>(request: Request, maxBytes: number): Promise<T> {
  const contentLength = Number(request.headers.get('content-length') ?? 0);
  if (Number.isFinite(contentLength) && contentLength > maxBytes) {
    throw new ApiError(413, 'payload_too_large');
  }

  const reader = request.body?.getReader();
  if (!reader) throw new ApiError(400, 'invalid_json');
  const chunks: Uint8Array[] = [];
  let byteLength = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      byteLength += value.byteLength;
      if (byteLength > maxBytes) {
        await reader.cancel();
        throw new ApiError(413, 'payload_too_large');
      }
      chunks.push(value);
    }
    const content = new Uint8Array(byteLength);
    let offset = 0;
    for (const chunk of chunks) {
      content.set(chunk, offset);
      offset += chunk.byteLength;
    }
    const text = new TextDecoder('utf-8', { fatal: true }).decode(content);
    return JSON.parse(text) as T;
  } catch (error) {
    if (error instanceof ApiError) throw error;
    throw new ApiError(400, 'invalid_json');
  }
}

export function requireTrustedOrigin(request: Request, trustedOrigin: string): void {
  const origin = request.headers.get('origin');
  if (!origin || origin !== trustedOrigin) throw new ApiError(403, 'origin_not_allowed');
}

export function requireSameOriginUrl(request: Request, trustedOrigin: string): void {
  if (new URL(request.url).origin !== trustedOrigin) {
    throw new ApiError(403, 'origin_not_allowed');
  }
}
