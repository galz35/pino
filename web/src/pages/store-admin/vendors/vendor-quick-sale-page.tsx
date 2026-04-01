import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { MinusCircle, PlusCircle, User, ShoppingBag, Loader2, DollarSign } from 'lucide-react';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import { useEffect, useState, useCallback, useMemo } from 'react';
import { Separator } from '@/components/ui/separator';
import { useParams } from 'react-router-dom';
import { useAuth } from '@/contexts/auth-context';
import { useToast } from '@/hooks/use-toast';
import { Input } from '@/components/ui/input';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Label } from '@/components/ui/label';
import apiClient from '@/services/api-client';

interface Product { id: string; description: string; salePrice: number; costPrice?: number; barcode?: string; unitsPerBulto?: number; }
interface CartItem extends Product { quantity: number; }
interface Client { id: string; name: string; phone?: string; address?: string; }
const genericClient: Client = { id: 'generic', name: 'Cliente Genérico', phone: '', address: '' };

export default function VendorQuickSalePage() {
    const [cart, setCart] = useState<CartItem[]>([]);
    const [settings, setSettings] = useState<{ applyVAT: boolean }>({ applyVAT: false });
    const [selectedClient, setSelectedClient] = useState<Client>(genericClient);
    const [paymentType, setPaymentType] = useState<'Contado' | 'Crédito'>('Contado');
    const [isProcessing, setIsProcessing] = useState(false);
    const [isFinalizeDialogOpen, setIsFinalizeDialogOpen] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [searchResults, setSearchResults] = useState<Product[]>([]);

    const { storeId } = useParams<{ storeId: string }>();
    const { user } = useAuth();
    const { toast } = useToast();

    useEffect(() => {
        if (!storeId) return;
        apiClient.get(`/stores/${storeId}`).then(res => { if (res.data?.settings) setSettings(res.data.settings); }).catch(() => {});
    }, [storeId]);

    const handleSearch = async (term: string) => {
        setSearchTerm(term);
        if (term.length < 2) { setSearchResults([]); return; }
        try { const res = await apiClient.get('/products', { params: { storeId, search: term, limit: 10 } }); setSearchResults(res.data || []); } catch { setSearchResults([]); }
    };

    const handleAddProduct = useCallback((product: Product) => {
        setCart(prev => {
            const existing = prev.find(i => i.id === product.id);
            if (existing) return prev.map(i => i.id === product.id ? { ...i, quantity: i.quantity + 1 } : i);
            return [...prev, { ...product, quantity: 1 }];
        });
        setSearchTerm(''); setSearchResults([]);
    }, []);

    const handleQuantityChange = (productId: string, amount: number) => {
        setCart(prev => prev.map(i => i.id === productId ? { ...i, quantity: Math.max(0, i.quantity + amount) } : i).filter(i => i.quantity > 0));
    };

    const subtotal = useMemo(() => cart.reduce((acc, i) => acc + i.salePrice * i.quantity, 0), [cart]);
    const tax = useMemo(() => settings.applyVAT ? subtotal * 0.15 : 0, [subtotal, settings]);
    const total = useMemo(() => subtotal + tax, [subtotal, tax]);

    const resetSale = () => { setCart([]); setSelectedClient(genericClient); setPaymentType('Contado'); setIsFinalizeDialogOpen(false); };

    const handleFinalizeSale = async () => {
        if (!user) { toast({ variant: 'destructive', title: 'Error', description: 'No se pudo identificar al vendedor.' }); return; }
        if (cart.length === 0) { toast({ variant: 'destructive', title: 'Error', description: 'No hay productos.' }); return; }
        setIsProcessing(true);
        try {
            await apiClient.post('/orders', {
                storeId, vendorId: user.id, cashierName: user.name, clientId: selectedClient.id !== 'generic' ? selectedClient.id : undefined, clientName: selectedClient.name,
                items: cart.map(({ id, description, quantity, salePrice, costPrice }) => ({ productId: id, description, quantity, unitPrice: salePrice, costPrice: costPrice || 0 })),
                subtotal, tax, total, paymentType, status: paymentType === 'Crédito' ? 'Pendiente de Pago' : 'Pagada', type: 'venta_directa',
            });
            toast({ title: 'Venta Registrada' }); resetSale();
        } catch (error: any) { toast({ variant: 'destructive', title: 'Error', description: error?.response?.data?.message || 'No se pudo registrar.' }); }
        finally { setIsProcessing(false); }
    };

    return (
        <div className="grid md:grid-cols-3 gap-6 h-full">
            <div className="md:col-span-2 space-y-6">
                <Card><CardHeader><CardTitle>Buscar Producto</CardTitle></CardHeader><CardContent>
                    <Input placeholder="Buscar por nombre o código..." value={searchTerm} onChange={(e) => handleSearch(e.target.value)} />
                    {searchResults.length > 0 && (<div className="mt-2 border rounded-md max-h-48 overflow-y-auto">{searchResults.map(p => (
                        <div key={p.id} className="p-2 hover:bg-muted cursor-pointer flex justify-between" onClick={() => handleAddProduct(p)}><span>{p.description}</span><span className="text-muted-foreground">C$ {p.salePrice.toFixed(2)}</span></div>
                    ))}</div>)}
                </CardContent></Card>
                <Card><CardHeader><CardTitle>Cliente</CardTitle></CardHeader><CardContent>
                    <div className="mt-2 p-4 border rounded-lg bg-muted/30 flex items-center gap-4"><User className="h-8 w-8 text-muted-foreground" /><div><p className="font-semibold">{selectedClient.name}</p><p className="text-sm text-muted-foreground">{selectedClient.phone || 'Sin teléfono'}</p></div></div>
                </CardContent></Card>
            </div>
            <div className="relative flex flex-col h-full">
                <Card className="flex flex-col flex-grow"><CardHeader><CardTitle>Venta Rápida</CardTitle></CardHeader>
                    <CardContent className="flex-grow overflow-auto">
                        {cart.length > 0 ? (<Table><TableHeader><TableRow><TableHead>Producto</TableHead><TableHead className="text-center">Cant.</TableHead><TableHead className="text-right">Subtotal</TableHead></TableRow></TableHeader>
                            <TableBody>{cart.map(item => (<TableRow key={item.id}><TableCell><p className="font-medium truncate">{item.description}</p><p className="text-xs text-muted-foreground">C$ {item.salePrice.toFixed(2)}</p></TableCell>
                                <TableCell className="text-center"><div className="flex items-center justify-center gap-1"><Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => handleQuantityChange(item.id, -1)}><MinusCircle className="h-4 w-4" /></Button><span className="w-6 text-center">{item.quantity}</span><Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => handleQuantityChange(item.id, 1)}><PlusCircle className="h-4 w-4" /></Button></div></TableCell>
                                <TableCell className="text-right font-medium">C$ {(item.salePrice * item.quantity).toFixed(2)}</TableCell></TableRow>))}</TableBody></Table>)
                        : (<div className="flex flex-col items-center justify-center h-full text-center text-muted-foreground p-4"><ShoppingBag className="h-16 w-16 mb-4" /><p className="text-lg font-medium">Venta Vacía</p></div>)}
                    </CardContent>
                    {cart.length > 0 && (<div className="p-4 border-t mt-auto space-y-4 bg-background"><div className="space-y-2 text-sm">
                        <div className="flex justify-between"><span>Subtotal:</span><span>C$ {subtotal.toFixed(2)}</span></div>
                        {settings.applyVAT && <div className="flex justify-between"><span>IVA (15%):</span><span>C$ {tax.toFixed(2)}</span></div>}
                        <Separator /><div className="flex justify-between font-bold text-lg"><span>Total:</span><span>C$ {total.toFixed(2)}</span></div>
                    </div></div>)}
                </Card>
                {cart.length > 0 && (<div className="sticky bottom-0 bg-background border-t p-4">
                    <Dialog open={isFinalizeDialogOpen} onOpenChange={setIsFinalizeDialogOpen}>
                        <DialogTrigger asChild><Button className="w-full h-16 text-lg"><DollarSign className="mr-2 h-6 w-6" />Finalizar Venta</Button></DialogTrigger>
                        <DialogContent>
                            <DialogHeader><DialogTitle>Finalizar Venta</DialogTitle><DialogDescription>Confirma detalles.</DialogDescription></DialogHeader>
                            <div className="py-4 space-y-6">
                                <div className="text-center"><p className="text-sm text-muted-foreground">Total</p><p className="text-4xl font-bold">C$ {total.toFixed(2)}</p></div>
                                <div className="space-y-2"><Label>Tipo de Pago</Label>
                                    <RadioGroup value={paymentType} onValueChange={(v) => setPaymentType(v as 'Contado' | 'Crédito')} className="flex gap-4">
                                        <Label htmlFor="contado" className="flex items-center gap-2 border rounded-md p-3 flex-1 cursor-pointer"><RadioGroupItem value="Contado" id="contado" />Contado</Label>
                                        <Label htmlFor="credito" className="flex items-center gap-2 border rounded-md p-3 flex-1 cursor-pointer"><RadioGroupItem value="Crédito" id="credito" />Crédito</Label>
                                    </RadioGroup>
                                </div>
                            </div>
                            <DialogFooter><Button variant="ghost" onClick={() => setIsFinalizeDialogOpen(false)}>Cancelar</Button><Button onClick={handleFinalizeSale} disabled={isProcessing}>{isProcessing ? <Loader2 className="mr-2 animate-spin" /> : null}Registrar</Button></DialogFooter>
                        </DialogContent>
                    </Dialog>
                </div>)}
            </div>
        </div>
    );
}
