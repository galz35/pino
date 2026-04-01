import { useState } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Lock } from 'lucide-react';
import { useParams } from 'react-router-dom';
import apiClient from '@/services/api-client';

interface AdminAuthDialogProps {
    isOpen: boolean;
    onClose: () => void;
    onConfirm: () => void;
    title?: string;
    description?: string;
    requiredRole?: 'admin' | 'owner';
}

export function AdminAuthDialog({
    isOpen,
    onClose,
    onConfirm,
    title = "Autorización Requerida",
    description = "Esta acción requiere permisos de administrador. Por favor ingrese su clave.",
}: AdminAuthDialogProps) {
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const params = useParams();
    const storeId = params.storeId as string;

    const handleConfirm = async () => {
        setIsLoading(true);
        setError('');

        try {
            if (!storeId) {
                setError('Error: No se identificó la tienda.');
                return;
            }

            // En MultiTienda v2, validamos el PIN contra el backend NestJS
            const response = await apiClient.post(`/stores/${storeId}/validate-pin`, { pin: password });

            if (response.data.valid) {
                onConfirm();
                onClose();
                setPassword('');
            } else {
                setError('PIN incorrecto');
            }

        } catch (err: any) {
            console.error("Auth error:", err);
            setError(err.response?.data?.message || 'Error de validación');
        } finally {
            setIsLoading(false);
        }
    };

    const handleKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter') {
            handleConfirm();
        }
    };

    return (
        <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
            <DialogContent className="sm:max-w-md">
                <DialogHeader>
                    <div className="mx-auto bg-red-100 p-3 rounded-full mb-2">
                        <Lock className="h-6 w-6 text-red-600" />
                    </div>
                    <DialogTitle className="text-center">{title}</DialogTitle>
                    <DialogDescription className="text-center">
                        {description}
                    </DialogDescription>
                </DialogHeader>

                <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                        <Label htmlFor="admin-password">Contraseña de Administrador (PIN)</Label>
                        <Input
                            id="admin-password"
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            onKeyDown={handleKeyDown}
                            placeholder="Ingrese PIN..."
                            autoFocus
                        />
                        {error && <p className="text-sm text-red-500 font-medium">{error}</p>}
                    </div>
                </div>

                <DialogFooter className="sm:justify-between flex-row gap-2">
                    <Button
                        type="button"
                        variant="secondary"
                        className="flex-1"
                        onClick={onClose}
                    >
                        Cancelar
                    </Button>
                    <Button
                        type="button"
                        className="flex-1 bg-red-600 hover:bg-red-700 text-white shadow-lg"
                        onClick={handleConfirm}
                        disabled={isLoading || !password}
                    >
                        {isLoading ? 'Verificando...' : 'Autorizar'}
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}
