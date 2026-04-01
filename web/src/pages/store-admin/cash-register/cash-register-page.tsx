import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { 
  Banknote, 
  DoorOpen, 
  Lock, 
  FileText, 
  Wallet, 
  ChevronRight, 
  CheckCircle2,
  AlertCircle,
  ShoppingCart,
  Printer
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { 
    Dialog, 
    DialogContent, 
    DialogHeader, 
} from '@/components/ui/dialog';
import { Skeleton } from '@/components/ui/skeleton';
import { useAuth } from '@/contexts/auth-context';
import apiClient from '@/services/api-client';
import { toast } from '@/lib/swalert';
import { format, parseISO } from 'date-fns';
import { es } from 'date-fns/locale';
import { cn } from '@/lib/utils';

interface CashShift {
  id: string;
  status: 'OPEN' | 'CLOSED';
  openedAt: string;
  closedAt?: string;
  startingCash: number;
  actualCash: number;
}

export default function CashRegisterPage() {
  const { storeId } = useParams();
  const { user } = useAuth();
  const [activeShift, setActiveShift] = useState<CashShift | null>(null);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({ cashSales: 0, cardSales: 0, totalSales: 0 });
  const [isOpeningShift, setIsOpeningShift] = useState(false);
  const [isClosingShift, setIsClosingShift] = useState(false);
  const [startingCash, setStartingCash] = useState('0');
  const [actualCashInput, setActualCashInput] = useState('0');

  useEffect(() => {
    fetchActiveShift();
  }, [storeId]);

  const fetchActiveShift = async () => {
    if (!storeId) return;
    setLoading(true);
    try {
      const response = await apiClient.get(`/cash-shifts/active?storeId=${storeId}`);
      setActiveShift(response.data);
      if (response.data) {
        fetchShiftStats(response.data.id);
      }
    } catch (error) {
      console.error('Error fetching shift:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchShiftStats = async (shiftId: string) => {
    try {
      const response = await apiClient.get(`/cash-shifts/stats/${shiftId}`);
      setStats(response.data);
    } catch (error) {
      console.error('Error fetching stats:', error);
    }
  };

  const handleOpenShift = async () => {
    if (!user || !storeId) return;
    try {
      const response = await apiClient.post('/cash-shifts', {
        storeId,
        userId: user.id,
        startingCash: parseFloat(startingCash)
      });
      setActiveShift(response.data);
      setIsOpeningShift(false);
      toast.success('Caja Abierta', 'Turno de caja iniciado correctamente.');
    } catch (error) {
      toast.error('Error', 'No se pudo abrir el turno de caja.');
    }
  };

  const handleCloseShift = async () => {
    if (!activeShift || !storeId || !user) return;
    const expectedCash = activeShift.startingCash + stats.cashSales;
    const actualCash = parseFloat(actualCashInput);
    const difference = actualCash - expectedCash;

    try {
      await apiClient.post('/cash-shifts/close', {
        shiftId: activeShift.id,
        storeId,
        expectedCash,
        actualCash,
        difference,
        userId: user.id
      });
      toast.success('Caja Cerrada', 'Turno finalizado y reporte generado.');
      setActiveShift(null);
      setIsClosingShift(false);
    } catch (error) {
      toast.error('Error', 'No se pudo cerrar el turno de caja.');
    }
  };

  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <Skeleton className="h-20 w-1/3 rounded-2xl" />
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[1,2,3,4].map(i => <Skeleton key={i} className="h-32 rounded-[24px]" />)}
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-8 max-w-6xl mx-auto">
      <div className="flex flex-col gap-2 items-center text-center">
        <h1 className="text-4xl font-black tracking-tight text-slate-800 flex items-center gap-3">
          <Banknote className="h-10 w-10 text-primary" />
          Control de Caja
        </h1>
        <p className="text-slate-500 font-bold uppercase tracking-[0.3em] text-xs underline decoration-primary decoration-4 underline-offset-8">Operaciones de Ventas</p>
      </div>

      {!activeShift ? (
        <div className="py-20 flex flex-col items-center justify-center">
           <Card className="max-w-md w-full border-none shadow-[30px_30px_60px_#ccced1,-30px_-30px_60px_#ffffff] bg-[#f0f2f5] rounded-[40px] overflow-hidden group">
              <div className="h-3 bg-red-400"></div>
              <CardContent className="p-10 flex flex-col items-center text-center space-y-6">
                 <div className="w-24 h-24 bg-red-50 rounded-[32px] flex items-center justify-center text-red-500 shadow-sm mb-4">
                    <Lock className="h-12 w-12" />
                 </div>
                 <h2 className="text-2xl font-black text-slate-800 uppercase leading-none">Caja Inactiva</h2>
                 <p className="text-slate-500 font-medium">No hay un turno de caja abierto para tu usuario en esta tienda.</p>
                 <Button 
                  onClick={() => setIsOpeningShift(true)}
                  className="w-full h-16 rounded-[24px] text-lg font-black tracking-widest shadow-xl shadow-primary/20 hover:scale-[1.02] transition-all bg-primary uppercase"
                 >
                    <DoorOpen className="mr-3 h-6 w-6" />
                    Abrir Caja Ahora
                 </Button>
              </CardContent>
           </Card>
        </div>
      ) : (
        <div className="space-y-8 animate-in fade-in duration-700">
           {/* Resumen Superior */}
           <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <Card className="border-none shadow-[20px_20px_40px_#ccced1,-20px_-20px_40px_#ffffff] bg-[#f0f2f5] rounded-[32px] p-6 group hover:translate-y-[-4px] transition-all">
                 <div className="flex items-center gap-4 mb-4">
                    <div className="w-12 h-12 rounded-2xl bg-blue-50 flex items-center justify-center text-blue-500 shadow-sm">
                       <CheckCircle2 className="h-6 w-6" />
                    </div>
                    <div>
                       <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Turno Abierto</p>
                       <p className="font-bold text-slate-800">{format(parseISO(activeShift.openedAt), 'Pp', { locale: es })}</p>
                    </div>
                 </div>
                 <div className="space-y-1">
                    <p className="text-xs font-bold text-slate-400 uppercase">Fondo Inicial</p>
                    <p className="text-2xl font-black text-slate-900 font-mono italic">C$ {activeShift.startingCash.toFixed(2)}</p>
                 </div>
              </Card>

              <Card className="border-none shadow-[20px_20px_40px_#ccced1,-20px_-20px_40px_#ffffff] bg-[#f0f2f5] rounded-[32px] p-6 group hover:translate-y-[-4px] transition-all">
                 <div className="flex items-center gap-4 mb-4">
                    <div className="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center text-green-500 shadow-sm">
                       <ShoppingCart className="h-6 w-6" />
                    </div>
                    <div>
                       <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Ventas Efectivo</p>
                       <p className="font-bold text-slate-800">Total Acumulado</p>
                    </div>
                 </div>
                 <div className="space-y-1">
                    <p className="text-xs font-bold text-slate-400 uppercase">Neto Caja</p>
                    <p className="text-2xl font-black text-green-600 font-mono italic">C$ {stats.cashSales.toFixed(2)}</p>
                 </div>
              </Card>

              <Card className="border-none shadow-[20px_20px_40px_#ccced1,-20px_-20px_40px_#ffffff] bg-[#f0f2f5] rounded-[32px] p-6 group hover:translate-y-[-4px] transition-all border-l-8 border-primary">
                 <div className="flex items-center gap-4 mb-4">
                    <div className="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center text-primary shadow-sm">
                       <Wallet className="h-6 w-6" />
                    </div>
                    <div>
                       <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Efectivo Estimado</p>
                       <p className="font-bold text-slate-800">Fondo + Ventas</p>
                    </div>
                 </div>
                 <div className="space-y-1">
                    <p className="text-xs font-bold text-slate-400 uppercase">Monto en Gaveta</p>
                    <p className="text-3xl font-black text-primary font-mono italic tracking-tighter">C$ {(activeShift.startingCash + stats.cashSales).toFixed(2)}</p>
                 </div>
              </Card>
           </div>

           {/* Acciones de Operación */}
           <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <Card className="border-none shadow-[20px_20px_60px_#ccced1,-20px_-20px_60px_#ffffff] bg-[#f0f2f5] rounded-[32px] overflow-hidden">
                 <CardHeader className="bg-slate-800 py-6">
                    <CardTitle className="text-white text-lg font-black uppercase flex items-center gap-2 tracking-widest">
                       <FileText className="h-5 w-5" />
                       Reportes Rápidos
                    </CardTitle>
                 </CardHeader>
                 <CardContent className="p-8 space-y-4">
                    <Button variant="outline" className="w-full h-14 rounded-2xl font-bold justify-between px-6 border-slate-200">
                       <div className="flex items-center gap-3">
                          <Printer className="h-5 w-5 text-slate-400" />
                          <span>IMPRIMIR CORTE X (LECTURA)</span>
                       </div>
                       <ChevronRight className="h-4 w-4" />
                    </Button>
                    <Button variant="outline" className="w-full h-14 rounded-2xl font-bold justify-between px-6 border-slate-200">
                       <div className="flex items-center gap-3">
                          <FileText className="h-5 w-5 text-slate-400" />
                          <span>ÚLTIMAS 50 VENTAS</span>
                       </div>
                       <ChevronRight className="h-4 w-4" />
                    </Button>
                 </CardContent>
              </Card>

              <Card className="border-none shadow-[20px_20px_60px_#ccced1,-20px_-20px_60px_#ffffff] bg-[#f0f2f5] rounded-[32px] overflow-hidden">
                 <CardHeader className="bg-red-500 py-6">
                    <CardTitle className="text-white text-lg font-black uppercase flex items-center gap-2 tracking-widest">
                       <Lock className="h-5 w-5" />
                       Cierre de Operaciones
                    </CardTitle>
                 </CardHeader>
                 <CardContent className="p-8">
                    <div className="flex flex-col items-center text-center space-y-6">
                       <p className="text-slate-500 font-medium italic">Al cerrar la caja se emitirá el Reporte Z y se bloqueará la terminal para nuevas ventas hasta el siguiente turno.</p>
                       <Button 
                        onClick={() => {
                            setActualCashInput((activeShift.startingCash + stats.cashSales).toString());
                            setIsClosingShift(true);
                        }}
                        className="w-full h-16 rounded-[24px] text-lg font-black tracking-widest bg-red-600 hover:bg-red-700 shadow-xl shadow-red-100 uppercase"
                       >
                          Finalizar Turno Actual
                       </Button>
                    </div>
                 </CardContent>
              </Card>
           </div>
        </div>
      )}

      {/* DIALOGS */}
      
      {/* Apertura de Caja */}
      <Dialog open={isOpeningShift} onOpenChange={setIsOpeningShift}>
         <DialogContent className="rounded-[40px] border-none shadow-2xl p-0 overflow-hidden max-w-md">
            <div className="bg-primary p-8 text-white">
                <h2 className="text-2xl font-black uppercase tracking-tight flex items-center gap-3 text-white">
                    <DoorOpen className="h-7 w-7 text-white" />
                    Apertura de Turno
                </h2>
                <p className="text-primary-foreground/80 font-medium mt-1">Ingresa el dinero inicial en gaveta.</p>
            </div>
            <div className="p-8 space-y-6">
                <div className="space-y-3">
                    <Label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-2">Fondo de Caja (NIO)</Label>
                    <div className="relative">
                        <span className="absolute left-6 top-1/2 -translate-y-1/2 text-2xl font-black text-slate-300">C$</span>
                        <Input 
                            type="number"
                            className="h-20 pl-16 rounded-[24px] text-3xl font-black bg-[#f0f2f5] border-none shadow-[inset_4px_4px_8px_#ccced1,inset_-4px_-4px_8px_#ffffff] transition-all font-mono"
                            value={startingCash}
                            onChange={(e) => setStartingCash(e.target.value)}
                        />
                    </div>
                </div>
                <Button 
                    onClick={handleOpenShift}
                    className="w-full h-16 rounded-[24px] text-lg font-black tracking-widest bg-primary shadow-lg shadow-primary/20 uppercase"
                >
                    Confirmar Apertura
                </Button>
            </div>
         </DialogContent>
      </Dialog>

      {/* Cierre de Caja (Cuadre) */}
      <Dialog open={isClosingShift} onOpenChange={setIsClosingShift}>
         <DialogContent className="rounded-[40px] border-none shadow-2xl p-0 overflow-hidden max-w-lg">
            <div className="bg-red-500 p-8 text-white">
                <h2 className="text-2xl font-black uppercase tracking-tight flex items-center gap-3 text-white">
                    <Lock className="h-7 w-7 text-white" />
                    Cuadre y Cierre
                </h2>
                <p className="text-white/80 font-medium mt-1 italic">Verifica el efectivo físico contra el sistema.</p>
            </div>
            <div className="p-8 space-y-8">
                <div className="grid grid-cols-2 gap-6">
                    <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100">
                        <p className="text-[10px] font-bold text-slate-400 uppercase">Monto Esperado</p>
                        <p className="text-xl font-black text-slate-800 font-mono">C$ {(activeShift?.startingCash! + stats.cashSales).toFixed(2)}</p>
                    </div>
                   <div className="p-4 bg-slate-50 rounded-2xl border border-slate-100">
                        <p className="text-[10px] font-bold text-slate-400 uppercase">Ventas Tarjeta</p>
                        <p className="text-xl font-black text-blue-600 font-mono">C$ {stats.cardSales.toFixed(2)}</p>
                    </div>
                </div>

                <div className="space-y-3">
                    <Label className="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-2">Efectivo Físico en Gaveta</Label>
                    <Input 
                        type="number"
                        className="h-20 rounded-[24px] text-3xl font-black bg-[#f0f2f5] border-none shadow-[inset_4px_4px_8px_#ccced1,inset_-4px_-4px_8px_#ffffff] transition-all font-mono text-center"
                        value={actualCashInput}
                        onChange={(e) => setActualCashInput(e.target.value)}
                    />
                </div>

                {activeShift && (parseFloat(actualCashInput) - (activeShift.startingCash + stats.cashSales)) !== 0 && (
                    <div className={cn(
                        "p-4 rounded-2xl flex items-center gap-3 font-bold",
                        (parseFloat(actualCashInput) - (activeShift.startingCash + stats.cashSales)) < 0 
                            ? "bg-red-50 text-red-600 border border-red-100" 
                            : "bg-amber-50 text-amber-600 border border-amber-100"
                    )}>
                        <AlertCircle className="h-5 w-5" />
                        <span>Diferencia: C$ {(parseFloat(actualCashInput) - (activeShift.startingCash + stats.cashSales)).toFixed(2)}</span>
                    </div>
                )}

                <Button 
                    onClick={handleCloseShift}
                    className="w-full h-16 rounded-[24px] text-lg font-black tracking-widest bg-red-600 hover:bg-red-700 shadow-lg shadow-red-100 uppercase"
                >
                    Finalizar y Generar Z
                </Button>
            </div>
         </DialogContent>
      </Dialog>
    </div>
  );
}
