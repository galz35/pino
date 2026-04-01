import apiClient from '@/services/api-client';
import { useToast } from '@/hooks/use-toast';
import { ToastAction } from '@/components/ui/toast';
import { useAuth } from '@/contexts/auth-context';
import { useEffect, useRef } from 'react';

export function GlobalAlertProvider() {
    const { toast } = useToast();
    const audioRef = useRef<HTMLAudioElement | null>(null);
    const previousAlertIds = useRef<Set<string>>(new Set());
    const { user } = useAuth();

    useEffect(() => {
        audioRef.current = new Audio('/sounds/ping.mp3');
        audioRef.current.load();
    }, []);

    useEffect(() => {
        if (!user) return;

        const fetchAlerts = async () => {
            try {
                const res = await apiClient.get('/authorizations', { params: { status: 'pending' } });
                const alerts = res.data || [];

                for (const alert of alerts) {
                    if (!previousAlertIds.current.has(alert.id)) {
                        previousAlertIds.current.add(alert.id);
                        if (previousAlertIds.current.size <= alerts.length) continue;

                        audioRef.current?.play().catch((e) => {
                            console.warn("Audio alerta bloqueado:", e);
                        });

                        toast({
                            title: 'Alerta Administrativa',
                            description: `Nueva solicitud de autorización recibida.`,
                            duration: Infinity,
                            variant: "destructive",
                            action: (
                                <div className="flex flex-col gap-2 sm:flex-row">
                                    <ToastAction
                                        altText="Aprobar"
                                        className="bg-green-600 text-white hover:bg-green-700 border-green-700"
                                        onClick={() => handleAction(alert.id, 'APPROVED')}
                                    >
                                        APROBAR
                                    </ToastAction>
                                    <ToastAction
                                        altText="Rechazar"
                                        className="bg-red-600 text-white hover:bg-red-700 border-red-700"
                                        onClick={() => handleAction(alert.id, 'REJECTED')}
                                    >
                                        RECHAZAR
                                    </ToastAction>
                                </div>
                            ),
                        });
                    }
                }
            } catch (err) {
                // silent
            }
        };

        fetchAlerts();
        const interval = setInterval(fetchAlerts, 10000);
        return () => {
            clearInterval(interval);
            previousAlertIds.current.clear();
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [user]);

    const handleAction = async (id: string, status: string) => {
        try {
            await apiClient.patch(`/authorizations/${id}/status`, { status });
            toast({ title: status === 'APPROVED' ? "Alerta Aprobada" : "Alerta Rechazada", duration: 3000 });
        } catch (error) {
            console.error("Error updating alert:", error);
            toast({ variant: "destructive", title: "Error", description: "No se pudo actualizar la alerta." });
        }
    };

    return null;
}
