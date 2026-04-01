import { useEffect, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { format, parseISO } from 'date-fns';
import { es } from 'date-fns/locale';
import { Loader2 } from 'lucide-react';
import apiClient from '@/services/api-client';

interface Shift {
    id: string;
    opened_by_name?: string;
    opened_at: string;
    closed_at?: string;
    starting_cash: number;
    actual_cash?: number;
    difference?: number;
    status: 'OPEN' | 'CLOSED';
}

export function HistoricalShiftsList({ storeId }: { storeId: string }) {
    const [shifts, setShifts] = useState<Shift[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        async function fetchHistory() {
            if (!storeId) return;
            try {
                const response = await apiClient.get(`/cash-shifts`, {
                    params: { storeId, status: 'CLOSED' }
                });
                setShifts(response.data);
            } catch (error) {
                console.error("Error fetching history:", error);
            } finally {
                setLoading(false);
            }
        }
        fetchHistory();
    }, [storeId]);

    if (loading) return <div className="flex justify-center p-8"><Loader2 className="animate-spin text-primary h-8 w-8" /></div>;

    return (
        <Card className="shadow-lg border-none bg-white/50 backdrop-blur-sm">
            <CardHeader>
                <CardTitle className="text-xl font-black text-slate-800">Historial de Cierres</CardTitle>
            </CardHeader>
            <CardContent>
                <div className="rounded-xl border overflow-hidden">
                    <Table>
                        <TableHeader className="bg-slate-50">
                            <TableRow>
                                <TableHead className="font-bold">Cajero</TableHead>
                                <TableHead className="font-bold">Apertura</TableHead>
                                <TableHead className="font-bold">Cierre</TableHead>
                                <TableHead className="text-right font-bold">Efectivo Final</TableHead>
                                <TableHead className="text-right font-bold">Diferencia</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {shifts.length === 0 ? (
                                <TableRow>
                                    <TableCell colSpan={5} className="text-center text-muted-foreground h-32">
                                        <div className="flex flex-col items-center gap-2">
                                            <p>No hay registros de cierres recientes.</p>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ) : (
                                shifts.map(shift => (
                                    <TableRow key={shift.id} className="hover:bg-slate-50/50 transition-colors">
                                        <TableCell className="font-bold text-slate-700">{shift.opened_by_name || 'Cajero'}</TableCell>
                                        <TableCell className="text-slate-600 text-xs">
                                            {format(parseISO(shift.opened_at), 'dd MMM HH:mm', { locale: es })}
                                        </TableCell>
                                        <TableCell className="text-slate-600 text-xs text-nowrap">
                                            {shift.closed_at ? format(parseISO(shift.closed_at), 'dd MMM HH:mm', { locale: es }) : '-'}
                                        </TableCell>
                                        <TableCell className="text-right font-mono font-bold text-slate-900">
                                            C$ {parseFloat(shift.actual_cash?.toString() || '0').toFixed(2)}
                                        </TableCell>
                                        <TableCell className="text-right">
                                            {shift.difference !== null && shift.difference !== undefined ? (
                                                <Badge variant={Math.abs(shift.difference) < 1 ? "outline" : shift.difference < 0 ? "destructive" : "default"} 
                                                       className={`font-mono ${Math.abs(shift.difference) < 1 ? "text-green-600 border-green-600 bg-green-50" : ""}`}>
                                                    {shift.difference > 0 ? '+' : ''}{parseFloat(shift.difference.toString()).toFixed(2)}
                                                </Badge>
                                            ) : '-'}
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </div>
            </CardContent>
        </Card>
    );
}
