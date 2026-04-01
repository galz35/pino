import { useEffect, useState } from 'react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { RefreshCw } from 'lucide-react';

export function NetworkStatusIndicator() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return (
    <div className="flex items-center gap-2 text-xs font-medium">
      <span
        className={cn(
          'h-2 w-2 rounded-full',
          isOnline ? 'bg-green-500' : 'bg-red-500'
        )}
      />
      <span className={cn(
        isOnline ? 'text-green-700 dark:text-green-400' : 'text-red-700 dark:text-red-400'
      )}>
        {isOnline ? 'En Línea' : 'Sin Conexión'}
      </span>
    </div>
  );
}
