import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { useNavigate, useParams, Link } from 'react-router-dom';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Input } from '@/components/ui/input';
import {
  Banknote,
  MinusCircle,
  PlusCircle,
  CreditCard,
  User,
  CircleDollarSign,
  ShoppingBag,
  Loader2,
  MoreVertical,
} from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useEffect, useState, useCallback, useMemo, useRef } from 'react';
import type { Product, Client } from '@/types';
import { ProductSearch } from '@/components/pos/product-search';
import { Separator } from '@/components/ui/separator';
import apiClient from '@/services/api-client';
import { ReturnsDialog } from '@/components/pos/returns-dialog';
import { AddClientDialog } from '@/components/pos/add-client-dialog';
import { Label } from '@/components/ui/label';
import { useAuth } from '@/contexts/auth-context';
import { toast } from '@/lib/swalert';
import { logError } from '@/lib/error-logger';
import { PrintableSaleTicket } from '@/components/pos/printable-sale-ticket';
import { DailySalesDialog } from '@/components/pos/daily-sales-dialog';
import { CashierLayout } from '@/components/pos/cashier-layout';
import { CashierBillingView } from '@/components/pos/cashier-billing-view';
import { PaymentData } from '@/components/pos/payment-dialog';

interface CartItem extends Product {
  quantity: number;
}

interface StoreSettings {
  applyVAT: boolean;
  billingMode?: 'scan-and-add' | 'scan-and-prompt';
  exchangeRate?: number;
}

interface Shift {
  id: string;
  status: 'open' | 'closed';
  openingTimestamp: string | Date;
}

const genericClient: Client = {
  id: 'generic',
  storeId: '',
  name: 'Cliente Genérico',
  phone: '',
  address: '',
  email: ''
};

function QuantityPromptDialog({
  isOpen,
  onClose,
  product,
  onConfirm,
}: {
  isOpen: boolean;
  onClose: () => void;
  product: Product;
  onConfirm: (quantity: number) => void;
}) {
  const [quantity, setQuantity] = useState(1);

  const handleConfirm = () => {
    if (quantity > 0) {
      onConfirm(quantity);
      setQuantity(1);
    }
  };

  if (!isOpen) return null;

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Ingresar Cantidad</DialogTitle>
          <DialogDescription>
            ¿Cuántas unidades de &quot;{product.description}&quot; deseas agregar?
          </DialogDescription>
        </DialogHeader>
        <div className="py-4">
          <Label htmlFor="quantity">Cantidad</Label>
          <Input
            id="quantity"
            type="number"
            value={quantity}
            onChange={(e) => setQuantity(Number(e.target.value))}
            className="text-2xl h-14 text-center"
            autoFocus
            onKeyPress={(e) => e.key === 'Enter' && handleConfirm()}
          />
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancelar
          </Button>
          <Button onClick={handleConfirm}>Agregar a la Venta</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}


