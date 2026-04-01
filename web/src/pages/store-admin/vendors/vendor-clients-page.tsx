import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Plus, Search, Phone, MapPin } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import apiClient from '@/services/api-client';

interface Client { id: string; name: string; phone?: string; address: string; vendorId?: string; zoneId?: string; isCreditClient?: boolean; }

export default function VendorClientsPage() {
    const { storeId } = useParams<{ storeId: string }>();
    const navigate = useNavigate();
    const [clients, setClients] = useState<Client[]>([]);
    const [vendors, setVendors] = useState<Record<string, string>>({});
    const [zones, setZones] = useState<Record<string, string>>({});
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        if (!storeId) return;
        const fetchData = async () => {
            try {
                const [vendorsRes, zonesRes, clientsRes] = await Promise.all([
                    apiClient.get(`/users?storeId=${storeId}&role=vendor`),
                    apiClient.get(`/store-zones?storeId=${storeId}`),
                    apiClient.get(`/clients?storeId=${storeId}`),
                ]);
                const vendorMap: Record<string, string> = {};
                (vendorsRes.data || []).forEach((v: any) => { vendorMap[v.id || v.uid] = v.name; });
                setVendors(vendorMap);
                const zoneMap: Record<string, string> = {};
                (zonesRes.data || []).forEach((z: any) => { zoneMap[z.id] = z.name; });
                setZones(zoneMap);
                setClients(clientsRes.data || []);
            } catch { }
            finally { setLoading(false); }
        };
        fetchData();
    }, [storeId]);

    const filteredClients = clients.filter(c => c.name.toLowerCase().includes(searchTerm.toLowerCase()) || c.address.toLowerCase().includes(searchTerm.toLowerCase()));

    return (
        <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div><h1 className="text-3xl font-bold tracking-tight">Gestión de Clientes</h1><p className="text-muted-foreground">Listado de clientes vinculados.</p></div>
                <Button onClick={() => navigate(`/store/${storeId}/vendors/add-client`)}><Plus className="mr-2 h-4 w-4" />Agregar Cliente</Button>
            </div>
            <Card>
                <CardHeader>
                    <div className="flex items-center justify-between"><CardTitle>Listado de Clientes</CardTitle>
                        <div className="relative w-full max-w-sm"><Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" /><Input placeholder="Buscar..." className="pl-8" value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} /></div>
                    </div>
                </CardHeader>
                <CardContent><div className="rounded-md border"><Table>
                    <TableHeader><TableRow><TableHead>Nombre</TableHead><TableHead>Contacto</TableHead><TableHead>Dirección</TableHead><TableHead>Zona</TableHead><TableHead>Vendedor</TableHead><TableHead>Crédito</TableHead></TableRow></TableHeader>
                    <TableBody>
                        {loading ? (Array.from({ length: 5 }).map((_, i) => (<TableRow key={i}><TableCell><Skeleton className="h-4 w-24" /></TableCell><TableCell><Skeleton className="h-4 w-32" /></TableCell><TableCell><Skeleton className="h-4 w-48" /></TableCell><TableCell><Skeleton className="h-4 w-24" /></TableCell><TableCell><Skeleton className="h-4 w-32" /></TableCell><TableCell><Skeleton className="h-4 w-16" /></TableCell></TableRow>)))
                        : filteredClients.length === 0 ? (<TableRow><TableCell colSpan={6} className="h-24 text-center">No se encontraron clientes.</TableCell></TableRow>)
                        : (filteredClients.map((client) => (
                            <TableRow key={client.id}>
                                <TableCell className="font-medium">{client.name}</TableCell>
                                <TableCell><span className="flex items-center gap-1 text-sm"><Phone className="h-3 w-3" /> {client.phone || 'N/A'}</span></TableCell>
                                <TableCell><span className="flex items-center gap-1 text-sm"><MapPin className="h-3 w-3" /> {client.address}</span></TableCell>
                                <TableCell><Badge variant="outline">{client.zoneId ? (zones[client.zoneId] || '...') : 'Sin zona'}</Badge></TableCell>
                                <TableCell><Badge variant="secondary">{client.vendorId ? (vendors[client.vendorId] || '...') : 'No asignado'}</Badge></TableCell>
                                <TableCell>{client.isCreditClient ? (<Badge className="bg-green-600">Habilitado</Badge>) : (<Badge variant="outline">Inactivo</Badge>)}</TableCell>
                            </TableRow>
                        )))}
                    </TableBody>
                </Table></div></CardContent>
            </Card>
        </div>
    );
}
