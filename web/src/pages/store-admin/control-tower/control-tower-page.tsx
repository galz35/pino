import { useParams } from 'react-router-dom';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Activity, ShieldAlert, ShoppingBag, Truck, Lock, History, ClipboardCheck } from 'lucide-react';
import { useEffect, useState, useMemo } from 'react';
import apiClient from '@/services/api-client';
import { Skeleton } from '@/components/ui/skeleton';
import { Badge } from '@/components/ui/badge';
import { ResponsiveContainer, AreaChart, Area, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';

export default function ControlTowerPage() {
    const { storeId } = useParams<{ storeId: string }>();
    const [stats, setStats] = useState({ pendingOrders: 0, pendingDeliveries: 0, pendingAuths: 0, openShifts: 0 });
    const [loading, setLoading] = useState(true);

    // Mock data for the chart - In a real scenario, this would come from an endpoint
    const chartData = useMemo(() => [
        { hour: '08:00', orders: 12 },
        { hour: '09:00', orders: 18 },
        { hour: '10:00', orders: 45 },
        { hour: '11:00', orders: 30 },
        { hour: '12:00', orders: 25 },
        { hour: '13:00', orders: 40 },
        { hour: '14:00', orders: 55 },
        { hour: '15:00', orders: 32 },
    ], []);

    useEffect(() => {
        if (!storeId) return;
        const fetchStats = async () => {
            try {
                const [orders, deliveries, auths, shifts] = await Promise.all([
                    apiClient.get('/pending-orders', { params: { storeId } }).catch(() => ({ data: [] })),
                    apiClient.get('/pending-deliveries', { params: { storeId } }).catch(() => ({ data: [] })),
                    apiClient.get('/authorizations', { params: { storeId, status: 'PENDING' } }).catch(() => ({ data: [] })),
                    apiClient.get('/cash-shifts', { params: { storeId, status: 'open' } }).catch(() => ({ data: [] })),
                ]);
                setStats({
                    pendingOrders: orders.data?.length || 0,
                    pendingDeliveries: deliveries.data?.length || 0,
                    pendingAuths: auths.data?.length || 0,
                    openShifts: shifts.data?.length || 0,
                });
            } catch { }
            setLoading(false);
        };
        fetchStats();
        const interval = setInterval(fetchStats, 15000);
        return () => clearInterval(interval);
    }, [storeId]);

    const cards = [
        { title: 'Ventas Pendientes', value: stats.pendingOrders, icon: ShoppingBag, color: 'text-indigo-600', bg: 'bg-indigo-50 dark:bg-indigo-950/30' },
        { title: 'Rutas en Tránsito', value: stats.pendingDeliveries, icon: Truck, color: 'text-amber-600', bg: 'bg-amber-50 dark:bg-amber-950/30' },
        { title: 'Autorizaciones Solicitadas', value: stats.pendingAuths, icon: Lock, color: 'text-rose-600', bg: 'bg-rose-50 dark:bg-rose-950/30' },
        { title: 'Turnos de Caja Activos', value: stats.openShifts, icon: Activity, color: 'text-emerald-600', bg: 'bg-emerald-50 dark:bg-emerald-950/30' },
    ];

    return (
        <div className="space-y-6 animate-in fade-in duration-500">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 className="text-3xl font-bold tracking-tight bg-gradient-to-r from-gray-900 to-gray-500 dark:from-white dark:to-gray-400 bg-clip-text text-transparent">
                        Torre de Control Logística
                    </h1>
                    <p className="text-muted-foreground">
                        Visibilidad operativa 360° para la sucursal activa.
                    </p>
                </div>
                <Badge variant="outline" className="w-fit h-fit py-1 px-3 border-emerald-500/50 text-emerald-600 dark:text-emerald-400 bg-emerald-50/50 dark:bg-emerald-500/10 backdrop-blur-sm">
                    <span className="relative flex h-2 w-2 mr-2">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                    </span>
                    Live Sync Activo
                </Badge>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                {cards.map((card) => (
                    <Card key={card.title} className="overflow-hidden border-none shadow-md hover:shadow-xl transition-all duration-300 group">
                        <CardContent className={`p-6 ${card.bg}`}>
                            {loading ? (
                                <Skeleton className="h-16 w-full" />
                            ) : (
                                <div className="flex items-center justify-between">
                                    <div>
                                        <p className="text-sm font-medium text-muted-foreground uppercase tracking-wider">{card.title}</p>
                                        <p className={`text-3xl font-bold mt-1 ${card.color}`}>{card.value}</p>
                                    </div>
                                    <div className={`p-3 rounded-xl bg-white dark:bg-gray-800 shadow-sm group-hover:scale-110 transition-transform`}>
                                        <card.icon className={`h-6 w-6 ${card.color}`} />
                                    </div>
                                </div>
                            )}
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <Card className="lg:col-span-2 shadow-lg border-none">
                    <CardHeader>
                        <div className="flex items-center justify-between">
                            <div>
                                <CardTitle className="text-lg flex items-center gap-2">
                                    <Activity className="h-5 w-5 text-indigo-500" />
                                    Actividad de Preventa (Hoy)
                                </CardTitle>
                                <CardDescription>Volumen de pedidos sincronizados por hora</CardDescription>
                            </div>
                            <History className="h-4 w-4 text-muted-foreground" />
                        </div>
                    </CardHeader>
                    <CardContent className="h-[300px] pt-4">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={chartData}>
                                <defs>
                                    <linearGradient id="colorOrders" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#4f46e5" stopOpacity={0.3}/>
                                        <stop offset="95%" stopColor="#4f46e5" stopOpacity={0}/>
                                    </linearGradient>
                                </defs>
                                <XAxis dataKey="hour" axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#888'}} />
                                <YAxis axisLine={false} tickLine={false} tick={{fontSize: 12, fill: '#888'}} />
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#eee" />
                                <Tooltip 
                                    contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 10px 15px -3px rgb(0 0 0 / 0.1)' }}
                                />
                                <Area type="monotone" dataKey="orders" stroke="#4f46e5" strokeWidth={3} fillOpacity={1} fill="url(#colorOrders)" />
                            </AreaChart>
                        </ResponsiveContainer>
                    </CardContent>
                </Card>

                <Card className="shadow-lg border-none bg-gradient-to-br from-gray-900 to-gray-800 text-white">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2 text-white">
                            <ShieldAlert className="h-5 w-5 text-rose-500" />
                            Alertas de Sistema
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {stats.pendingAuths > 0 ? (
                            <div className="p-4 rounded-xl bg-white/10 backdrop-blur-md border border-white/10">
                                <p className="text-rose-400 font-bold">¡Atención!</p>
                                <p className="text-sm">Hay {stats.pendingAuths} autorizaciones de precio bloqueando pedidos.</p>
                            </div>
                        ) : (
                            <div className="text-center py-12 opacity-50">
                                <ClipboardCheck className="h-12 w-12 mx-auto mb-4" />
                                <p className="text-sm italic">Operación despejada.</p>
                            </div>
                        )}
                        
                        <div className="mt-8 pt-8 border-t border-white/10">
                            <h4 className="text-xs font-bold uppercase tracking-widest text-indigo-400 mb-4">Estado de Sincronización</h4>
                            <div className="space-y-3">
                                <div className="flex justify-between text-xs">
                                    <span>PDA Sincronizadas</span>
                                    <span className="text-emerald-400">9/10</span>
                                </div>
                                <div className="w-full bg-white/10 rounded-full h-1.5">
                                    <div className="bg-indigo-500 h-1.5 rounded-full" style={{ width: '90%' }}></div>
                                </div>
                                <p className="text-[10px] text-gray-400 italic">Última actualización global: Hace 2 minutos</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
