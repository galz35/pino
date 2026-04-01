import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { AlertCircle, AlertTriangle, CheckCircle, Users } from 'lucide-react';
import { differenceInDays, parseISO } from 'date-fns';
import apiClient from '@/services/api-client';

interface LicenseStats { active: number; expiringSoon: number; expired: number; }

export default function MasterDashboardPage() {
    const [licenseStats, setLicenseStats] = useState<LicenseStats | null>(null);
    const [totalUsers, setTotalUsers] = useState(0);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchData = async () => {
            try {
                const [usersRes, storesRes] = await Promise.all([apiClient.get('/users'), apiClient.get('/stores')]);
                setTotalUsers((usersRes.data || []).length);
                let active = 0, expiringSoon = 0, expired = 0;
                (storesRes.data || []).forEach((store: any) => {
                    if (!store.license?.expiryDate) return;
                    const days = differenceInDays(parseISO(store.license.expiryDate), new Date());
                    if (days < 0) expired++; else if (days <= 30) expiringSoon++; else active++;
                });
                setLicenseStats({ active, expiringSoon, expired });
            } catch { } finally { setLoading(false); }
        };
        fetchData();
        const interval = setInterval(fetchData, 60000);
        return () => clearInterval(interval);
    }, []);

    if (loading) return (
        <div className="space-y-6"><h1 className="text-2xl font-bold tracking-tight">Panel de Master-Admin</h1>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">{Array.from({ length: 4 }).map((_, i) => (
                <Card key={i}><CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><Skeleton className="h-5 w-32" /><Skeleton className="h-6 w-6 rounded-full" /></CardHeader><CardContent><Skeleton className="h-8 w-16" /></CardContent></Card>
            ))}</div>
        </div>
    );

    return (
        <div>
            <h1 className="text-2xl font-bold tracking-tight mb-4">Panel de Master-Admin</h1>
            <p className="text-muted-foreground mb-6">Métricas importantes para la gestión de todas las tiendas.</p>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
                <Card><CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Tiendas Activas</CardTitle><CheckCircle className="h-4 w-4 text-green-500" /></CardHeader><CardContent><div className="text-2xl font-bold">{licenseStats?.active ?? 0}</div></CardContent></Card>
                <Card><CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Licencias por Vencer</CardTitle><AlertTriangle className="h-4 w-4 text-yellow-500" /></CardHeader><CardContent><div className="text-2xl font-bold">{licenseStats?.expiringSoon ?? 0}</div></CardContent></Card>
                <Card><CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Licencias Vencidas</CardTitle><AlertCircle className="h-4 w-4 text-red-500" /></CardHeader><CardContent><div className="text-2xl font-bold">{licenseStats?.expired ?? 0}</div></CardContent></Card>
                <Card><CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2"><CardTitle className="text-sm font-medium">Total de Usuarios</CardTitle><Users className="h-4 w-4 text-muted-foreground" /></CardHeader><CardContent><div className="text-2xl font-bold">{totalUsers}</div></CardContent></Card>
            </div>
        </div>
    );
}
