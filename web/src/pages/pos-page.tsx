import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/auth-context';
import { Loader2 } from 'lucide-react';

export default function PosPage() {
  const { user, loading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!loading) {
      if (!user) {
        navigate('/login');
        return;
      }

      // Master admins go to master dashboard
      if (user.role === 'master-admin' || user.role === 'owner') {
        navigate('/master-admin/dashboard');
        return;
      }

      // Store users go to their default store's billing
      if (user.storeIds && user.storeIds.length > 0) {
        navigate(`/store/${user.storeIds[0]}/billing`);
      } else if (user.role === 'Admin' || user.role === 'store-admin') {
         // Fallback for admins without specific storeIds array (unlikely but safe)
         navigate('/store/default/dashboard'); 
      } else {
        // No stores assigned?
        console.warn('User has no assigned stores');
      }
    }
  }, [user, loading, navigate]);

  return (
    <div className="flex h-screen items-center justify-center bg-background">
      <div className="text-center">
        <Loader2 className="animate-spin h-12 w-12 text-primary mx-auto mb-4" />
        <p className="font-black uppercase tracking-widest text-muted-foreground text-xs italic">Cargando Terminal...</p>
      </div>
    </div>
  );
}
