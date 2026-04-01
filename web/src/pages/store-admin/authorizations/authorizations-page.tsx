import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { ShieldCheck, ShieldAlert, Clock, User, DollarSign, CheckCircle2, XCircle } from "lucide-react";
import { useParams } from "react-router-dom";
import { useEffect, useState } from 'react';
import apiClient from '@/services/api-client';
import { useToast } from '@/hooks/use-toast';
import { cn } from '@/lib/utils';

interface AuthorizationRequest {
    id: string;
    storeId: string;
    requesterId: string;
    type: string;
    details: {
        clientName?: string;
        creditLimit?: number;
        [key: string]: any;
    };
    status: 'PENDING' | 'APPROVED' | 'REJECTED';
    createdAt: any;
}

export default function AuthorizationsPage() {
    const { storeId } = useParams<{ storeId: string }>();
    const { toast } = useToast();

    const [requests, setRequests] = useState<AuthorizationRequest[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const fetchRequests = async () => {
        try {
            const response = await apiClient.get('/authorizations', {
                params: { storeId, status: 'PENDING' }
            });
            setRequests(response.data);
        } catch (err) {
            console.error(err);
            setError("No se pudieron cargar las autorizaciones.");
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        if (!storeId) return;
        fetchRequests();
        const interval = setInterval(fetchRequests, 15000);
        return () => clearInterval(interval);
    }, [storeId]);

    const handleAction = async (requestId: string, status: 'APPROVED' | 'REJECTED') => {
        try {
            await apiClient.patch(`/authorizations/${requestId}/status`, { status });
            toast({
                title: status === 'APPROVED' ? 'Solicitud Aprobada' : 'Solicitud Rechazada',
                description: `La solicitud ha sido ${status === 'APPROVED' ? 'autorizada' : 'denegada'} exitosamente.`,
                variant: status === 'APPROVED' ? 'default' : 'destructive',
            });
            setRequests(prev => prev.filter(r => r.id !== requestId));
        } catch (err) {
            console.error(err);
            toast({ title: 'Error', description: 'No se pudo procesar la solicitud.', variant: 'destructive' });
        }
    };

    if (loading) {
        return (
            <div className="space-y-4">
                <Skeleton className="h-10 w-64" />
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {[1, 2, 3].map(i => (
                        <Card key={i}>
                            <CardHeader><Skeleton className="h-6 w-3/4" /><Skeleton className="h-4 w-1/2" /></CardHeader>
                            <CardContent><Skeleton className="h-20 w-full" /></CardContent>
                        </Card>
                    ))}
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <Alert variant="destructive">
                <ShieldAlert className="h-4 w-4" />
                <AlertTitle>Error</AlertTitle>
                <AlertDescription>{error}</AlertDescription>
            </Alert>
        );
    }

    return (
        <div className="space-y-6">
            <div>
                <h1 className="text-3xl font-bold tracking-tight">Autorizaciones en Tiempo Real</h1>
                <p className="text-muted-foreground">
                    Gestiona las solicitudes de límites de crédito y otros permisos especiales.
                </p>
            </div>

            {requests.length === 0 ? (
                <div className="flex flex-col items-center justify-center py-20 bg-muted/20 rounded-xl border-2 border-dashed">
                    <CheckCircle2 className="h-12 w-12 text-muted-foreground/50 mb-4" />
                    <h3 className="text-lg font-medium">No hay solicitudes pendientes</h3>
                    <p className="text-sm text-muted-foreground">Todas las peticiones han sido procesadas.</p>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {requests.map((request) => (
                        <Card key={request.id} className="overflow-hidden border-2 border-primary/10 hover:border-primary/30 transition-all shadow-md">
                            <CardHeader className="bg-muted/30 pb-4">
                                <div className="flex justify-between items-start">
                                    <Badge variant="outline" className="bg-primary/10 text-primary border-primary/20">
                                        <ShieldCheck className="w-3 h-3 mr-1" />
                                        {request.type === 'creditLimit' ? 'Límite de Crédito' : request.type}
                                    </Badge>
                                    <div className="text-xs text-muted-foreground flex items-center">
                                        <Clock className="w-3 h-3 mr-1" />
                                        {request.createdAt ? new Date(request.createdAt).toLocaleTimeString() : 'Ahora'}
                                    </div>
                                </div>
                                <CardTitle className="mt-2 flex items-center gap-2">
                                    <User className="h-4 w-4 text-muted-foreground" />
                                    {request.details.clientName || 'Cliente sin nombre'}
                                </CardTitle>
                                <CardDescription>
                                    Solicitud de {request.type === 'creditLimit' ? 'crédito especial' : 'permiso'}
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="pt-6 space-y-4">
                                <div className="bg-primary/5 p-4 rounded-lg flex items-center justify-between border border-primary/10">
                                    <div className="flex items-center gap-2">
                                        <DollarSign className="h-5 w-5 text-primary" />
                                        <span className="text-sm font-medium text-muted-foreground">Monto Solicitado:</span>
                                    </div>
                                    <span className="text-xl font-bold text-primary">
                                        C$ {request.details.creditLimit?.toLocaleString() || '0'}
                                    </span>
                                </div>

                                <div className="grid grid-cols-2 gap-3 pt-2">
                                    <Button
                                        variant="outline"
                                        className="border-destructive text-destructive hover:bg-destructive hover:text-white"
                                        onClick={() => handleAction(request.id, 'REJECTED')}
                                    >
                                        <XCircle className="w-4 h-4 mr-2" />
                                        Rechazar
                                    </Button>
                                    <Button
                                        className="bg-green-600 hover:bg-green-700 text-white"
                                        onClick={() => handleAction(request.id, 'APPROVED')}
                                    >
                                        <CheckCircle2 className="w-4 h-4 mr-2" />
                                        Aprobar
                                    </Button>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}
        </div>
    );
}
