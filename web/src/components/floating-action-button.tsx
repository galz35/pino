import { Plus } from 'lucide-react';
import { Link } from 'react-router-dom';
import { Button } from './ui/button';
import { cn } from '@/lib/utils';

type FloatingActionButtonProps = {
  href: string;
  className?: string;
};

export function FloatingActionButton({ href, className }: FloatingActionButtonProps) {
  return (
    <Button
      asChild
      className={cn(
        'fixed bottom-8 right-8 h-14 w-14 rounded-full shadow-lg z-50 bg-accent text-accent-foreground hover:bg-accent/90',
        className
      )}
    >
      <Link to={href}>
        <Plus className="h-6 w-6" />
        <span className="sr-only">Agregar Nuevo</span>
      </Link>
    </Button>
  );
}
