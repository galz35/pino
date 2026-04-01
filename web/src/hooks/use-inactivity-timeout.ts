

import { useEffect, useRef, useCallback } from 'react';
import { useAuth } from '@/context/auth-context';

export function useInactivityTimeout(onTimeout: () => void, timeout: number = 3600000) {
  const { user } = useAuth();
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);

  const resetTimer = useCallback(() => {
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }
    timeoutRef.current = setTimeout(onTimeout, timeout);
  }, [onTimeout, timeout]);

  useEffect(() => {
    if (!user) {
      // If there's no user, clear any existing timer and do nothing.
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
      return;
    }

    const events = ['mousemove', 'mousedown', 'keydown', 'scroll', 'touchstart'];

    const resetActivityTimer = () => {
      resetTimer();
    };

    // Set the initial timer when the user logs in
    resetTimer();

    // Add event listeners to reset the timer on user activity
    events.forEach(event => {
      window.addEventListener(event, resetActivityTimer);
    });

    // Cleanup function to remove event listeners and clear the timer
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
      events.forEach(event => {
        window.removeEventListener(event, resetActivityTimer);
      });
    };
  }, [user, resetTimer]); // Rerun effect if user or timeout changes
}
