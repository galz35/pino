import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { MapPinned, Users, CheckCircle, History, Loader2, ScrollText } from "lucide-react";
import { useParams, useNavigate } from "react-router-dom";
import { useState, useEffect, useMemo } from "react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useToast } from "@/hooks/use-toast";
import { format, isSameDay } from "date-fns";
import { es } from "date-fns/locale";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import apiClient from '@/services/api-client';

interface Client { id: string; name: string; address: string; zoneId: string; }
interface Zone { id: string; name: string; visitDay: string; }
interface VisitLog { clientId: string; date: string; status: string; }

export default function VendorDashboardPage() {
    const [storeName, setStoreName] = useState('');
    const [loading, setLoading] = useState(true);
    const [clients, setClients] = useState<Client[]>([]);
    const [zones, setZones] = useState<Record<string, Zone>>({});
    const [visitLogs, setVisitLogs] = useState<VisitLog[]>([]);
    const [isVisitDialogOpen, setIsVisitDialogOpen] = useState(false);
    const [selectedClient, setSelectedClient] = useState<Client | null>(null);
    const [visitNotes, setVisitNotes] = useState('');
    const [isSavingVisit, setIsSavingVisit] = useState(false);

    const { storeId } = useParams<{ storeId: string }>();
    const navigate = useNavigate();
    const { toast } = useToast();

    const todayDayName = format(new Date(), 'eeee', { locale: es });
    const capitalizedToday = todayDayName.charAt(0).toUpperCase() + todayDayName.slice(1);

    useEffect(() => {
        if (!storeId) return;
        const fetchData = async () => {
            try {
                const [storeRes, zonesRes, clientsRes, logsRes] = await Promise.all([
                    apiClient.get(`/stores/${storeId}`),
                    apiClient.get(`/store-zones?storeId=${storeId}`),
                    apiClient.get(`/clients?storeId=${storeId}`),
                    apiClient.get(`/visit-logs?storeId=${storeId}&days=7`),
                ]);
                setStoreName(storeRes.data?.name || 'Tienda');
                const zoneMap: Record<string, Zone> = {};
                (zonesRes.data || []).forEach((z: any) => { zoneMap[z.id] = z; });
                setZones(zoneMap);
                setClients(clientsRes.data || []);
                setVisitLogs(logsRes.data || []);
            } catch { setStoreName('Tienda'); }
            finally { setLoading(false); }
        };
        fetchData();
    }, [storeId]);

    const getVisitStatus = (clientId: string, date: Date) => visitLogs.find(log => log.clientId === clientId && isSameDay(new Date(log.date), date));

    const todayVisits = useMemo(() => clients.filter(client => {
        const zone = zones[client.zoneId];
        if (!zone) return false;
        return zone.visitDay === capitalizedToday && !getVisitStatus(client.id, new Date());
    }), [clients, zones, visitLogs, capitalizedToday]);

    const pendingVisits = useMemo(() => clients.filter(client => {
        const zone = zones[client.zoneId];
        if (!zone || zone.visitDay === 'Ninguno' || zone.visitDay === capitalizedToday) return false;
        return !visitLogs.some(log => log.clientId === client.id);
    }), [clients, zones, visitLogs, capitalizedToday]);

    const handleMarkVisited = async () => {
        if (!selectedClient) return;
        setIsSavingVisit(true);
        try {
            await apiClient.post('/visit-logs', { clientId: selectedClient.id, clientName: selectedClient.name, storeId, status: 'visited_no_order', notes: visitNotes });
            toast({ title: "Visita registrada correctamente" });
            setIsVisitDialogOpen(false); setVisitNotes('');
            const res = await apiClient.get(`/visit-logs?storeId=${storeId}&days=7`);
            setVisitLogs(res.data || []);
        } catch { toast({ title: "Error al registrar visita", variant: "destructive" }); }
        finally { setIsSavingVisit(false); }
    };

    if (loading) return (<div className="flex h-[400px] items-center justify-center"><Loader2 className="h-8 w-8 animate-spin text-primary" /></div>);

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div><h1 className="text-3xl font-bold tracking-tight">Mi Ruta - {storeName}</h1><p className="text-muted-foreground capitalize">Hoy es {format(new Date(), "EEEE d 'de' MMMM", { locale: es })}</p></div>
            </div>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Card><CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Clientes de Hoy</CardTitle><MapPinned className="h-4 w-4 text-muted-foreground" /></CardHeader><CardContent><div className="text-2xl font-bold">{todayVisits.length}</div><p className="text-xs text-muted-foreground">Programados para {capitalizedToday}</p></CardContent></Card>
                <Card><CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Pendientes</CardTitle><Users className="h-4 w-4 text-destructive" /></CardHeader><CardContent><div className="text-2xl font-bold">{pendingVisits.length}</div><p className="text-xs text-muted-foreground">No visitados</p></CardContent></Card>
            </div>
            <div className="grid gap-6 md:grid-cols-2">
                <Card>
                    <CardHeader><CardTitle className="flex items-center gap-2"><CheckCircle className="h-5 w-5 text-green-500" />Visitas para Hoy</CardTitle><CardDescription>Clientes del {capitalizedToday}</CardDescription></CardHeader>
                    <CardContent><div className="space-y-4">
                        {todayVisits.length === 0 ? (<p className="text-sm text-muted-foreground text-center py-4">No hay visitas programadas.</p>) : todayVisits.map(client => (
                            <div key={client.id} className="flex items-center justify-between p-3 border rounded-lg bg-card">
                                <div className="flex-1 min-w-0 mr-4"><p className="font-medium truncate">{client.name}</p><p className="text-xs text-muted-foreground truncate">{client.address}</p></div>
                                <div className="flex gap-2 shrink-0">
                                    <Button size="sm" variant="outline" onClick={() => { setSelectedClient(client); setIsVisitDialogOpen(true); }}>Sin Pedido</Button>
                                    <Button size="sm" onClick={() => navigate(`/store/${storeId}/vendors/quick-sale?clientId=${client.id}`)}>Vender</Button>
                                </div>
                            </div>
                        ))}
                    </div></CardContent>
                </Card>
                <Card>
                    <CardHeader><CardTitle className="flex items-center gap-2"><History className="h-5 w-5 text-orange-500" />Visitas Pendientes</CardTitle><CardDescription>Clientes sin visitar esta semana</CardDescription></CardHeader>
                    <CardContent><div className="space-y-4">
                        {pendingVisits.length === 0 ? (<p className="text-sm text-muted-foreground text-center py-4">¡Buen trabajo!</p>) : pendingVisits.map(client => (
                            <div key={client.id} className="flex items-center justify-between p-3 border rounded-lg bg-destructive/5 border-destructive/20">
                                <div className="flex-1 min-w-0 mr-4"><p className="font-medium truncate">{client.name}</p>
                                    <div className="flex items-center gap-2"><Badge variant="outline" className="text-[10px] h-4">{zones[client.zoneId]?.visitDay}</Badge><p className="text-[10px] text-muted-foreground truncate">{client.address}</p></div>
                                </div>
                                <div className="flex gap-2 shrink-0">
                                    <Button size="sm" variant="outline" onClick={() => { setSelectedClient(client); setIsVisitDialogOpen(true); }}>Visitar</Button>
                                    <Button size="sm" variant="secondary" onClick={() => navigate(`/store/${storeId}/vendors/quick-sale?clientId=${client.id}`)}>Vender</Button>
                                </div>
                            </div>
                        ))}
                    </div></CardContent>
                </Card>
            </div>
            <Dialog open={isVisitDialogOpen} onOpenChange={setIsVisitDialogOpen}>
                <DialogContent>
                    <DialogHeader><DialogTitle>Registrar Visita</DialogTitle><DialogDescription>Registra la visita a <strong>{selectedClient?.name}</strong> sin pedido.</DialogDescription></DialogHeader>
                    <div className="space-y-4 py-4"><div className="space-y-2"><Label htmlFor="notes">Notas (Opcional)</Label><Textarea id="notes" value={visitNotes} onChange={(e) => setVisitNotes(e.target.value)} placeholder="Ej: No se encontraba el dueño..." /></div></div>
                    <DialogFooter>
                        <Button variant="ghost" onClick={() => setIsVisitDialogOpen(false)}>Cancelar</Button>
                        <Button onClick={handleMarkVisited} disabled={isSavingVisit}>{isSavingVisit ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <ScrollText className="mr-2 h-4 w-4" />}Confirmar Visita</Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
