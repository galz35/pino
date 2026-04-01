import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { useNavigate } from 'react-router-dom';

interface PreloaderProps {
  message?: string;
  allowForceRedirect?: boolean;
}

export function Preloader({ message = 'Cargando...', allowForceRedirect = false }: PreloaderProps) {
  const [showForceButton, setShowForceButton] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    if (!allowForceRedirect) return;

    const timer = setTimeout(() => {
      setShowForceButton(true);
    }, 7000); // 7 seconds

    return () => clearTimeout(timer);
  }, [allowForceRedirect]);

  const handleForceRedirect = () => {
    navigate('/');
  };

  return (
    <div className="fixed inset-0 z-50 flex h-screen w-full items-center justify-center bg-background p-4">
      <div className="flex flex-col items-center gap-6 text-center">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className="h-16 w-16 animate-pulse text-primary"
        >
          <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path>
        </svg>
        <div className="space-y-2">
          <p className="text-xl font-medium">{message}</p>
          <p className="text-sm text-muted-foreground animate-pulse">
            Preparando tu espacio de trabajo...
          </p>
        </div>

        {showForceButton && (
          <div className="mt-4 flex flex-col items-center gap-3 animate-in fade-in slide-in-from-bottom-4 duration-500">
            <p className="text-sm text-destructive font-medium">
              Estamos tardando más de lo usual.
            </p>
            <Button
              variant="outline"
              onClick={handleForceRedirect}
              className="shadow-lg"
            >
              Forzar navegación al Panel
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}
