
import {
    Trash2,
    FileText,
    CreditCard,
    ListOrdered,
    User as UserIcon,
    FolderOpen
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { usePos } from '@/context/pos-context';
import { useEffect, useCallback } from 'react';

interface DashboardButtonProps {
    label: string | React.ReactNode;
    icon: React.ReactNode;
    onClick: () => void;
    className?: string; // For background colors
    colSpan?: string;
    shortcut?: string;
}

function DashboardButton({ label, icon, onClick, className, colSpan, shortcut }: DashboardButtonProps) {
    return (
        <button
            onClick={onClick}
            className={cn(
                "flex flex-col items-center justify-center text-white font-bold rounded shadow-sm hover:opacity-90 active:scale-95 transition-all",
                "h-12", // Default height
                "text-[10px] leading-tight text-center p-1",
                className,
                colSpan
            )}
            title={shortcut ? `Atajo: ${shortcut}` : undefined}
        >
            <div className="mb-0.5">{icon}</div>
            <span className="whitespace-pre-line">{label}</span>
        </button>
    );
}

export function CompactDashboard() {
    const {
        clearCart,
        handleHoldBill,
        handleCreditNoteClick,
        setIsHeldBillsOpen,
        setShowQuickSwitch,
        handleOpenDrawer,
        handlePayment,
        setIsLoading
    } = usePos();

    const withLoading = useCallback((action: () => void) => {
        return async () => {
            setIsLoading(true);
            await new Promise(resolve => setTimeout(resolve, 800)); // Simulate 800ms delay
            action();
            setIsLoading(false);
        };
    }, [setIsLoading]);

    // Keyboard shortcuts
    useEffect(() => {
        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.key === 'Delete') withLoading(clearCart)();
            if (e.key === 'F2') withLoading(handleHoldBill)();
            if (e.key === 'F3') withLoading(handleCreditNoteClick)();
            if (e.key === 'F10') setIsHeldBillsOpen(true);
            if (e.key === 'F1') withLoading(handlePayment)();
            // Add more as needed
        };

        window.addEventListener('keydown', handleKeyDown);
        return () => window.removeEventListener('keydown', handleKeyDown);
    }, [clearCart, handleHoldBill, handleCreditNoteClick, setIsHeldBillsOpen, handlePayment, withLoading]);

    return (
        <div className="grid grid-cols-3 gap-1.5 p-2 bg-white border-t shrink-0">
            <DashboardButton
                label="LIMPIAR"
                icon={<Trash2 className="h-4 w-4" />}
                onClick={withLoading(clearCart)}
                className="bg-[#FF5722]"
                shortcut="Del"
            />
            <DashboardButton
                label="PONER EN ESPERA"
                icon={<FileText className="h-4 w-4" />}
                onClick={withLoading(handleHoldBill)}
                className="bg-[#673AB7]"
                shortcut="F2"
            />
            <DashboardButton
                label="NOTA DE CRÉDITO"
                icon={<CreditCard className="h-4 w-4" />}
                onClick={withLoading(handleCreditNoteClick)}
                className="bg-[#673AB7]"
                shortcut="F3"
            />
            <DashboardButton
                label="VER FACS EN ESPERA"
                icon={<ListOrdered className="h-4 w-4" />}
                onClick={() => setIsHeldBillsOpen(true)}
                className="bg-[#673AB7]"
                shortcut="F10"
            />
            <DashboardButton
                label="CAMBIO USUARIO"
                icon={<UserIcon className="h-4 w-4" />}
                onClick={() => setShowQuickSwitch(true)}
                className="bg-[#2196F3]"
            />
            <DashboardButton
                label="ABRIR GAVETA"
                icon={<FolderOpen className="h-4 w-4" />}
                onClick={withLoading(handleOpenDrawer)}
                className="bg-[#607D8B]"
            />

            {/* Main Payment Button */}
            <DashboardButton
                label="COBRAR"
                icon={<CreditCard className="h-5 w-5" />}
                onClick={withLoading(handlePayment)}
                className="bg-[#8BC34A] text-lg h-auto" // Making it bigger/prominent
                colSpan="col-span-3"
                shortcut="F1"
            />
        </div>
    );
}
