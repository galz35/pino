import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { AlertCircle, AlertTriangle, CheckCircle, Users } from 'lucide-react';
import { differenceInDays, parseISO } from 'date-fns';
import apiClient from '@/services/api-client';

interface LicenseStats {
  active: number;
  expiringSoon: number;
  expired: number;
}

interface UserStats {
  total: number;
}

export function MasterAdminDashboardMetrics() {
  const [licenseStats, setLicenseStats] = useState<LicenseStats | null>(null);
  const [userStats, setUserStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [usersRes, storesRes] = await Promise.all([
          apiClient.get('/users'),
          apiClient.get('/stores')
        ]);

        // Calculate User stats
        setUserStats({ total: usersRes.data.length });

        // Calculate License stats
        let active = 0;
        let expiringSoon = 0;
        let expired = 0;

        storesRes.data.forEach((store: any) => {
          // If we have a license object in settings or as a separate property
          const license = store.license || store.settings?.license;
          if (!license || !license.expiryDate) {
            return;
          }

          const expiryDate = parseISO(license.expiryDate);
          const today = new Date();
          const daysUntilExpiry = differenceInDays(expiryDate, today);

          if (daysUntilExpiry < 0) {
            expired++;
          } else if (daysUntilExpiry <= 30) {
            expiringSoon++;
          } else {
            active++;
          }
        });

        setLicenseStats({ active, expiringSoon, expired });
      } catch (error) {
        console.error("Error fetching master admin dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return (
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <Card key={i}>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <Skeleton className="h-5 w-32" />
              <Skeleton className="h-6 w-6 rounded-full" />
            </CardHeader>
            <CardContent>
              <Skeleton className="h-8 w-16" />
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Tiendas Activas</CardTitle>
          <CheckCircle className="h-4 w-4 text-green-500" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{licenseStats?.active ?? 0}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Licencias por Vencer</CardTitle>
          <AlertTriangle className="h-4 w-4 text-yellow-500" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{licenseStats?.expiringSoon ?? 0}</div>
        </CardContent>
      </Card>
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Licencias Vencidas</CardTitle>
          <AlertCircle className="h-4 w-4 text-red-500" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{licenseStats?.expired ?? 0}</div>
        </CardContent>
      </Card>
       <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Total de Usuarios</CardTitle>
          <Users className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">{userStats?.total ?? 0}</div>
        </CardContent>
      </Card>
    </div>
  );
}
