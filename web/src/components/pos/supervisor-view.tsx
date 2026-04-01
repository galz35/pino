import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { ArrowLeft, Printer, RefreshCw } from 'lucide-react';
import { format } from 'date-fns';
import { es } from 'date-fns/locale';

interface SupervisorViewProps {
    shift: any;
    cashSales: number;
    cardSales: number;
    onBack: () => void;
}

export function SupervisorView({ shift, cashSales, cardSales, onBack }: SupervisorViewProps) {
    const totalSales = cashSales + cardSales;
    const currentTotal = (shift.initialAmount || 0) + cashSales;

    return (
        <div className="space-y-6 max-w-4xl mx-auto">
            <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                    <Button variant="outline" size="icon" onClick={onBack}>
                        <ArrowLeft className="h-4 w-4" />
                    </Button>
                    <div>
                        <h1 className="text-2xl font-bold">Monitor de Caja: {shift.cashierName}</h1>
                        <p className="text-muted-foreground text-sm">
                            Iniciado: {shift.openingTimestamp ? format(shift.openingTimestamp.toDate(), 'PP p', { locale: es }) : '-'}
                        </p>
                    </div>
                </div>
                <Badge variant="outline" className="text-green-600 bg-green-50 border-green-200 px-4 py-1 text-sm">
                    Activa
                </Badge>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Card>
                    <CardHeader className="pb-2">
                        <CardTitle className="text-sm font-medium text-muted-foreground">Fondo Inicial</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">C$ {shift.initialAmount?.toFixed(2)}</div>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="pb-2">
                        <CardTitle className="text-sm font-medium text-muted-foreground">Ventas Totales (Est.)</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-blue-600">C$ {totalSales.toFixed(2)}</div>
                        <p className="text-xs text-muted-foreground">Efectivo: {cashSales.toFixed(2)} | Tarjeta: {cardSales.toFixed(2)}</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="pb-2">
                        <CardTitle className="text-sm font-medium text-muted-foreground">Total en Caja (Est.)</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-green-600">C$ {currentTotal.toFixed(2)}</div>
                        <p className="text-xs text-muted-foreground">Fondo + Ventas Efectivo</p>
                    </CardContent>
                </Card>
            </div>

            <Card className="bg-slate-50 border-slate-200">
                <CardHeader>
                    <CardTitle className="text-base">Acciones de Supervisor</CardTitle>
                    <CardDescription>
                        Como administrador, puedes ver los detalles pero no cerrar la caja de otro usuario.
                    </CardDescription>
                </CardHeader>
                <CardContent className="flex gap-4">
                    <Button variant="outline" onClick={() => window.print()}>
                        <Printer className="mr-2 h-4 w-4" />
                        Imprimir Reporte X (Lectura)
                    </Button>
                    {/* Placeholder for future actions like 'Auditoria' */}
                </CardContent>
            </Card>
        </div>
    );
}
