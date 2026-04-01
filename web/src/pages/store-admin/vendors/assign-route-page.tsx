import apiClient from '@/services/api-client';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { ClipboardCheck, Route } from 'lucide-react';
import { useEffect, useState, useMemo } from 'react';
import { useParams } from 'react-router-dom';
import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { Button } from '@/components/ui/button';
import { toast } from '@/lib/swalert';
import { logError } from '@/lib/error-logger';
import { Checkbox } from '@/components/ui/checkbox';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useAuth } from '@/contexts/auth-context';

interface DeliveryItem { id: string; description: string; quantity: number; salePrice: number; }
interface PendingDelivery { id: string; clientName: string; clientAddress?: string; salesManagerName: string; items: DeliveryItem[]; total: number; paymentType: string; status: string; createdAt: string; }
interface Rutero { uid: string; name: string; }

export default function AssignRoutePage() {
  const params = useParams();
  const storeId = params.storeId as string;
  const { user } = useAuth();

  const [deliveries, setDeliveries] = useState<PendingDelivery[]>([]);
  const [ruteros, setRuteros] = useState<Rutero[]>([]);
  const [selectedDeliveries, setSelectedDeliveries] = useState<Record<string, boolean>>({});
  const [selectedRutero, setSelectedRutero] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [isProcessing, setIsProcessing] = useState(false);

  useEffect(() => {
    if (!storeId) return;
    const fetchData = async () => {
      try {
        const [deliveriesRes, ruterosRes] = await Promise.all([
          apiClient.get(`/pending-deliveries?storeId=${storeId}&status=Pendiente&unassigned=true`),
          apiClient.get(`/users?storeId=${storeId}&role=Rutero`),
        ]);
        setDeliveries(deliveriesRes.data || []);
        setRuteros((ruterosRes.data || []).map((r: any) => ({ uid: r.id || r.uid, name: r.name })));
      } catch (err) {
        logError(err, { location: 'assign-route-fetch' });
        toast.error('Error', 'No se pudieron cargar los datos.');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [storeId]);

  const selectedCount = useMemo(() => Object.values(selectedDeliveries).filter(Boolean).length, [selectedDeliveries]);

  const handleAssignRoute = async () => {
    if (!selectedRutero || selectedCount === 0 || !user) {
      toast.error('Datos incompletos', 'Debes seleccionar al menos un pedido y un rutero.');
      return;
    }
    setIsProcessing(true);
    try {
      const deliveryIds = Object.entries(selectedDeliveries).filter(([, v]) => v).map(([k]) => k);
      const ruteroData = ruteros.find(r => r.uid === selectedRutero);
      await apiClient.post('/pending-deliveries/assign-route', {
        deliveryIds,
        ruteroId: selectedRutero,
        ruteroName: ruteroData?.name,
        assignedBy: user.name,
        storeId,
      });
      toast.success('Ruta Asignada', `${selectedCount} pedidos han sido asignados a ${ruteroData?.name}.`);
      setSelectedDeliveries({});
      setSelectedRutero(null);
      
      const res = await apiClient.get(`/pending-deliveries?storeId=${storeId}&status=Pendiente&unassigned=true`);
      setDeliveries(res.data || []);
    } catch (error) {
      logError(error, { location: 'assign-route-submit' });
      toast.error('Error', 'No se pudo asignar la ruta.');
    } finally {
      setIsProcessing(false);
    }
  };

  const renderContent = () => {
    if (loading) return (<div className="space-y-2">{Array.from({ length: 3 }).map((_, i) => <Skeleton key={i} className="h-20 w-full" />)}</div>);
    if (deliveries.length === 0) return (<Alert><ClipboardCheck className="h-4 w-4" /><AlertTitle>No hay pedidos por asignar</AlertTitle><AlertDescription>Todos los pedidos ya han sido asignados.</AlertDescription></Alert>);
    return (
      <div className="space-y-2">
        {deliveries.map((delivery) => (
          <div key={delivery.id} className="flex items-center gap-4 p-3 border rounded-md has-[:checked]:bg-muted has-[:checked]:border-primary transition-all">
            <Checkbox id={`delivery-${delivery.id}`} checked={!!selectedDeliveries[delivery.id]} onCheckedChange={(checked) => { setSelectedDeliveries(prev => ({...prev, [delivery.id]: !!checked})); }} />
            <label htmlFor={`delivery-${delivery.id}`} className="flex-grow cursor-pointer select-none">
              <div className="flex items-center justify-between w-full text-left">
                <div className="flex-grow">
                  <p className="font-bold text-slate-800 uppercase text-sm tracking-tight">{delivery.clientName}</p>
                  <p className="text-[10px] font-black uppercase text-slate-400 tracking-widest mt-1">Pedido por {delivery.salesManagerName} - {delivery.createdAt ? format(new Date(delivery.createdAt), 'PPP', { locale: es }) : ''}</p>
                </div>
                <div className="font-black text-lg pr-4 text-slate-900 font-mono tracking-tighter">C$ {delivery.total.toFixed(2)}</div>
              </div>
            </label>
          </div>
        ))}
      </div>
    );
  };

  return (
    <div className="flex flex-col h-full bg-slate-50/30 p-4 lg:p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-black tracking-tighter text-slate-900 uppercase italic">Asignar Rutas de <span className="text-blue-600">Entrega</span></h1>
        <p className="text-xs font-black uppercase tracking-[0.2em] text-slate-400 mt-1 italic">Gestión logística y despacho de pedidos</p>
      </div>
      
      <div className="grid md:grid-cols-3 gap-8 flex-grow">
        <Card className="md:col-span-2 border-none shadow-sm shadow-slate-200/50 rounded-[2rem] overflow-hidden">
          <CardHeader className="bg-white border-b border-slate-100">
            <CardTitle className="text-lg font-black uppercase tracking-tight text-slate-800 flex items-center gap-2">
              <ClipboardCheck className="w-5 h-5 text-blue-500" />
              Pedidos Pendientes de Asignación
            </CardTitle>
          </CardHeader>
          <CardContent className="bg-white/50 p-6">
            {renderContent()}
          </CardContent>
        </Card>
        
        <div className="space-y-6 flex flex-col">
          <Card className="sticky top-24 border-none shadow-xl shadow-slate-200/50 rounded-[2.5rem] overflow-hidden bg-white">
            <CardHeader className="pb-4">
              <CardTitle className="text-xl font-black uppercase tracking-tight text-slate-800 italic">Asignar a <span className="text-blue-600">Rutero</span></CardTitle>
              <CardDescription className="font-bold text-[10px] uppercase tracking-widest text-slate-400">{selectedCount} pedido(s) seleccionado(s).</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-2">
                <label className="text-[10px] font-black uppercase tracking-widest text-slate-400 pl-1">Personal de Ruta</label>
                <Select onValueChange={setSelectedRutero} value={selectedRutero || ''}>
                  <SelectTrigger className="h-12 rounded-xl border-slate-100 bg-slate-50 font-bold uppercase text-xs">
                    <SelectValue placeholder="Selecciona un rutero..." />
                  </SelectTrigger>
                  <SelectContent className="rounded-xl border-slate-100 shadow-xl font-bold uppercase text-xs">
                    {ruteros.map(r => (<SelectItem key={r.uid} value={r.uid}>{r.name}</SelectItem>))}
                  </SelectContent>
                </Select>
              </div>
              
              <Button 
                className="w-full h-14 rounded-2xl bg-blue-600 hover:bg-blue-700 text-white font-black uppercase tracking-widest shadow-lg shadow-blue-100 transition-all active:scale-95 disabled:bg-slate-100 disabled:text-slate-300 disabled:shadow-none" 
                disabled={isProcessing || selectedCount === 0 || !selectedRutero} 
                onClick={handleAssignRoute}
              >
                {isProcessing ? (
                  <Skeleton className="h-4 w-4 bg-white/20 rounded-full animate-pulse" />
                ) : (
                  <Route className="mr-2 h-5 w-5" />
                )}
                Confirmar Asignación
              </Button>
            </CardContent>
          </Card>
          
          <div className="flex-grow"></div>
          
          <div className="p-6 bg-slate-100/50 rounded-[2rem] border border-dashed border-slate-200">
             <p className="text-[9px] font-black uppercase text-slate-400 tracking-widest leading-relaxed">
               * Nota: Una vez asignados, los pedidos aparecerán en el aplicativo móvil del rutero seleccionado en tiempo real.
             </p>
          </div>
        </div>
      </div>
    </div>
  );
}
