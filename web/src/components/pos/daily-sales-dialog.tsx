import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { toast } from '@/lib/swalert';
import { useEffect, useState } from 'react';
import { FileText, Loader2, Printer } from 'lucide-react';
import { useParams } from 'react-router-dom';
import apiClient from '@/services/api-client';
import { logError } from '@/lib/error-logger';
import { ScrollArea } from '../ui/scroll-area';
import { format, parseISO } from 'date-fns';
import { es } from 'date-fns/locale';
import type { Sale } from './printable-sale-ticket';

interface DailySalesDialogProps {
  activeShiftId: string;
  onReprint: (sale: Sale) => void;
  onClose: () => void;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
}

export function DailySalesDialog({ activeShiftId, onReprint, onClose, open: controlledOpen, onOpenChange: setControlledOpen }: DailySalesDialogProps) {
  const params = useParams();
  const storeId = params.storeId as string;

  const [internalIsOpen, setInternalIsOpen] = useState(false);

  const isOpen = controlledOpen !== undefined ? controlledOpen : internalIsOpen;
  const setIsOpen = setControlledOpen || setInternalIsOpen;

  const [isLoading, setIsLoading] = useState(false);
  const [sales, setSales] = useState<Sale[]>([]);

  const fetchSales = async () => {
    if (!activeShiftId) return;
    setIsLoading(true);
    try {
      const response = await apiClient.get('/sales', {
        params: {
          storeId,
          shiftId: activeShiftId
        }
      });
      
      const salesData = response.data;
      setSales(salesData);
    } catch (error) {
      logError(error, { location: 'daily-sales-dialog-fetch', additionalInfo: { storeId, activeShiftId } });
      toast.error('Error', 'No se pudieron cargar las ventas del día.');
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    if (isOpen) {
      fetchSales();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isOpen, activeShiftId]);

  const handleReprintClick = (sale: Sale) => {
    onReprint(sale);
    setIsOpen(false);
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      {!controlledOpen && (
        <DialogTrigger asChild>
          <div className="relative flex cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors focus:bg-accent focus:text-accent-foreground data-[disabled]:pointer-events-none data-[disabled]:opacity-50">
            <FileText className="mr-2 h-4 w-4" />
            <span>Ventas del Día</span>
          </div>
        </DialogTrigger>
      )}
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>Ventas del Turno Actual</DialogTitle>
          <DialogDescription>
            Lista de ventas realizadas en esta caja durante este turno.
          </DialogDescription>
        </DialogHeader>
        <div className="mt-4">
          {isLoading ? (
            <div className="flex justify-center items-center h-48">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : sales.length === 0 ? (
            <div className="h-48 flex flex-col items-center justify-center text-muted-foreground gap-2">
              <FileText className="h-8 w-8 opacity-20" />
              <p>No hay ventas en este turno.</p>
            </div>
          ) : (
            <ScrollArea className="h-96">
              <div className="space-y-2 pr-4">
                {sales.map(sale => (
                  <div key={sale.id} className="flex items-center justify-between p-3 rounded-md border bg-slate-50/50 hover:bg-slate-50 transition-colors">
                    <div>
                      <p className="font-bold text-sm text-slate-800">Tiket: {sale.ticketNumber || sale.id.slice(-6)}</p>
                      <p className="text-xs text-muted-foreground">
                        {format(parseISO(sale.createdAt as string), 'p', { locale: es })} - <span className="font-bold text-primary">C$ {sale.total.toFixed(2)}</span>
                      </p>
                    </div>
                    <Button variant="outline" size="sm" className="h-8 px-2 text-xs" onClick={() => handleReprintClick(sale)}>
                      <Printer className="mr-2 h-3.5 w-3.5 text-primary" />
                      Reimprimir
                    </Button>
                  </div>
                ))}
              </div>
            </ScrollArea>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
