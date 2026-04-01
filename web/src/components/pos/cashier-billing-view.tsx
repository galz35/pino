
import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Search, Home, Trash2, Archive, Users, FolderOpen, Banknote, History, ShoppingBag, CreditCard, Printer } from 'lucide-react';
import { cn } from '@/lib/utils';
import type { Product, Client } from '@/types';
import { ProductSearch } from '@/components/pos/product-search';
import { UserSwitchDialog } from '@/components/auth/user-switch-dialog';
import { ClientSelectionDialog } from '@/components/pos/client-selection-dialog';
import { PaymentDialog, PaymentData } from '@/components/pos/payment-dialog';
import { PriceSelectionDialog } from '@/components/pos/price-selection-dialog';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { format } from 'date-fns';
import { Badge } from '@/components/ui/badge';
import { Link, useParams } from 'react-router-dom';
import { toast, alert } from '@/lib/swalert';
import { ReturnsDialog } from '@/components/pos/returns-dialog';
import { ProductGridNavigation } from '@/components/pos/product-grid-navigation';
import { TicketService } from '@/services/pos/ticket-service';
import apiClient from '@/services/api-client';

interface Order {
    id: string;
    timestamp: number;
    cart: any[];
    client: any;
    total: number;
}

interface CashierBillingViewProps {
    cart: (Product & { quantity: number, priceLabel?: string })[];
    total: number;
    subtotal: number;
    tax: number;
    onAddProduct: (product: Product, quantity: number) => void;
    onRemoveProduct: (productId: string) => void;
    onUpdateQuantity: (productId: string, quantity: number) => void;
    onSelectClient: (client: Client) => void;
    onFinalize: (data: PaymentData) => void;
    activeShift: any;
    onClearCart?: () => void;
    onSetCart?: (cart: (Product & { quantity: number, priceLabel?: string })[]) => void;
    client?: Client | null;
    lastSale?: any;
}