export default function BillingPage() {
  const [cart, setCart] = useState<CartItem[]>([]);
  const [settings, setSettings] = useState<StoreSettings>({ applyVAT: false, billingMode: 'scan-and-add', exchangeRate: 36.6 });
  const [activeShift, setActiveShift] = useState<Shift | null>(null);
  const [loading, setLoading] = useState(true);
  const [selectedClient, setSelectedClient] = useState<Client>(genericClient);
  const [productForQuantityPrompt, setProductForQuantityPrompt] = useState<Product | null>(null);
  const [amountReceived, setAmountReceived] = useState<number | string>('');
  const [paymentCurrency, setPaymentCurrency] = useState<'NIO' | 'USD'>('NIO');
  const [isPaymentProcessing, setIsPaymentProcessing] = useState(false);
  const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
  const [saleToPrint, setSaleToPrint] = useState<any>(null);
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  const ticketRef = useRef<any>(null);

  const params = useParams();
  const storeId = params.storeId as string;
  const { user, loading: authLoading } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    if (!authLoading && !user) {
      navigate('/login');
    }
  }, [authLoading, user, navigate]);

  useEffect(() => {
    if (!storeId || !user?.id) return;

    const fetchSettings = async () => {
      try {
        const response = await apiClient.get(`/stores/${storeId}`);
        if (response.data && response.data.settings) {
          setSettings(response.data.settings as StoreSettings);
        }
      } catch (error) {
        console.error("Failed to fetch store settings:", error);
      }
    };
    fetchSettings();

    let intervalId: any;
    const fetchActiveShift = async () => {
      try {
        const response = await apiClient.get('/cash-shifts', {
          params: { storeId, cashierId: user.id, status: 'open' }
        });
        if (response.data && response.data.length > 0) {
          setActiveShift(response.data[0]);
        } else {
          setActiveShift(null);
        }
      } catch (error) {
         console.error("Error fetching shifts:", error);
         setActiveShift(null);
      } finally {
        setLoading(false);
      }
    }
    fetchActiveShift();
    intervalId = setInterval(fetchActiveShift, 30000);

    return () => clearInterval(intervalId);
  }, [storeId, user?.id]);


  const handleAddProduct = useCallback((product: Product, quantity: number = 1) => {
    setCart((prevCart) => {
      const existingItem = prevCart.find((item) => item.id === product.id);
      if (existingItem) {
        return prevCart.map((item) =>
          item.id === product.id
            ? { ...item, quantity: item.quantity + quantity }
            : item
        );
      }
      return [...prevCart, { ...product, quantity }];
    });
  }, []);

  const handleProductSelect = useCallback((product: Product) => {
    if (settings.billingMode === 'scan-and-prompt') {
      setProductForQuantityPrompt(product);
    } else {
      handleAddProduct(product, 1);
    }
  }, [settings.billingMode, handleAddProduct]);


  const handleQuantityChange = (productId: string, amount: number) => {
    setCart((prevCart) =>
      prevCart
        .map((item) =>
          item.id === productId
            ? { ...item, quantity: Math.max(0, item.quantity + amount) }
            : item
        )
        .filter((item) => item.quantity > 0)
    );
  };

  const subtotal = cart.reduce((acc, item) => acc + item.salePrice * item.quantity, 0);
  const tax = settings?.applyVAT ? subtotal * 0.15 : 0;
  const total = subtotal + tax;

  const handleDialogChange = (open: boolean) => {
    if (!open) {
      setAmountReceived('');
      setPaymentCurrency('NIO');
    }
    setIsPaymentDialogOpen(open);
  }

  const resetSale = () => {
    setCart([]);
    setSelectedClient(genericClient);
    setAmountReceived('');
    setPaymentCurrency('NIO');
    setIsPaymentDialogOpen(false);
  }

  const handleFinalizeSale = async (methodOrData: 'Efectivo' | 'Tarjeta' | PaymentData) => {
    if (!user || !activeShift) {
      toast.error('Error', 'No se pudo identificar al cajero o el turno de caja.');
      return;
    }

    let paymentMethod: 'Efectivo' | 'Tarjeta';
    let finalAmountReceived: number;
    let finalPaymentCurrency: 'NIO' | 'USD';
    let finalChange: number;

    if (typeof methodOrData === 'object' && 'method' in methodOrData) {
      paymentMethod = methodOrData.method as any;
      finalAmountReceived = methodOrData.amountReceived;
      finalPaymentCurrency = methodOrData.paymentCurrency as any;
      finalChange = methodOrData.change;
    } else {
      paymentMethod = methodOrData as 'Efectivo' | 'Tarjeta';
      finalAmountReceived = Number(amountReceived);
      finalPaymentCurrency = paymentCurrency;
      finalChange = change;
    }

    setIsPaymentProcessing(true);
    try {
      const salePayload = {
        storeId,
        shiftId: activeShift.id,
        cashierId: user.id,
        cashierName: user.name,
        clientId: selectedClient.id,
        clientName: selectedClient.name,
        items: cart.map(({ id, description, quantity, salePrice, costPrice, usesInventory, currentStock }) => ({ 
           id, description, quantity, salePrice, costPrice: costPrice || 0, usesInventory, currentStock 
        })),
        paymentMethod,
        paymentCurrency: finalPaymentCurrency,
        amountReceived: finalAmountReceived,
        change: finalChange,
      };

      const response = await apiClient.post('/sales/process', salePayload);
      const saleToPrintData = response.data;

      setSaleToPrint(saleToPrintData);

      toast.success('Venta Completada', 'La venta ha sido registrada exitosamente.');
      resetSale();
    } catch (error) {
      logError(error, {
        location: 'billing-page-finalize-sale',
        additionalInfo: { storeId, cartSize: cart.length }
      });
      toast.error('Error al Guardar', 'No se pudo registrar la venta. Inténtalo de nuevo.');
    } finally {
      setIsPaymentProcessing(false);
    }
  };

  const change = useMemo(() => {
    const received = Number(amountReceived);
    if (isNaN(received) || received <= 0) return 0;

    let receivedInNIO = received;
    if (paymentCurrency === 'USD') {
      receivedInNIO = received * (settings.exchangeRate || 36.6);
    }

    if (receivedInNIO < total) {
      return 0;
    }
    return receivedInNIO - total;
  }, [amountReceived, total, paymentCurrency, settings.exchangeRate]);


  if (loading || authLoading) {
    return (
      <div className="flex items-center justify-center h-full">
        <Loader2 className="animate-spin h-8 w-8 text-primary" />
      </div>
    );
  }

  if (!user) return null;

  if (!activeShift) {
    return (
      <div className="flex items-center justify-center h-full p-4">
        <Card className="max-w-md w-full">
          <CardHeader className="text-center">
            <div className="mx-auto w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mb-4">
              <Banknote className="h-8 w-8 text-red-600" />
            </div>
            <CardTitle className="text-2xl font-bold text-red-600">¡Caja Cerrada!</CardTitle>
            <CardDescription>
              Es obligatorio realizar la apertura de caja antes de comenzar a facturar.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <Button asChild className="w-full h-12" variant="default">
              <Link to={`/store/${storeId}/cash-register`}>
                REALIZAR APERTURA DE CAJA
              </Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Check for Cashier role to render specific layout
  if (user?.role === 'Cashier' || user?.role === 'Cajero') {
    return (
      <CashierLayout>
        <CashierBillingView
          cart={cart}
          subtotal={subtotal}
          tax={tax}
          total={total}
          onAddProduct={handleAddProduct}
          onRemoveProduct={(productId) => {
            const item = cart.find(i => i.id === productId);
            if (item) handleQuantityChange(productId, -item.quantity);
          }}
          onUpdateQuantity={handleQuantityChange}
          client={selectedClient}
          onSelectClient={setSelectedClient}
          onFinalize={handleFinalizeSale}
          activeShift={activeShift}
          onClearCart={() => setCart([])}
          onSetCart={(newCart) => setCart(newCart as any)}
          lastSale={saleToPrint}
        />
        <div className="fixed top-0 left-0 -z-50 opacity-0 pointer-events-none">
          <PrintableSaleTicket ref={ticketRef} storeId={storeId} sale={saleToPrint} />
        </div>
      </CashierLayout>
    );
  }

  return (
    <>
      <div className="grid md:grid-cols-3 gap-6 h-full print:hidden">
        <div className="md:col-span-2 space-y-6">
          <QuantityPromptDialog
            isOpen={!!productForQuantityPrompt}
            onClose={() => setProductForQuantityPrompt(null)}
            product={productForQuantityPrompt!}
            onConfirm={(quantity) => {
              if (productForQuantityPrompt) handleAddProduct(productForQuantityPrompt, quantity);
              setProductForQuantityPrompt(null);
            }}
          />
          <ProductSearch onProductSelect={handleProductSelect} />
          <Card>
            <CardHeader>
              <CardTitle>Cliente</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-4">
                <Input placeholder="Buscar cliente..." />
                <AddClientDialog onClientAdded={setSelectedClient} />
              </div>
              <div className="mt-4 p-4 border rounded-lg bg-muted/30 flex items-center gap-4">
                <User className="h-8 w-8 text-muted-foreground" />
                <div>
                  <p className="font-semibold">{selectedClient.name}</p>
                  <p className="text-sm text-muted-foreground">{selectedClient.phone || 'Sin teléfono'}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="relative flex flex-col h-full">
          <Card className="flex flex-col flex-grow">
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>Venta Actual</CardTitle>
                <DropdownMenu open={isMenuOpen} onOpenChange={setIsMenuOpen}>
                  <DropdownMenuTrigger asChild>
                    <Button variant="ghost" size="icon">
                      <MoreVertical className="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DailySalesDialog
                      activeShiftId={activeShift.id}
                      onReprint={setSaleToPrint}
                      onClose={() => setIsMenuOpen(false)}
                    />
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </CardHeader>
            <CardContent className="flex-grow overflow-auto">
              {cart.length > 0 ? (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Producto</TableHead>
                      <TableHead className="text-center">Cant.</TableHead>
                      <TableHead className="text-right">Subtotal</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {cart.map((item) => (
                      <TableRow key={item.id}>
                        <TableCell>
                          <p className="font-medium truncate">{item.description}</p>
                          <p className="text-xs text-muted-foreground">
                            C$ {item.salePrice.toFixed(2)}
                          </p>
                        </TableCell>
                        <TableCell className="text-center">
                          <div className="flex items-center justify-center gap-1">
                            <Button variant="ghost" size="icon" onClick={() => handleQuantityChange(item.id, -1)}>
                              <MinusCircle className="h-4 w-4" />
                            </Button>
                            <span>{item.quantity}</span>
                            <Button variant="ghost" size="icon" onClick={() => handleQuantityChange(item.id, 1)}>
                              <PlusCircle className="h-4 w-4" />
                            </Button>
                          </div>
                        </TableCell>
                        <TableCell className="text-right font-medium">
                          C$ {(item.salePrice * item.quantity).toFixed(2)}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              ) : (
                <div className="flex flex-col items-center justify-center h-full text-center text-muted-foreground p-4">
                  <ShoppingBag className="h-16 w-16 mb-4" />
                  <p className="text-lg font-medium">Ticket de Venta Vacío</p>
                  <ReturnsDialog />
                </div>
              )}
            </CardContent>

            {cart.length > 0 && (
              <div className="p-4 border-t mt-auto space-y-4 bg-background">
                <div className="space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span>Subtotal:</span>
                    <span>C$ {subtotal.toFixed(2)}</span>
                  </div>
                  {settings?.applyVAT && (
                    <div className="flex justify-between">
                      <span>IVA (15%):</span>
                      <span>C$ {tax.toFixed(2)}</span>
                    </div>
                  )}
                  <Separator />
                  <div className="flex justify-between font-bold text-lg">
                    <span>Total a Pagar:</span>
                    <span>C$ {total.toFixed(2)}</span>
                  </div>
                </div>
                <Dialog open={isPaymentDialogOpen} onOpenChange={handleDialogChange}>
                  <DialogTrigger asChild>
                    <Button className="w-full h-14" disabled={cart.length === 0}>
                      <CircleDollarSign className="mr-2 h-6 w-6" />
                      Cobrar
                    </Button>
                  </DialogTrigger>
                  <DialogContent>
                    <DialogHeader>
                      <DialogTitle>Finalizar Venta</DialogTitle>
                    </DialogHeader>
                    <div className="py-4 space-y-4">
                      <div className="text-center">
                        <p className="text-3xl font-bold">C$ {total.toFixed(2)}</p>
                      </div>
                      <div className="flex gap-2">
                        <Button variant={paymentCurrency === 'NIO' ? 'default' : 'outline'} className="flex-1" onClick={() => setPaymentCurrency('NIO')}>NIO</Button>
                        <Button variant={paymentCurrency === 'USD' ? 'default' : 'outline'} className="flex-1" onClick={() => setPaymentCurrency('USD')}>USD</Button>
                      </div>
                      <Input
                        type="number"
                        placeholder="Monto Recibido"
                        className="text-lg h-12 text-right"
                        value={amountReceived}
                        onChange={(e) => setAmountReceived(e.target.value)}
                      />
                      {change > 0 && (
                        <div className="text-center p-4 bg-muted rounded-lg">
                          <p className="text-sm">Cambio</p>
                          <p className="text-2xl font-bold text-primary">C$ {change.toFixed(2)}</p>
                        </div>
                      )}
                      <div className="grid grid-cols-2 gap-4">
                        <Button className="h-14" onClick={() => handleFinalizeSale('Efectivo')} disabled={isPaymentProcessing}>Efectivo</Button>
                        <Button variant="secondary" className="h-14" onClick={() => handleFinalizeSale('Tarjeta')} disabled={isPaymentProcessing}>Tarjeta</Button>
                      </div>
                    </div>
                  </DialogContent>
                </Dialog>
              </div>
            )}
          </Card>
        </div>
      </div>
      <div className="fixed top-0 left-0 -z-50 opacity-0 pointer-events-none">
        <PrintableSaleTicket ref={ticketRef} storeId={storeId} sale={saleToPrint} />
      </div>
    </>
  );
}
