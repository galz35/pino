import { useEffect, useState, useMemo } from 'react';
import { Skeleton } from '@/components/ui/skeleton';
import {
  startOfDay,
  endOfDay,
  startOfMonth,
  endOfMonth,
  startOfYear,
  endOfYear,
  subDays,
  subMonths,
  eachMonthOfInterval,
  format,
  isToday,
  parseISO
} from 'date-fns';
import { es } from 'date-fns/locale';
import { ActiveRegistersOverview } from './active-cash-registers';
import { SalesChart } from './sales-chart';
import { StatsCards } from './stats-cards';
import { Award, Package, Truck } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import apiClient from '@/services/api-client';

interface Sale {
  total: number;
  createdAt: string; // ISO String from NestJS
  shiftId: string;
}

interface Delivery {
  id: string;
  total: number;
  status: 'PENDING' | 'DELIVERED' | 'FAILED';
  salesManagerName: string;
  createdAt: string;
  updatedAt?: string;
}

interface StoreAdminDashboardMetricsProps {
  storeId: string;
}

interface StoreSettings {
  enableSalesManagerMode?: boolean;
}

export function StoreAdminDashboardMetrics({ storeId }: StoreAdminDashboardMetricsProps) {
  const [salesData, setSalesData] = useState<Sale[] | null>(null);
  const [deliveryData, setDeliveryData] = useState<Delivery[] | null>(null);
  const [settings, setSettings] = useState<StoreSettings>({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!storeId) return;

    const fetchData = async () => {
      setLoading(true);
      try {
        const [salesRes, deliveriesRes, storeRes] = await Promise.all([
          apiClient.get(`/sales?storeId=${storeId}`),
          apiClient.get(`/orders/pending?storeId=${storeId}`),
          apiClient.get(`/stores/${storeId}`)
        ]);

        setSalesData(salesRes.data);
        setDeliveryData(deliveriesRes.data);
        if (storeRes.data.settings) {
          setSettings(storeRes.data.settings);
        }
      } catch (error) {
        console.error("Error fetching dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, [storeId]);

  const stats = useMemo(() => {
    if (!deliveryData) {
      return { dailyDeliveries: 0, pendingDeliveries: 0, ordersToday: 0, bestSalesManager: 'N/A' };
    }

    const dailyDeliveriesCount = deliveryData.filter(d => 
        d.status === 'DELIVERED' && d.updatedAt && isToday(parseISO(d.updatedAt))
    ).length;
    
    const pendingDeliveriesCount = deliveryData.filter(d => d.status === 'PENDING').length;
    const ordersTodayCount = deliveryData.filter(d => isToday(parseISO(d.createdAt))).length;

    const salesByManager = new Map<string, number>();
    const thisMonthStart = startOfMonth(new Date());

    deliveryData
      .filter(d => parseISO(d.createdAt) >= thisMonthStart)
      .forEach(d => {
        salesByManager.set(d.salesManagerName, (salesByManager.get(d.salesManagerName) || 0) + d.total);
      });

    let bestManager = 'N/A';
    let maxSales = 0;
    salesByManager.forEach((sales, name) => {
      if (sales > maxSales) {
        maxSales = sales;
        bestManager = name;
      }
    });

    return {
      dailyDeliveries: dailyDeliveriesCount,
      pendingDeliveries: pendingDeliveriesCount,
      ordersToday: ordersTodayCount,
      bestSalesManager: bestManager
    };
  }, [deliveryData]);

  if (loading || !salesData) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-[250px] w-full" />
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <Skeleton key={i} className="h-[150px] w-full" />
          ))}
        </div>
      </div>
    );
  }

  const now = new Date();
  const todayStart = startOfDay(now);
  const yesterdayStart = startOfDay(subDays(now, 1));
  const yesterdayEnd = endOfDay(subDays(now, 1));
  const thisMonthStart = startOfMonth(now);
  const lastMonthStart = startOfMonth(subMonths(now, 1));
  const lastMonthEnd = endOfMonth(subMonths(now, 1));
  const thisYearStart = startOfYear(now);

  const dailySales = salesData.filter(s => parseISO(s.createdAt) >= todayStart).reduce((sum, s) => sum + s.total, 0);
  const yesterdaySales = salesData.filter(s => {
    const saleDate = parseISO(s.createdAt);
    return saleDate >= yesterdayStart && saleDate <= yesterdayEnd;
  }).reduce((sum, s) => sum + s.total, 0);

  const monthlySales = salesData.filter(s => parseISO(s.createdAt) >= thisMonthStart).reduce((sum, s) => sum + s.total, 0);
  const lastMonthSales = salesData.filter(s => {
    const saleDate = parseISO(s.createdAt);
    return saleDate >= lastMonthStart && saleDate <= lastMonthEnd;
  }).reduce((sum, s) => sum + s.total, 0);

  const annualSales = salesData.filter(s => parseISO(s.createdAt) >= thisYearStart).reduce((sum, s) => sum + s.total, 0);
  
  const thisMonthSalesCount = salesData.filter(s => parseISO(s.createdAt) >= thisMonthStart).length;
  const avgInvoice = thisMonthSalesCount > 0 ? monthlySales / thisMonthSalesCount : 0;

  const lastMonthSalesCount = salesData.filter(s => {
    const saleDate = parseISO(s.createdAt);
    return saleDate >= lastMonthStart && saleDate <= lastMonthEnd;
  }).length;
  const lastMonthAvgInvoice = lastMonthSalesCount > 0 ? lastMonthSales / lastMonthSalesCount : 0;

  const months = eachMonthOfInterval({ start: thisYearStart, end: endOfYear(now) });
  const annualSalesChartData = months.map(month => {
    const monthStart = startOfMonth(month);
    const monthEnd = endOfMonth(month);
    const total = salesData
      .filter(s => {
        const saleDate = parseISO(s.createdAt);
        return saleDate >= monthStart && saleDate <= monthEnd;
      })
      .reduce((sum, s) => sum + s.total, 0);
    return { month: format(month, 'MMM', { locale: es }), sales: total };
  });

  return (
    <div className="space-y-6">
      <ActiveRegistersOverview storeId={storeId} />
      <SalesChart data={annualSalesChartData} />
      <StatsCards
        dailySales={dailySales}
        yesterdaySales={yesterdaySales}
        monthlySales={monthlySales}
        lastMonthSales={lastMonthSales}
        avgInvoice={avgInvoice}
        lastMonthAvgInvoice={lastMonthAvgInvoice}
        annualSales={annualSales}
        lastYearSales={0}
      />
      {settings.enableSalesManagerMode && (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Entregas del Día</CardTitle>
              <Truck className="h-4 w-4 text-green-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.dailyDeliveries}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Pedidos Pendientes</CardTitle>
              <Package className="h-4 w-4 text-yellow-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.pendingDeliveries}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Pedidos Levantados Hoy</CardTitle>
              <Package className="h-4 w-4 text-blue-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{stats.ordersToday}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
              <CardTitle className="text-sm font-medium">Mejor Gestor (Mes)</CardTitle>
              <Award className="h-4 w-4 text-purple-500" />
            </CardHeader>
            <CardContent>
              <div className="text-xl font-bold truncate">{stats.bestSalesManager}</div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
}