export function CashierBillingView({
    cart,
    total,
    subtotal,
    tax,
    onAddProduct,
    onUpdateQuantity,
    client,
    onSelectClient,
    onFinalize,
    activeShift,
    onClearCart,
    onSetCart,
    lastSale
}: CashierBillingViewProps) {
    const params = useParams();
    const storeId = params.storeId || activeShift?.storeId;
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedItems, setSelectedItems] = useState<Set<string>>(new Set());
    const [isSelectionMode, setIsSelectionMode] = useState(false);
    const [isHoldDialogOpen, setIsHoldDialogOpen] = useState(false);
    const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
    const [isUserSwitchOpen, setIsUserSwitchOpen] = useState(false);
    const [priceSelectionProduct, setPriceSelectionProduct] = useState<Product | null>(null);
    const [heldOrders, setHeldOrders] = useState<Order[]>([]);
    const [activeTab, setActiveTab] = useState<'products' | 'cart'>('products');
    const [storeSettings, setStoreSettings] = useState<any>(null);

    useEffect(() => {
        const stored = localStorage.getItem('held_orders');
        if (stored) {
            try {
                setHeldOrders(JSON.parse(stored));
            } catch (e) {
                console.error("Failed to parse held orders", e);
            }
        }
        
        // Cargar ajustes para impresión
        if (storeId) {
            apiClient.get(`/stores/${storeId}/settings`).then(res => setStoreSettings(res.data)).catch(() => {});
        }
    }, [storeId]);

    const saveHeldOrders = (orders: Order[]) => {
        localStorage.setItem('held_orders', JSON.stringify(orders));
        setHeldOrders(orders);
    };

    const handleHoldCurrentOrder = () => {
        if (cart.length === 0) {
            toast.error("Carrito vacío", "No hay productos para poner en espera.");
            return;
        }

        const newOrder: Order = {
            id: Date.now().toString(),
            timestamp: Date.now(),
            cart,
            client,
            total
        };

        const updatedOrders = [newOrder, ...heldOrders];
        saveHeldOrders(updatedOrders);

        if (onClearCart) onClearCart();
        toast.success("Orden en espera", "La orden ha sido guardada correctamente.");
    };

    const handleRetrieveOrder = (order: Order) => {
        if (onSetCart) onSetCart(order.cart);
        if (onSelectClient) onSelectClient(order.client);

        const updatedOrders = heldOrders.filter(o => o.id !== order.id);
        saveHeldOrders(updatedOrders);
        setIsHoldDialogOpen(false);
        toast.success("Orden recuperada", "La orden ha sido cargada al carrito.");
    };

    const handleClearCart = async () => {
        if (cart.length === 0) return;
        
        const result = await alert.confirm("¿Limpiar Carrito?", "¿Estás seguro de que deseas eliminar todos los productos?");
        if (result.isConfirmed) {
            if (onClearCart) onClearCart();
            toast.success("Carrito Limpiado");
        }
    };

    const handleToggleSelect = (productId: string) => {
        const newSelected = new Set(selectedItems);
        if (newSelected.has(productId)) {
            newSelected.delete(productId);
        } else {
            newSelected.add(productId);
        }
        setSelectedItems(newSelected);
    };

    const handleOpenDrawer = () => {
        toast.info("Gaveta Abierta", "Se ha enviado la señal de apertura.");
    };

    const handleInitiateAddProduct = (product: any) => {
        setPriceSelectionProduct(product);
    };

    const handlePriceSelected = (price: number, label: string) => {
        if (priceSelectionProduct) {
            onAddProduct({
                ...priceSelectionProduct,
                salePrice: price,
                priceLabel: label
            }, 1);
            setPriceSelectionProduct(null);
        }
    };

    const handleReprint = async () => {
        if (!lastSale) {
            toast.warning("Sin Venta Reciente", "No hay una venta previa para re-imprimir.");
            return;
        }
        
        toast.info("Imprimiendo...", "Enviando copia a la impresora.");
        TicketService.generateAndPrint({
            ...lastSale,
            settings: storeSettings,
            storeName: activeShift?.store?.name || 'MULTITIENDA'
        });
    };

    return (
        <div className="flex flex-col lg:flex-row h-screen w-full bg-slate-100 overflow-hidden font-sans pb-[60px] lg:pb-0">
            {/* LEFT COLUMN - TICKET */}
            <div className={cn(
                "w-full lg:w-[400px] flex flex-col bg-white border-r shadow-xl z-20 h-full transition-transform duration-300",
                activeTab === 'cart' ? "flex" : "hidden lg:flex"
            )}>

                <div className="bg-white p-3 border-b flex justify-between items-center shadow-sm z-10">
                    <div className="flex items-center gap-2">
                        <h2 className="font-bold text-xl text-slate-800 leading-none pl-2 italic">MultiTienda <span className="text-blue-600 font-black">POS</span></h2>
                    </div>
                    {lastSale && (
                        <Button variant="ghost" size="icon" onClick={handleReprint} className="h-9 w-9 bg-slate-50 hover:bg-blue-50 text-blue-600 hover:text-blue-700 rounded-xl transition-all shadow-sm">
                            <Printer className="h-5 w-5" />
                        </Button>
                    )}
                </div>

                <div className="bg-[#3b4150] text-white p-2 flex justify-between items-center text-xs font-black uppercase tracking-widest">
                    <div>
                        <span className="opacity-50 mr-2">TICKET:</span>
                        <span>{format(new Date(), 'HH:mm')}</span>
                    </div>
                    <div className="flex items-center gap-2">
                        <div
                            className="flex items-center gap-2 cursor-pointer select-none bg-white/10 px-2 py-1 rounded-md"
                            onClick={() => {
                                setIsSelectionMode(!isSelectionMode);
                                if (isSelectionMode) setSelectedItems(new Set());
                            }}
                        >
                            <span className={cn("inline-block w-3 h-3 border-2 border-white/30 rounded-full transition-all", isSelectionMode ? "bg-blue-400 border-white" : "")}></span>
                            <span className={cn("transition-opacity", isSelectionMode ? "opacity-100" : "opacity-60")}>Multiselect</span>
                        </div>
                    </div>
                </div>

                <div className="grid grid-cols-12 gap-1 px-4 py-2 bg-slate-50 border-b text-[10px] font-black text-slate-400 uppercase tracking-widest">
                    <div className="col-span-5">DETALLE PRODUCTO</div>
                    <div className="col-span-4 text-center">PRECIO UNIT.</div>
                    <div className="col-span-3 text-right">SUBTOTAL</div>
                </div>

                <div className="flex-1 overflow-y-auto bg-white relative scrollbar-thin scrollbar-thumb-slate-200">
                    {cart.map((item) => (
                        <div
                            key={item.id}
                            className={cn(
                                "grid grid-cols-12 gap-1 py-4 px-4 border-b text-sm items-center hover:bg-slate-50/80 transition-all group",
                                isSelectionMode && "cursor-pointer",
                                selectedItems.has(item.id) && "bg-blue-50 border-l-4 border-l-blue-500"
                            )}
                            onClick={() => isSelectionMode && handleToggleSelect(item.id)}
                        >
                            <div className="col-span-5">
                                <p className="font-black text-slate-800 leading-tight uppercase text-xs mb-1 group-hover:text-blue-700 transition-colors">{item.description}</p>
                                <div className="flex items-center gap-2">
                                     <Badge className="h-4 px-1.5 bg-slate-100 text-slate-500 font-mono text-[9px] border-none">{item.barcode || 'S/C'}</Badge>
                                     {item.priceLabel && <Badge className="h-4 px-1.5 bg-blue-50 text-blue-500 font-black text-[8px] border-none uppercase">{item.priceLabel}</Badge>}
                                </div>
                            </div>

                            <div className="col-span-4 flex flex-col items-center justify-center">
                                <div className="flex items-center border-2 border-slate-100 rounded-xl bg-white shadow-sm overflow-hidden h-9">
                                    <button
                                        type="button"
                                        className="w-8 h-full flex items-center justify-center hover:bg-slate-50 text-slate-400 hover:text-red-500 active:scale-95 transition-all font-black text-lg"
                                        onClick={(e) => { e.stopPropagation(); onUpdateQuantity(item.id, Math.max(0, item.quantity - 1)); }}
                                    >-</button>
                                    <span className="w-8 text-center font-black text-slate-800 text-xs">{item.quantity}</span>
                                    <button
                                        type="button"
                                        className="w-8 h-full flex items-center justify-center hover:bg-slate-50 text-slate-400 hover:text-emerald-500 active:scale-95 transition-all font-black text-lg"
                                        onClick={(e) => { e.stopPropagation(); onUpdateQuantity(item.id, item.quantity + 1); }}
                                    >+</button>
                                </div>
                                <span className="text-[9px] font-black text-slate-400 mt-1 uppercase italic">C$ {item.salePrice.toFixed(0)}</span>
                            </div>

                            <div className="col-span-3 text-right">
                                <p className="font-black text-slate-900 font-mono text-base tracking-tighter">C$ {(item.salePrice * item.quantity).toFixed(0)}</p>
                            </div>
                        </div>
                    ))}

                    {cart.length === 0 && (
                        <div className="flex flex-col items-center justify-center h-full text-slate-200">
                            <ShoppingBag className="h-20 w-20 mb-4 opacity-20" />
                            <p className="text-xs font-black uppercase tracking-[0.3em] italic opacity-40">Esperando Escaneo...</p>
                        </div>
                    )}
                </div>

                <div className="mt-auto bg-white border-t-2 border-slate-100 z-10 shadow-[0_-20px_40px_rgba(0,0,0,0.03)]">
                    <div className="px-6 py-4 bg-slate-50/50 space-y-2">
                        <div className="flex justify-between text-[11px] font-black text-slate-400 uppercase tracking-widest">
                            <span>Subtotal</span>
                            <span className="font-mono text-slate-600">C$ {subtotal.toFixed(2)}</span>
                        </div>
                        <div className="flex justify-between text-[11px] font-black text-slate-400 uppercase tracking-widest">
                            <span>Impuesto (IVA)</span>
                            <span className="font-mono text-slate-600">C$ {tax.toFixed(2)}</span>
                        </div>

                        <div className="flex justify-between items-center pt-3 mt-2 border-t-2 border-dashed border-slate-200 overflow-hidden relative">
                            <div className="flex flex-col">
                                <span className="text-[10px] font-black text-blue-500 uppercase tracking-widest italic">Total a Pagar</span>
                                <span className="text-[10px] font-bold text-slate-300 uppercase">Córdobas Netos</span>
                            </div>
                            <span className="text-4xl font-black text-slate-900 tracking-tighter font-mono">C$ {total.toFixed(0)}</span>
                            <div className="absolute -left-1 -bottom-4 h-12 w-12 bg-blue-500/5 rounded-full"></div>
                        </div>
                    </div>

                    <div className="p-3 border-t bg-white">
                        <div
                            className="bg-white rounded-2xl p-3 flex justify-between items-center cursor-pointer hover:bg-slate-50 active:scale-[0.98] transition-all border-2 border-slate-100 hover:border-blue-200 shadow-sm group"
                            onClick={() => document.getElementById('client-trigger-btn')?.click()}
                        >
                            <div className="flex items-center gap-4">
                                <div className="h-10 w-10 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center group-hover:bg-blue-600 group-hover:text-white transition-colors">
                                    <Users className="h-5 w-5" />
                                </div>
                                <div className="flex flex-col">
                                    <span className="text-[9px] font-black text-slate-400 uppercase tracking-widest">Cuenta de Cliente</span>
                                    <span className="font-black text-slate-700 truncate max-w-[180px] uppercase">{client?.name || 'CONSUMIDOR FINAL'}</span>
                                </div>
                            </div>
                            <div className="hidden">
                                <ClientSelectionDialog
                                    onSelectClient={onSelectClient}
                                    currentClient={client}
                                    trigger={<button type="button" id="client-trigger-btn">trigger</button>}
                                />
                            </div>
                        </div>
                    </div>

                    <div className="p-3 grid grid-cols-4 gap-2 h-[120px]">
                        <Button
                            className="h-full bg-red-500 hover:bg-red-600 text-white flex flex-col gap-1 rounded-2xl shadow-lg shadow-red-100 border-0 transition-all active:scale-95"
                            onClick={handleClearCart}
                        >
                            <Trash2 className="h-5 w-5" />
                            <span className="text-[9px] font-black uppercase tracking-tighter">ANULAR</span>
                        </Button>

                        <div className="flex flex-col gap-2 col-span-1 h-full">
                            <Button
                                className="flex-1 bg-amber-500 hover:bg-amber-600 text-white flex flex-col gap-1 rounded-2xl shadow-lg shadow-amber-50 border-0 p-0 transition-all active:scale-95"
                                onClick={handleHoldCurrentOrder}
                            >
                                <Archive className="h-4 w-4" />
                                <span className="text-[8px] font-black leading-none text-center uppercase tracking-tighter">EN ESPERA</span>
                            </Button>
                            <Button
                                className="flex-1 bg-slate-700 hover:bg-slate-800 text-white flex flex-col gap-1 rounded-2xl shadow-md border-0 p-0 transition-all active:scale-95"
                                onClick={() => setIsHoldDialogOpen(true)}
                            >
                                <History className="h-4 w-4" />
                                <span className="text-[8px] font-black leading-none text-center uppercase tracking-tighter">HISTORIAL</span>
                            </Button>
                        </div>

                        <div className="flex flex-col gap-2 col-span-1 h-full">
                            <ReturnsDialog />
                            <Button
                                className="flex-1 bg-white hover:bg-slate-50 text-slate-600 flex flex-col gap-1 rounded-2xl shadow-sm border-2 border-slate-100 p-0 transition-all active:scale-95"
                                onClick={() => setIsUserSwitchOpen(true)}
                            >
                                <Users className="h-4 w-4 text-blue-500" />
                                <span className="text-[8px] font-black leading-none text-center uppercase tracking-tighter">CAMBIAR<br />CAJA</span>
                            </Button>
                        </div>

                        <div className="flex flex-col gap-2 col-span-1 h-full">
                            <Button
                                className="flex-1 bg-blue-50 hover:bg-blue-100 text-blue-600 flex flex-col gap-1 rounded-2xl shadow-sm border-2 border-blue-100 p-0 transition-all active:scale-95"
                                onClick={handleOpenDrawer}
                            >
                                <FolderOpen className="h-4 w-4" />
                                <span className="text-[8px] font-black leading-none text-center uppercase tracking-tighter">GAVETA</span>
                            </Button>
                            <div className="flex-1"></div>
                        </div>
                    </div>

                    <div className="px-3 pb-4">
                        <Button
                            className="w-full h-16 bg-emerald-500 hover:bg-emerald-600 text-white shadow-xl shadow-emerald-100 rounded-3xl transition-all active:scale-95 group overflow-hidden relative"
                            onClick={() => setIsPaymentDialogOpen(true)}
                            disabled={cart.length === 0}
                        >
                            <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300"></div>
                            <Banknote className="h-8 w-8 mr-3 opacity-90 group-hover:scale-110 transition-transform" />
                            <span className="text-2xl font-black tracking-tighter uppercase italic">Finalizar Cobro</span>
                        </Button>
                    </div>

                </div>
            </div>

            {/* RIGHT COLUMN - WORKSPACE & PRODUCTS */}
            <div className={cn(
                "flex-1 flex flex-col h-full bg-white relative min-w-0 transition-all duration-500",
                activeTab === 'products' ? "flex" : "hidden lg:flex"
            )}>

                <div className="bg-white p-3 flex justify-between items-center border-b z-20 shrink-0">
                    <div className="flex items-center gap-3">
                         <Link to="/" className="h-12 w-12 bg-slate-100 hover:bg-blue-600 hover:text-white text-slate-400 rounded-2xl flex items-center justify-center transition-all shadow-inner border border-slate-200 group">
                            <Home className="h-6 w-6 group-hover:scale-110 transition-transform" />
                        </Link>
                        <h1 className="hidden md:block font-black uppercase text-xl text-slate-800 tracking-tighter italic mr-4">Inventario <span className="text-blue-600">POS</span></h1>
                    </div>

                    <div className="flex-1 max-w-xl relative group">
                        <div className="flex bg-slate-100 rounded-2xl overflow-hidden p-1.5 gap-2 items-center transition-all focus-within:bg-white focus-within:ring-4 focus-within:ring-blue-50 border-2 border-transparent focus-within:border-blue-200">
                             <div className="relative flex-1">
                                <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-slate-400" />
                                <input
                                    type="text"
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                    className="w-full bg-transparent border-none outline-none text-slate-800 font-black placeholder-slate-300 pl-10 text-base h-10 uppercase tracking-tight"
                                    placeholder="ESCANEAR O BUSCAR PRODUCTO..."
                                    autoFocus
                                />
                            </div>
                            <Button className="h-10 px-4 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-black shadow-lg shadow-blue-100">BUSCAR</Button>
                        </div>
                    </div>
                    
                    <div className="ml-4 flex items-center gap-3">
                         <Link to={`/store/${storeId}/products`} className="hidden md:flex h-12 px-5 bg-white border-2 border-slate-100 hover:border-blue-500 hover:bg-blue-50 text-slate-500 hover:text-blue-600 rounded-2xl items-center gap-2 font-black text-xs uppercase tracking-widest transition-all">
                             <Archive className="w-4 h-4" /> Stock
                         </Link>
                    </div>
                </div>

                <div className="flex-1 relative overflow-hidden flex flex-col bg-slate-50/50">
                    <div className="absolute inset-0 z-0 p-4">
                        <ProductGridNavigation
                            storeId={activeShift?.storeId || ''}
                            onProductSelect={handleInitiateAddProduct}
                            className="h-full w-full"
                        />
                    </div>

                    {searchTerm && (
                        <div className="absolute inset-0 z-10 bg-white/95 backdrop-blur-md animate-in fade-in duration-300">
                            <ProductSearch
                                onProductSelect={(p) => {
                                    handleInitiateAddProduct(p);
                                    setSearchTerm('');
                                }}
                                className="bg-transparent shadow-none border-none h-full"
                                hideSearchInput={true}
                                searchTerm={searchTerm}
                                hideHeader={true}
                            />
                        </div>
                    )}
                </div>
            </div>

            <PaymentDialog
                open={isPaymentDialogOpen}
                onOpenChange={setIsPaymentDialogOpen}
                total={total}
                onConfirm={(payment) => {
                    onFinalize(payment);
                    setIsPaymentDialogOpen(false);
                    // Disparar ticket automáticamente al finalizar si hay settings
                    if (payment) {
                        TicketService.generateAndPrint({
                            id: Date.now().toString().substring(5),
                            items: cart,
                            total,
                            subtotal,
                            discount: 0,
                            clientName: client?.name || 'CONSUMIDOR FINAL',
                            cashierName: activeShift?.user?.name || 'Cajero 01',
                            storeName: activeShift?.store?.name || 'MULTITIENDA',
                            paymentMethod: payment.method || 'EFECTIVO',
                            amountReceived: payment.amountReceived || total,
                            change: payment.change || 0,
                            settings: storeSettings
                        });
                    }
                }}
            />

            <Dialog open={isHoldDialogOpen} onOpenChange={setIsHoldDialogOpen}>
                <DialogContent className="max-w-3xl rounded-[40px] border-none shadow-2xl p-0 overflow-hidden">
                    <DialogHeader className="bg-slate-50 p-8">
                        <DialogTitle className="text-3xl font-black uppercase tracking-tighter text-slate-800 italic">Ventas en Lista de Espera</DialogTitle>
                        <DialogDescription className="font-bold text-slate-400 uppercase text-xs">Recupera tickets pausados anteriormente</DialogDescription>
                    </DialogHeader>

                    <div className="p-8 grid grid-cols-1 md:grid-cols-2 gap-4 max-h-[60vh] overflow-y-auto bg-white">
                        {heldOrders.length === 0 ? (
                            <div className="col-span-full text-center py-20 bg-slate-50 rounded-3xl border-2 border-dashed border-slate-200">
                                <History className="h-16 w-16 mx-auto mb-4 text-slate-200" />
                                <p className="font-black text-slate-300 uppercase italic">No hay órdenes pausadas</p>
                            </div>
                        ) : (
                            heldOrders.map((order) => (
                                <div key={order.id} className="border-2 border-slate-100 rounded-[30px] p-6 hover:border-blue-500 hover:shadow-xl transition-all group overflow-hidden relative">
                                    <div className="flex justify-between items-start mb-4">
                                        <div className="flex flex-col">
                                            <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Cliente</span>
                                            <span className="font-black text-slate-800 uppercase text-lg leading-tight">{order.client?.name || 'ANÓNIMO'}</span>
                                        </div>
                                        <Badge className="bg-slate-100 text-slate-500 font-bold border-none">{format(order.timestamp, 'HH:mm')}</Badge>
                                    </div>
                                    <div className="flex justify-between items-end border-t border-slate-100 pt-4">
                                        <p className="text-xs font-black text-blue-500 uppercase italic">{order.cart.length} Ítems</p>
                                        <p className="text-2xl font-black text-slate-800 font-mono tracking-tighter">C$ {order.total.toFixed(0)}</p>
                                    </div>
                                    <Button className="w-full mt-4 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-black uppercase tracking-tighter h-12 shadow-lg shadow-blue-100 transition-all active:scale-95" onClick={() => handleRetrieveOrder(order)}>Recuperar Órden</Button>
                                </div>
                            ))
                        )}
                    </div>
                </DialogContent>
            </Dialog>

            <UserSwitchDialog
                open={isUserSwitchOpen}
                onOpenChange={setIsUserSwitchOpen}
                trigger={<span className="hidden" />}
            />

            <PriceSelectionDialog
                isOpen={!!priceSelectionProduct}
                onClose={() => setPriceSelectionProduct(null)}
                onPriceSelected={handlePriceSelected}
                product={priceSelectionProduct as any}
            />

            <div className="lg:hidden fixed bottom-12 left-0 right-0 h-[70px] bg-white border-t-2 border-slate-100 shadow-[0_-10px_30px_rgba(0,0,0,0.1)] flex items-center justify-around z-50 rounded-t-[30px]">
                <button
                    onClick={() => setActiveTab('products')}
                    className={cn(
                        "flex flex-col items-center gap-1 p-2 transition-all",
                        activeTab === 'products' ? "text-blue-600 scale-110" : "text-slate-300"
                    )}
                >
                    <div className="h-10 w-10 flex items-center justify-center rounded-2xl bg-current/5">
                        <ShoppingBag className="h-6 w-6" />
                    </div>
                    <span className="text-[9px] font-black uppercase tracking-widest">Stock</span>
                </button>
                <div className="h-12 w-[2px] bg-slate-100"></div>
                <button
                    onClick={() => setActiveTab('cart')}
                    className={cn(
                        "flex flex-col items-center gap-1 p-2 transition-all relative",
                        activeTab === 'cart' ? "text-emerald-500 scale-110" : "text-slate-300"
                    )}
                >
                    <div className="h-10 w-10 flex items-center justify-center rounded-2xl bg-current/5 relative">
                        <CreditCard className="h-6 w-6" />
                        {cart.length > 0 && (
                            <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[9px] rounded-full w-4 h-4 flex items-center justify-center font-black shadow-lg shadow-red-200 animate-bounce">
                                {cart.length}
                            </span>
                        )}
                    </div>
                    <span className="text-[9px] font-black uppercase tracking-widest">Carrito</span>
                </button>
            </div>
        </div>
    );
}
