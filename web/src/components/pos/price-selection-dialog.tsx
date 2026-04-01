import { useState } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Lock, Tag } from 'lucide-react';
import { AdminAuthDialog } from '../auth/admin-auth-dialog';
import { formatCurrency } from '@/lib/utils';

export interface ProductWithPrices {
    id: string;
    description: string;
    price1: number;
    price2: number;
    price3?: number;
    price4?: number;
    price5?: number;
    salePrice?: number;
}

interface PriceSelectionDialogProps {
    isOpen: boolean;
    onClose: () => void;
    onPriceSelected: (price: number, priceLabel: string) => void;
    product: ProductWithPrices | null;
}

export function PriceSelectionDialog({
    isOpen,
    onClose,
    onPriceSelected,
    product
}: PriceSelectionDialogProps) {
    const [authDialogOpen, setAuthDialogOpen] = useState(false);
    const [pendingPrice, setPendingPrice] = useState<{ price: number, label: string } | null>(null);

    if (!product) return null;

    const prices = [
        { level: 1, label: 'Precio 1 (General)', value: product.price1 || product.salePrice || 0, restricted: false },
        { level: 2, label: 'Precio 2 (Oferta)', value: product.price2 || 0, restricted: false },
        { level: 3, label: 'Precio 3 (Mayoreo)', value: product.price3 || 0, restricted: false },
        { level: 4, label: 'Precio 4 (Especial)', value: product.price4 || 0, restricted: true },
        { level: 5, label: 'Precio 5 (Mínimo)', value: product.price5 || 0, restricted: true },
    ].filter(p => p.level <= 3 || p.value > 0);

    const handleSelect = (priceItem: typeof prices[0]) => {
        if (priceItem.value <= 0) return;

        if (priceItem.restricted) {
            setPendingPrice({ price: priceItem.value, label: priceItem.label });
            setAuthDialogOpen(true);
        } else {
            onPriceSelected(priceItem.value, priceItem.label);
            onClose();
        }
    };

    const handleAuthSuccess = () => {
        if (pendingPrice) {
            onPriceSelected(pendingPrice.price, pendingPrice.label);
            setAuthDialogOpen(false);
            setPendingPrice(null);
            onClose();
        }
    };


    return (
        <>
            <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
                <DialogContent className="sm:max-w-lg border-none shadow-2xl bg-white">
                    <DialogHeader>
                        <DialogTitle className="flex items-center gap-3 text-slate-800 text-2xl font-black uppercase tracking-tight">
                            <Tag className="w-8 h-8 text-purple-600" />
                            Seleccionar Precio
                        </DialogTitle>
                        <DialogDescription className="text-lg bg-slate-50 p-2 rounded border border-slate-100 font-bold text-slate-700">
                            {product.description}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="grid gap-3 py-4">
                        {prices.map((price) => (
                            <Button
                                key={price.level}
                                variant={price.restricted ? "outline" : "secondary"}
                                disabled={price.value <= 0}
                                className={`h-20 flex justify-between items-center px-8 text-lg transition-all shadow-md active:scale-95 ${price.restricted
                                    ? 'border-red-200 border-2 hover:bg-red-50 text-red-700'
                                    : 'hover:bg-blue-600 hover:text-white bg-blue-50 text-blue-700'
                                    }`}
                                onClick={() => handleSelect(price)}
                            >
                                <div className="flex flex-col items-start gap-0.5">
                                    <span className="text-xs font-black uppercase opacity-60 tracking-wider font-mono">{price.label}</span>
                                    <span className="font-black text-3xl font-mono">{formatCurrency(price.value)}</span>
                                </div>
                                {price.restricted && (
                                    <Lock className="w-6 h-6 animate-pulse" />
                                )}
                            </Button>
                        ))}
                    </div>

                    <DialogFooter>
                        <Button variant="ghost" onClick={onClose} className="w-full text-slate-400 font-bold">
                            CANCELAR
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            <AdminAuthDialog
                isOpen={authDialogOpen}
                onClose={() => setAuthDialogOpen(false)}
                onConfirm={handleAuthSuccess}
                title="Autorización Requerida"
                description={`Para aplicar el ${pendingPrice?.label} se requiere PIN de administrador.`}
            />
        </>
    );
}
