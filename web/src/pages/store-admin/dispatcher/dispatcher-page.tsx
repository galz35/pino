import { Button } from '@/components/ui/button';
import {
    Card, CardContent, CardDescription, CardHeader, CardTitle,
} from '@/components/ui/card';
import {
    Table, TableBody, TableCell, TableHead, TableHeader, TableRow,
} from '@/components/ui/table';
import { MinusCircle, PlusCircle, User, ShoppingBag, SendToBack } from 'lucide-react';
import { useEffect, useState, useCallback } from 'react';
import { Separator } from '@/components/ui/separator';
import { useParams } from 'react-router-dom';
import { useAuth } from '@/contexts/auth-context';
import { useToast } from '@/hooks/use-toast';
import { Input } from '@/components/ui/input';
import apiClient from '@/services/api-client';

interface Product {
    id: string;
    description: string;
    barcode: string;
    salePrice: number;
    costPrice?: number;
    currentStock?: number;
    usesInventory?: boolean;
}

interface CartItem extends Product {
    quantity: number;
}

interface Client {
    id: string;
    name: string;
    phone?: string;
    address?: string;
}

const genericClient: Client = { id: 'generic', name: 'Cliente Genérico', phone: '', address: '' };

export default function DispatcherPage() {
    const [cart, setCart] = useState<CartItem[]>([]);
    const [settings, setSettings] = useState<{ applyVAT: boolean }>({ applyVAT: false });
    const [selectedClient, setSelectedClient] = useState<Client>(genericClient);
    const [isProcessing, setIsProcessing] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [searchResults, setSearchResults] = useState<Product[]>([]);

    const { storeId } = useParams<{ storeId: string }>();
    const { user } = useAuth();
    const { toast } = useToast();

    useEffect(() => {
        if (!storeId) return;
        const fetchSettings = async () => {
            try {
                const res = await apiClient.get(`/stores/${storeId}`);
                if (res.data?.settings) setSettings(res.data.settings);
            } catch (err) { console.error(err); }
        };
        fetchSettings();
    }, [storeId]);

    const handleSearch = async (term: string) => {
        setSearchTerm(term);
        if (term.length < 2) { setSearchResults([]); return; }
        try {
            const res = await apiClient.get('/products', { params: { storeId, search: term, limit: 10 } });
            setSearchResults(res.data || []);
        } catch { setSearchResults([]); }
    };

    const handleAddProduct = useCallback((product: Product) => {
        setCart((prevCart) => {
            const existing = prevCart.find((item) => item.id === product.id);
            if (existing) {
                return prevCart.map((item) =>
                    item.id === product.id ? { ...item, quantity: item.quantity + 1 } : item
                );
            }
            return [...prevCart, { ...product, quantity: 1 }];
        });
        setSearchTerm('');
        setSearchResults([]);
    }, []);

    const handleQuantityChange = (productId: string, amount: number) => {
        setCart((prevCart) =>
            prevCart.map((item) =>
                item.id === productId ? { ...item, quantity: Math.max(0, item.quantity + amount) } : item
            ).filter((item) => item.quantity > 0)
        );
    };

    const subtotal = cart.reduce((acc, item) => acc + item.salePrice * item.quantity, 0);
    const tax = settings?.applyVAT ? subtotal * 0.15 : 0;
    const total = subtotal + tax;

    const resetOrder = () => { setCart([]); setSelectedClient(genericClient); };

    const handleSendCommand = async () => {
        if (!user) { toast({ variant: 'destructive', title: 'Error', description: 'No se pudo identificar al despachador.' }); return; }
        if (cart.length === 0) { toast({ variant: 'destructive', title: 'Error', description: 'No hay productos en la comanda.' }); return; }

        setIsProcessing(true);
        try {
            await apiClient.post('/pending-orders', {
                storeId,
                dispatcherId: user.id,
                dispatcherName: user.name,
                clientId: selectedClient.id !== 'generic' ? selectedClient.id : undefined,
                clientName: selectedClient.name,
                items: cart.map(({ id, description, quantity, salePrice, costPrice }) => ({ productId: id, description, quantity, unitPrice: salePrice, costPrice: costPrice || 0 })),
                subtotal, tax, total,
                status: 'Pendiente',
            });
            toast({ title: 'Comanda Enviada', description: `La comanda para ${selectedClient.name} está lista para ser cobrada.` });
            resetOrder();
        } catch (error) {
            console.error(error);
            toast({ variant: 'destructive', title: 'Error al Enviar', description: 'No se pudo enviar la comanda.' });
        } finally {
            setIsProcessing(false);
        }
    };

    return (
        <div className="grid md:grid-cols-3 gap-6 h-full">
            <div className="md:col-span-2 space-y-6">
                {/* Product Search */}
                <Card>
                    <CardHeader><CardTitle>Buscar Producto</CardTitle></CardHeader>
                    <CardContent>
                        <Input placeholder="Buscar por nombre o código de barra..." value={searchTerm} onChange={(e) => handleSearch(e.target.value)} />
                        {searchResults.length > 0 && (
                            <div className="mt-2 border rounded-md max-h-48 overflow-y-auto">
                                {searchResults.map(p => (
                                    <div key={p.id} className="p-2 hover:bg-muted cursor-pointer flex justify-between" onClick={() => handleAddProduct(p)}>
                                        <span>{p.description}</span>
                                        <span className="text-muted-foreground">C$ {p.salePrice.toFixed(2)}</span>
                                    </div>
                                ))}
                            </div>
                        )}
                    </CardContent>
                </Card>

                {/* Client */}
                <Card>
                    <CardHeader><CardTitle>Cliente</CardTitle><CardDescription>Busca o selecciona un cliente para asociar la comanda.</CardDescription></CardHeader>
                    <CardContent>
                        <div className="mt-2 p-4 border rounded-lg bg-muted/30 flex items-center gap-4">
                            <User className="h-8 w-8 text-muted-foreground" />
                            <div><p className="font-semibold">{selectedClient.name}</p><p className="text-sm text-muted-foreground">{selectedClient.phone || 'Sin teléfono'}</p></div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            <div className="relative flex flex-col h-full">
                <Card className="flex flex-col flex-grow">
                    <CardHeader><CardTitle>Comanda Actual</CardTitle></CardHeader>
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
                                                <p className="text-xs text-muted-foreground">C$ {item.salePrice.toFixed(2)}</p>
                                            </TableCell>
                                            <TableCell className="text-center align-middle">
                                                <div className="flex items-center justify-center gap-1">
                                                    <Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => handleQuantityChange(item.id, -1)}>
                                                        <MinusCircle className="h-4 w-4" />
                                                    </Button>
                                                    <span className="w-6 text-center">{item.quantity}</span>
                                                    <Button variant="ghost" size="icon" className="h-6 w-6" onClick={() => handleQuantityChange(item.id, 1)}>
                                                        <PlusCircle className="h-4 w-4" />
                                                    </Button>
                                                </div>
                                            </TableCell>
                                            <TableCell className="text-right font-medium">C$ {(item.salePrice * item.quantity).toFixed(2)}</TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        ) : (
                            <div className="flex flex-col items-center justify-center h-full text-center text-muted-foreground p-4">
                                <ShoppingBag className="h-16 w-16 mb-4" />
                                <p className="mb-4 text-lg font-medium">Comanda Vacía</p>
                                <p className="text-sm">Agrega productos para iniciar una comanda.</p>
                            </div>
                        )}
                    </CardContent>

                    {cart.length > 0 && (
                        <div className="p-4 border-t mt-auto space-y-4 bg-background">
                            <div className="space-y-2 text-sm">
                                <div className="flex justify-between"><span>Subtotal:</span><span>C$ {subtotal.toFixed(2)}</span></div>
                                {settings?.applyVAT && (<div className="flex justify-between"><span>IVA (15%):</span><span>C$ {tax.toFixed(2)}</span></div>)}
                                <Separator />
                                <div className="flex justify-between font-bold text-lg"><span>Total a Pagar:</span><span>C$ {total.toFixed(2)}</span></div>
                            </div>
                        </div>
                    )}
                </Card>
                {cart.length > 0 && (
                    <div className="sticky bottom-0 bg-background border-t p-4">
                        <Button className="w-full h-16 text-lg" disabled={isProcessing || cart.length === 0} onClick={handleSendCommand}>
                            <SendToBack className="mr-2 h-6 w-6" />
                            Comandar
                        </Button>
                    </div>
                )}
            </div>
        </div>
    );
}
