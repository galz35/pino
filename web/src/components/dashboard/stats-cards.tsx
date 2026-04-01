

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { DollarSign, Rocket, Lightbulb, TrendingUp } from 'lucide-react';
import { format, subDays, subMonths, subYears } from 'date-fns';
import { es } from 'date-fns/locale';

interface StatsCardsProps {
  dailySales: number;
  yesterdaySales: number;
  monthlySales: number;
  lastMonthSales: number;
  avgInvoice: number;
  lastMonthAvgInvoice: number;
  annualSales: number;
  lastYearSales: number;
}

function StatCard({
  title,
  icon: Icon,
  currentValue,
  previousValue,
  currentPeriod,
  previousPeriod,
  currency = 'C$',
}: {
  title: string;
  icon: React.ElementType;
  currentValue: number;
  previousValue: number;
  currentPeriod: string;
  previousPeriod: string;
  currency?: string;
}) {
  const percentageChange =
    previousValue > 0
      ? ((currentValue - previousValue) / previousValue) * 100
      : currentValue > 0
      ? 100
      : 0;

  const getChangeColor = () => {
    if (percentageChange > 0) return 'text-green-500';
    if (percentageChange < 0) return 'text-red-500';
    return 'text-gray-500';
  };

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="flex items-baseline gap-2">
           <p className={`text-lg font-bold ${getChangeColor()}`}>
            {percentageChange.toFixed(2)}%
          </p>
        </div>
        
        <div className="mt-2 space-y-1 text-sm">
            <div className="flex justify-between">
                <p className="font-bold">{`${currency} ${currentValue.toLocaleString('es-NI', {minimumFractionDigits: 2, maximumFractionDigits: 2})}`}</p>
                <p className="text-muted-foreground">{currentPeriod}</p>
            </div>
             <div className="flex justify-between">
                <p>{`${currency} ${previousValue.toLocaleString('es-NI', {minimumFractionDigits: 2, maximumFractionDigits: 2})}`}</p>
                <p className="text-muted-foreground">{previousPeriod}</p>
            </div>
        </div>
      </CardContent>
    </Card>
  );
}

export function StatsCards({
  dailySales,
  yesterdaySales,
  monthlySales,
  lastMonthSales,
  avgInvoice,
  lastMonthAvgInvoice,
  annualSales,
  lastYearSales,
}: StatsCardsProps) {
  const today = new Date();
  const yesterday = subDays(today, 1);
  const thisMonth = subMonths(today, 0);
  const lastMonth = subMonths(today, 1);
  const thisYear = subYears(today, 0);
  const lastYear = subYears(today, 1);

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      <StatCard
        title="Ventas Del Día"
        icon={DollarSign}
        currentValue={dailySales}
        previousValue={yesterdaySales}
        currentPeriod={format(today, 'd MMM, yyyy', { locale: es })}
        previousPeriod={format(yesterday, 'd MMM, yyyy', { locale: es })}
      />
      <StatCard
        title="Ventas Del Mes"
        icon={Rocket}
        currentValue={monthlySales}
        previousValue={lastMonthSales}
        currentPeriod={format(thisMonth, 'MMMM yyyy', { locale: es })}
        previousPeriod={format(lastMonth, 'MMMM yyyy', { locale: es })}
      />
      <StatCard
        title="Factura Promedio Del Mes"
        icon={Lightbulb}
        currentValue={avgInvoice}
        previousValue={lastMonthAvgInvoice}
        currentPeriod={format(thisMonth, 'MMMM yyyy', { locale: es })}
        previousPeriod={format(lastMonth, 'MMMM yyyy', { locale: es })}
      />
      <StatCard
        title="Ventas Anuales"
        icon={TrendingUp}
        currentValue={annualSales}
        previousValue={lastYearSales}
        currentPeriod={format(thisYear, 'yyyy', { locale: es })}
        previousPeriod={format(lastYear, 'yyyy', { locale: es })}
      />
    </div>
  );
}
