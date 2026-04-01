import { createContext, useContext, useState, ReactNode, useMemo } from 'react';
import { Product } from '../types';

export interface CartItem extends Product {
    uniqueId: string; // for React keys
    quantity: number;
}

interface PosContextType {
    cart: CartItem[];
    addToCart: (product: Product) => void;
    removeFromCart: (uniqueId: string) => void;
    clearCart: () => void;
    mode: 'products' | 'payment';
    setMode: (mode: 'products' | 'payment') => void;
    handleHoldBill: () => void;
    handleCreditNoteClick: () => void;
    setIsHeldBillsOpen: (open: boolean) => void;
    isHeldBillsOpen: boolean;
    setShowQuickSwitch: (open: boolean) => void;
    showQuickSwitch: boolean;
    handleOpenDrawer: () => void;
    handlePayment: () => void;
    client: { name: string; id?: string } | null;
    setClient: (client: { name: string; id?: string } | null) => void;
    isLoading: boolean;
    setIsLoading: (loading: boolean) => void;
}

const PosContext = createContext<PosContextType | undefined>(undefined);

export function PosProvider({ children }: { children: ReactNode }) {
    const [cart, setCart] = useState<CartItem[]>([]);
    const [mode, setMode] = useState<'products' | 'payment'>('products');
    const [isHeldBillsOpen, setIsHeldBillsOpen] = useState(false);
    const [showQuickSwitch, setShowQuickSwitch] = useState(false);
    const [client, setClient] = useState<{ name: string; id?: string } | null>(null);
    const [isLoading, setIsLoading] = useState(false);

    const addToCart = (product: Product) => {
        setCart((prev) => {
            const existing = prev.find((item) => item.id === product.id);
            if (existing) {
                return prev.map((item) =>
                    item.id === product.id
                        ? { ...item, quantity: item.quantity + 1 }
                        : item
                );
            }
            return [...prev, { ...product, quantity: 1, uniqueId: crypto.randomUUID() }];
        });
    };

    const removeFromCart = (uniqueId: string) => {
        setCart((prev) => prev.filter((item) => item.uniqueId !== uniqueId));
    };

    const clearCart = () => {
        if (confirm("¿Estás seguro de limpiar el carrito?")) {
            setCart([]);
        }
    };

    const handleHoldBill = () => {
        setCart([]);
        setMode('products');
    };

    const handleCreditNoteClick = () => {
        // TODO: Implementar nota de crédito
    };

    const handleOpenDrawer = () => {
        // TODO: Integrar con hardware de caja
    };

    const handlePayment = () => {
        setMode('payment');
    };

    const contextValue = useMemo(() => ({
        cart,
        addToCart,
        removeFromCart,
        clearCart,
        mode,
        setMode,
        handleHoldBill,
        handleCreditNoteClick,
        setIsHeldBillsOpen,
        isHeldBillsOpen,
        setShowQuickSwitch,
        showQuickSwitch,
        handleOpenDrawer,
        handlePayment,
        client,
        setClient,
        isLoading,
        setIsLoading,
    }), [
        cart,
        mode,
        isHeldBillsOpen,
        showQuickSwitch,
        client,
        isLoading,
        // function refs are stable since they aren't recreation on render now
        addToCart,
        removeFromCart,
        clearCart,
        handleHoldBill,
        handlePayment
    ]);

    return (
        <PosContext.Provider value={contextValue}>
            {children}
        </PosContext.Provider>
    );
}

export function usePos() {
    const context = useContext(PosContext);
    if (context === undefined) {
        throw new Error('usePos must be used within a PosProvider');
    }
    return context;
}
