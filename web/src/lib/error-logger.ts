import apiClient from '../services/api-client';

interface ErrorContext {
  userId?: string | null;
  userEmail?: string | null;
  location: string;
  additionalInfo?: Record<string, any>;
}

export async function logError(error: any, context: ErrorContext) {
  // Log to console always
  console.error(`[Error Log] Location: ${context.location}`, {
    message: error?.message || 'Unknown error',
    code: error?.code,
    stack: error?.stack,
    context: {
      ...context,
      userAgent: typeof window !== 'undefined' ? window.navigator.userAgent : 'Server-side',
    }
  });

  // Send to NestJS /errors endpoint for centralized auditing
  try {
    await apiClient.post('/errors', {
      message: error?.message || 'Unknown error',
      stack: error?.stack || '',
      location: context.location,
      userId: context.userId || null,
      storeId: context.additionalInfo?.storeId || null,
      additionalInfo: {
        ...context.additionalInfo,
        userEmail: context.userEmail,
        userAgent: typeof window !== 'undefined' ? window.navigator.userAgent : 'N/A',
      },
    });
  } catch {
    // Silently fail — don't let the error logger itself crash the app
  }
}
