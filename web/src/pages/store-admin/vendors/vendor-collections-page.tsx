import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Input } from '@/components/ui/input';
import { useToast } from '@/hooks/use-toast';
import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { HandCoins, Info, Loader2 } from 'lucide-react';
import { useAuth } from '@/contexts/auth-context';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import apiClient from '@/services/api-client';

interface Account { id: string; clientName: string; pendingAmount: number; }

export default function VendorCollectionsPage() {
    const { storeId } = useParams<{ storeId: string }>();
    const { user } = useAuth();
    const { toast } = useToast();

    const [accounts, setAccounts] = useState<Account[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedAccount, setSelectedAccount] = useState<Account | null>(null);
    const [paymentAmount, setPaymentAmount] = useState<string>('');
    const [isProcessing, setIsProcessing] = useState(false);
    const [isDialogOpen, setIsDialogOpen] = useState(false);

    const fetchAccounts = async () => {
        try { const res = await apiClient.get(`/accounts-receivable?storeId=${storeId}&pending=true`); setAccounts(res.data || []); }
        catch { toast({ variant: 'destructive', title: 'Error', description: 'No se pudieron cargar las cuentas.' }); }
        finally { setLoading(false); }
    };
    useEffect(() => { if (storeId) fetchAccounts(); }, [storeId]);

    const handleCollect = (account: Account) => { setSelectedAccount(account); setPaymentAmount(account.pendingAmount.toString()); setIsDialogOpen(true); };

    const processPayment = async () => {
        if (!selectedAccount || !user || !paymentAmount) return;
        const amount = parseFloat(paymentAmount);
        if (isNaN(amount) || amount <= 0 || amount > selectedAccount.pendingAmount) { toast({ variant: 'destructive', title: 'Monto inválido' }); return; }
        setIsProcessing(true);
        try {
            await apiClient.post(`/accounts-receivable/${selectedAccount.id}/payments`, { amount, vendorId: user.id, vendorName: user.name });
            toast({ title: 'Pago Registrado', description: `Abono de C$ ${amount.toFixed(2)} para ${selectedAccount.clientName}.` });
            setIsDialogOpen(false); setSelectedAccount(null); setPaymentAmount(''); fetchAccounts();
        } catch { toast({ variant: 'destructive', title: 'Error al pagar' }); }
        finally { setIsProcessing(false); }
    };

    return (
        <div>
            <div className="mb-6"><h1 className="text-2xl font-bold tracking-tight">Cobranza en Ruta</h1><p className="text-muted-foreground">Visualiza saldos pendientes y registra pagos.</p></div>
            <Card>
                <CardHeader><CardTitle>Cuentas por Cobrar</CardTitle><CardDescription>Clientes con saldos pendientes.</CardDescription></CardHeader>
                <CardContent>
                    {loading ? (<div className="text-center py-8"><Loader2 className="animate-spin mx-auto" /></div>)
                    : accounts.length === 0 ? (<Alert><Info className="h-4 w-4" /><AlertTitle>Todo al día</AlertTitle><AlertDescription>No hay cuentas pendientes.</AlertDescription></Alert>)
                    : (<Table>
                        <TableHeader><TableRow><TableHead>Cliente</TableHead><TableHead className="text-right">Saldo Pendiente</TableHead><TableHead className="text-center">Acción</TableHead></TableRow></TableHeader>
                        <TableBody>{accounts.map(acc => (
                            <TableRow key={acc.id}><TableCell className="font-medium">{acc.clientName}</TableCell><TableCell className="text-right font-mono">C$ {acc.pendingAmount.toFixed(2)}</TableCell>
                                <TableCell className="text-center"><Button size="sm" onClick={() => handleCollect(acc)}><HandCoins className="mr-2 h-4 w-4" />Registrar Pago</Button></TableCell></TableRow>
                        ))}</TableBody>
                    </Table>)}
                </CardContent>
            </Card>
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
                <DialogContent>
                    <DialogHeader><DialogTitle>Pago de {selectedAccount?.clientName}</DialogTitle><DialogDescription>Saldo: C$ {selectedAccount?.pendingAmount.toFixed(2)}</DialogDescription></DialogHeader>
                    <div className="py-4"><Label>Monto a Pagar</Label><Input type="number" value={paymentAmount} onChange={(e) => setPaymentAmount(e.target.value)} /></div>
                    <DialogFooter><Button variant="ghost" onClick={() => setIsDialogOpen(false)}>Cancelar</Button><Button onClick={processPayment} disabled={isProcessing}>{isProcessing && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}Confirmar Pago</Button></DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
