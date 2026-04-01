import apiClient from '@/services/api-client';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage, FormDescription } from '@/components/ui/form';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import { Calendar } from '@/components/ui/calendar';
import { Checkbox } from '@/components/ui/checkbox';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { CalendarIcon, Loader2, Save, MapPin, Users, Route } from 'lucide-react';
import { cn } from '@/lib/utils';
import { format } from 'date-fns';
import { es } from 'date-fns/locale';
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { toast } from '@/lib/swalert';
import { useParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { logError } from '@/lib/error-logger';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Skeleton } from '@/components/ui/skeleton';

const routeFormSchema = z.object({
  vendorId: z.string().min(1, 'Debes seleccionar un vendedor.'),
  date: z.date(),
  clientIds: z.array(z.string()).min(1, 'Tienes que seleccionar al menos un cliente.'),
});

interface Vendor { uid: string; name: string; }
interface Client { id: string; name: string; }

export default function VendorRoutesPage() {
  const params = useParams();
  const storeId = params.storeId as string;
  const [vendors, setVendors] = useState<Vendor[]>([]);
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  const form = useForm<z.infer<typeof routeFormSchema>>({ 
    resolver: zodResolver(routeFormSchema), 
    defaultValues: { 
      date: new Date(), 
      clientIds: [] 
    } 
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [vendorsRes, clientsRes] = await Promise.all([
          apiClient.get(`/users?storeId=${storeId}&role=Vendedor Ambulante`),
          apiClient.get(`/clients?storeId=${storeId}`),
        ]);
        setVendors((vendorsRes.data || []).map((v: any) => ({ uid: v.id || v.uid, name: v.name })));
        setClients((clientsRes.data || []).map((c: any) => ({ id: c.id, name: c.name })));
      } catch (err) { 
        logError(err, { location: 'vendor-routes-fetch', additionalInfo: { storeId } });
        toast.error('Error', 'No se pudieron cargar los datos de vendedores o clientes.');
      } finally { 
        setLoading(false); 
      }
    };
    fetchData();
  }, [storeId]);

  async function onSubmit(values: z.infer<typeof routeFormSchema>) {
    setIsSaving(true);
    try {
      await apiClient.post('/routes', { ...values, storeId, status: 'pending' });
      toast.success('Ruta Creada', 'La ruta ha sido asignada y el vendedor notificado.');
      form.reset({ date: new Date(), clientIds: [] });
    } catch (error) {
      logError(error, { location: 'vendor-routes-submit', additionalInfo: { ...values } });
      toast.error('Error', 'No se pudo crear la ruta.');
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <div className="flex flex-col h-full bg-slate-50/30 p-4 lg:p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-black tracking-tighter text-slate-900 uppercase italic">Gestión de <span className="text-blue-600">Rutas de Venta</span></h1>
        <p className="text-xs font-black uppercase tracking-[0.2em] text-slate-400 mt-1 italic">Planificación y asignación de clientes para vendedores de campo</p>
      </div>

      <div className="flex justify-center flex-grow">
        <Card className="w-full max-w-4xl border-none shadow-xl shadow-slate-200/50 rounded-[3rem] overflow-hidden bg-white">
          <CardHeader className="bg-slate-900 text-white p-8">
            <CardTitle className="text-2xl font-black uppercase tracking-tight italic flex items-center gap-3">
              <Route className="h-7 w-7 text-blue-400" />
              Planificador de <span className="text-blue-400">Rutas Diarias</span>
            </CardTitle>
            <CardDescription className="text-slate-400 font-bold uppercase text-[10px] tracking-widest mt-2">
              Configure la hoja de ruta de los vendedores para optimizar su desempeño.
            </CardDescription>
          </CardHeader>
          <CardContent className="p-8">
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                  <FormField control={form.control} name="vendorId" render={({ field }) => (
                    <FormItem className="space-y-3">
                      <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400 pl-1">Vendedor Ambulante</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger className="h-14 rounded-2xl border-slate-100 bg-slate-50 font-bold uppercase text-xs shadow-sm focus:ring-4 focus:ring-blue-100 transition-all">
                            <SelectValue placeholder="Selecciona un vendedor" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent className="rounded-xl border-slate-100 shadow-2xl font-bold uppercase text-xs">
                          {vendors.map((v) => (<SelectItem key={v.uid} value={v.uid}>{v.name}</SelectItem>))}
                        </SelectContent>
                      </Select>
                      <FormMessage className="text-[10px] font-black uppercase" />
                    </FormItem>
                  )} />
                  
                  <FormField control={form.control} name="date" render={({ field }) => (
                    <FormItem className="flex flex-col space-y-3">
                      <FormLabel className="text-[10px] font-black uppercase tracking-widest text-slate-400 pl-1">Fecha de Despacho</FormLabel>
                      <Popover>
                        <PopoverTrigger asChild>
                          <FormControl>
                            <Button variant={'outline'} className={cn('h-14 rounded-2xl border-slate-100 bg-slate-50 font-bold uppercase text-xs shadow-sm pl-3 text-left focus:ring-4 focus:ring-blue-100 transition-all', !field.value && 'text-muted-foreground')}>
                              {field.value ? format(field.value, 'PPP', { locale: es }) : <span>Selecciona una fecha</span>}
                              <CalendarIcon className="ml-auto h-5 w-5 text-blue-500 opacity-70" />
                            </Button>
                          </FormControl>
                        </PopoverTrigger>
                        <PopoverContent className="w-auto p-0 border-none rounded-2xl shadow-2xl overflow-hidden" align="start">
                          <Calendar mode="single" selected={field.value} onSelect={field.onChange} initialFocus locale={es} />
                        </PopoverContent>
                      </Popover>
                      <FormMessage className="text-[10px] font-black uppercase" />
                    </FormItem>
                  )} />
                </div>

                <FormField control={form.control} name="clientIds" render={() => (
                  <FormItem className="space-y-4">
                    <div className="flex items-center justify-between px-1">
                      <FormLabel className="text-xl font-black uppercase tracking-tight text-slate-800 italic flex items-center gap-2">
                        <Users className="h-5 w-5 text-blue-500" />
                         Lista de Clientes <span className="text-blue-500">( {form.watch('clientIds').length} )</span>
                      </FormLabel>
                      <span className="text-[9px] font-black uppercase tracking-widest text-slate-300">Seleccione los destinos de visita</span>
                    </div>
                    
                    <FormControl>
                      <ScrollArea className="h-[350px] w-full rounded-[2rem] border-2 border-slate-50 bg-slate-50/30 p-6 shadow-inner">
                        {loading ? (
                           <div className="space-y-4">
                             {[...Array(5)].map((_, i) => <Skeleton key={i} className="h-16 w-full rounded-2xl bg-slate-100" />)}
                           </div>
                        ) : (
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {clients.map((client) => (
                              <FormField key={client.id} control={form.control} name="clientIds" render={({ field }) => (
                                <FormItem key={client.id} className="flex flex-row items-center space-x-4 space-y-0 p-4 border rounded-2xl bg-white hover:bg-blue-50 hover:border-blue-200 transition-all cursor-pointer group">
                                  <FormControl>
                                    <Checkbox 
                                      className="h-5 w-5 border-2 rounded-md border-slate-200 group-hover:border-blue-400"
                                      checked={field.value?.includes(client.id)} 
                                      onCheckedChange={(checked) => { 
                                        return checked ? field.onChange([...(field.value || []), client.id]) : field.onChange(field.value?.filter((value) => value !== client.id)); 
                                      }} 
                                    />
                                  </FormControl>
                                  <div className="flex flex-col">
                                    <FormLabel className="font-bold text-slate-700 uppercase text-[11px] tracking-tight group-hover:text-blue-700 transition-colors">{client.name}</FormLabel>
                                    <div className="flex items-center gap-1 mt-1">
                                       <MapPin className="h-3 w-3 text-slate-300" />
                                       <span className="text-[9px] font-black text-slate-300 uppercase tracking-widest leading-none">Geolocalizado</span>
                                    </div>
                                  </div>
                                </FormItem>
                              )}
                            />
                          ))}
                        </div>
                      )}
                      </ScrollArea>
                    </FormControl>
                    <FormMessage className="text-[10px] font-black uppercase text-center" />
                  </FormItem>
                )} />

                <div className="flex justify-end pt-4">
                  <Button 
                    type="submit" 
                    className="h-16 px-12 rounded-3xl bg-blue-600 hover:bg-blue-700 text-white font-black uppercase tracking-[0.2em] italic shadow-2xl shadow-blue-200 transition-all active:scale-95 group relative overflow-hidden" 
                    disabled={isSaving}
                  >
                    <div className="absolute inset-0 bg-white/10 -translate-y-full group-hover:translate-y-0 transition-all duration-300"></div>
                    {isSaving ? (
                      <Loader2 className="h-6 w-6 animate-spin mr-3" />
                    ) : (
                      <Save className="h-6 w-6 mr-3" />
                    )}
                    {isSaving ? 'Guardando...' : 'Generar Hoja de Ruta'}
                  </Button>
                </div>
              </form>
            </Form>
          </CardContent>
        </Card>
      </div>
      
      <div className="md:hidden h-20"></div>
    </div>
  );
}
