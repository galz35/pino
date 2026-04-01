
import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Cog, Zap, Layout, Printer, ShieldCheck, DollarSign, Save, Loader2 } from 'lucide-react';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormDescription,
} from '@/components/ui/form';
import {
  RadioGroup,
  RadioGroupItem,
} from '@/components/ui/radio-group';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Switch } from '@/components/ui/switch';
import { useParams } from 'react-router-dom';
import { useEffect, useState, useCallback } from 'react';
import apiClient from '@/services/api-client';
import { toast } from '@/lib/swalert';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';

const settingsSchema = z.object({
  applyVAT: z.boolean(),
  exchangeRate: z.number().min(1),
  billingMode: z.enum(['scan-and-add', 'scan-and-prompt']),
  adminPin: z.string().min(4).max(8),
  enableDispatcherMode: z.boolean(),
  trackByBrand: z.boolean(),
  headerLine1: z.string(),
  headerLine2: z.string(),
  footerLine1: z.string(),
  fontSize: z.number().min(8),
  columns: z.number().min(20),
});

type SettingsFormValues = z.infer<typeof settingsSchema>;

export default function StoreSettingsPage() {
  const params = useParams();
  const storeId = params.storeId as string;
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  const form = useForm<SettingsFormValues>({
    resolver: zodResolver(settingsSchema),
    defaultValues: {
      applyVAT: false,
      exchangeRate: 36.60,
      billingMode: 'scan-and-add',
      adminPin: '0000',
      enableDispatcherMode: false,
      trackByBrand: false,
      headerLine1: 'MULTITIENDA LOS PINOS',
      headerLine2: 'Sucursal Central',
      footerLine1: '¡Gracias por su preferencia!',
      fontSize: 10,
      columns: 36,
    },
  });

  const fetchSettings = useCallback(async () => {
    if (!storeId) return;
    try {
      const response = await apiClient.get(`/stores/${storeId}`);
      if (response.data && response.data.settings) {
        form.reset(response.data.settings);
      }
    } catch (error) {
      console.error("Error fetching settings:", error);
    } finally {
      setLoading(false);
    }
  }, [storeId, form]);

  useEffect(() => {
    fetchSettings();
  }, [fetchSettings]);

  async function onSubmit(values: SettingsFormValues) {
    setIsSaving(true);
    try {
      await apiClient.patch(`/stores/${storeId}/settings`, values);
      toast.success('Configuración Guardada', 'Los ajustes de la tienda se han actualizado con éxito.');
    } catch (error) {
      toast.error('Error', 'No se pudo guardar la configuración.');
    } finally {
      setIsSaving(false);
    }
  }

  if (loading) {
    return (
      <div className="p-8 max-w-4xl mx-auto space-y-8">
        <Skeleton className="h-12 w-1/3 rounded-2xl" />
        <Skeleton className="h-64 w-full rounded-3xl" />
      </div>
    );
  }

  /**
   * Helper to fix TS issues with Control in FormField
   * by explicitly casting the generic Control.
   */
  const control = form.control as any;

  return (
    <div className="p-8 max-w-5xl mx-auto min-h-screen bg-slate-50/30">
      <div className="mb-10">
        <h1 className="text-4xl font-black italic uppercase tracking-tighter text-slate-800 leading-none">Ajustes del Sistema</h1>
        <p className="text-slate-400 font-bold uppercase tracking-widest text-sm mt-3 flex items-center gap-2">
          <Cog className="h-4 w-4 text-blue-500" /> Configuración Global de la Sucursal
        </p>
      </div>

      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
          <Tabs defaultValue="general" className="w-full">
            <TabsList className="bg-white p-1 rounded-2xl shadow-sm border border-slate-100 flex h-auto mb-8">
              <TabsTrigger value="general" className="flex-1 py-3 font-black uppercase text-xs rounded-xl data-[state=active]:bg-blue-600 data-[state=active]:text-white transition-all">
                <Zap className="w-4 h-4 mr-2" /> General
              </TabsTrigger>
              <TabsTrigger value="workflow" className="flex-1 py-3 font-black uppercase text-xs rounded-xl data-[state=active]:bg-blue-600 data-[state=active]:text-white transition-all">
                <Layout className="w-4 h-4 mr-2" /> Flujo
              </TabsTrigger>
              <TabsTrigger value="ticket" className="flex-1 py-3 font-black uppercase text-xs rounded-xl data-[state=active]:bg-blue-600 data-[state=active]:text-white transition-all">
                <Printer className="w-4 h-4 mr-2" /> Ticket
              </TabsTrigger>
              <TabsTrigger value="security" className="flex-1 py-3 font-black uppercase text-xs rounded-xl data-[state=active]:bg-blue-600 data-[state=active]:text-white transition-all">
                <ShieldCheck className="w-4 h-4 mr-2" /> Seguridad
              </TabsTrigger>
            </TabsList>

            {/* GENERAL TAB */}
            <TabsContent value="general" className="mt-0">
              <Card className="rounded-[40px] border-none shadow-2xl bg-white overflow-hidden">
                <CardHeader className="bg-slate-50/50 p-8">
                  <CardTitle className="text-2xl font-black uppercase text-slate-800">Impuestos y Divisas</CardTitle>
                  <CardDescription className="text-slate-400 font-bold uppercase text-xs">Manejo de IVA y Tasa de Cambio</CardDescription>
                </CardHeader>
                <CardContent className="p-8 space-y-6">
                  <FormField
                    control={control}
                    name="applyVAT"
                    render={({ field }) => (
                      <FormItem className="flex items-center justify-between p-6 bg-slate-50 rounded-3xl border-2 border-slate-100 shadow-inner">
                        <div className="space-y-0.5">
                          <FormLabel className="text-lg font-black text-slate-700 uppercase">Aplicar IVA (15%)</FormLabel>
                          <FormDescription className="font-bold text-slate-400">Calcular impuestos en facturación</FormDescription>
                        </div>
                        <FormControl>
                          <Switch checked={!!field.value} onCheckedChange={field.onChange} className="data-[state=checked]:bg-emerald-500 scale-125" />
                        </FormControl>
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={control}
                    name="exchangeRate"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="text-sm font-black text-slate-500 uppercase">Tasa de Cambio Oficial (C$1.00 USD)</FormLabel>
                        <div className="relative">
                          <DollarSign className="absolute left-4 top-1/2 -translate-y-1/2 text-emerald-500 h-6 w-6" />
                          <FormControl>
                            <Input type="number" step="0.01" className="h-16 pl-12 text-2xl font-black font-mono border-2 rounded-2xl bg-white shadow-sm focus:border-blue-500" {...field} />
                          </FormControl>
                        </div>
                      </FormItem>
                    )}
                  />
                </CardContent>
              </Card>
            </TabsContent>

            {/* WORKFLOW TAB */}
            <TabsContent value="workflow" className="mt-0">
              <Card className="rounded-[40px] border-none shadow-2xl bg-white overflow-hidden">
                <CardHeader className="bg-slate-50/50 p-8">
                  <CardTitle className="text-2xl font-black uppercase text-slate-800">Modos de Operación</CardTitle>
                </CardHeader>
                <CardContent className="p-8 space-y-6">
                   <FormField
                    control={control}
                    name="billingMode"
                    render={({ field }) => (
                      <FormItem className="space-y-4">
                        <FormLabel className="text-lg font-black text-slate-700 uppercase">Modo de POS</FormLabel>
                        <FormControl>
                          <RadioGroup
                            onValueChange={field.onChange}
                            defaultValue={field.value}
                            className="grid grid-cols-1 md:grid-cols-2 gap-4"
                          >
                            <FormItem className={cn(
                              "flex items-center space-x-4 space-y-0 border-2 p-6 rounded-3xl transition-all cursor-pointer",
                              field.value === 'scan-and-add' ? "bg-blue-50 border-blue-500 shadow-lg" : "border-slate-100 bg-white"
                            )}>
                              <FormControl><RadioGroupItem value="scan-and-add" /></FormControl>
                              <FormLabel className="font-black text-slate-700 flex flex-col cursor-pointer">
                                <span>MODO DIRECTO</span>
                                <span className="text-[10px] font-bold text-slate-400 mt-1 uppercase">1 Escaneo = 1 Unidad (Supermercado)</span>
                              </FormLabel>
                            </FormItem>
                            <FormItem className={cn(
                              "flex items-center space-x-4 space-y-0 border-2 p-6 rounded-3xl transition-all cursor-pointer",
                              field.value === 'scan-and-prompt' ? "bg-blue-50 border-blue-500 shadow-lg" : "border-slate-100 bg-white"
                            )}>
                              <FormControl><RadioGroupItem value="scan-and-prompt" /></FormControl>
                              <FormLabel className="font-black text-slate-700 flex flex-col cursor-pointer">
                                <span>PREGUNTAR CANTIDAD</span>
                                <span className="text-[10px] font-bold text-slate-400 mt-1 uppercase">Abrir diálogo de teclado numérico</span>
                              </FormLabel>
                            </FormItem>
                          </RadioGroup>
                        </FormControl>
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={control}
                    name="enableDispatcherMode"
                    render={({ field }) => (
                      <FormItem className="flex items-center justify-between p-6 bg-slate-50 rounded-3xl border-2 border-slate-100">
                        <div className="space-y-0.5">
                          <FormLabel className="text-lg font-black text-slate-700 uppercase italic">Modo Despachador</FormLabel>
                          <FormDescription className="font-bold text-slate-400">Separar toma de orden y cobro</FormDescription>
                        </div>
                        <FormControl>
                          <Switch checked={!!field.value} onCheckedChange={field.onChange} className="data-[state=checked]:bg-blue-600 scale-125" />
                        </FormControl>
                      </FormItem>
                    )}
                  />
                </CardContent>
              </Card>
            </TabsContent>

            {/* SECURITY TAB */}
            <TabsContent value="security" className="mt-0">
               <Card className="rounded-[40px] border-none shadow-2xl bg-white overflow-hidden">
                <CardHeader className="bg-slate-50/50 p-8">
                  <CardTitle className="text-2xl font-black uppercase text-slate-800">Protección y Autorización</CardTitle>
                </CardHeader>
                <CardContent className="p-8">
                  <FormField
                    control={control}
                    name="adminPin"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel className="text-sm font-black text-slate-500 uppercase flex items-center gap-2">
                          PIN Maestro de Supervisor <ShieldCheck className="w-4 h-4" />
                        </FormLabel>
                        <FormControl>
                          <Input type="password" maxLength={8} className="h-20 text-4xl font-black font-mono tracking-widest text-center border-4 border-blue-100 rounded-3xl focus:border-blue-600" {...field} />
                        </FormControl>
                        <FormDescription className="text-center font-bold text-slate-400 uppercase text-[10px] mt-4">Requerido para Devoluciones, Notas de Crédito y Descuentos Mayores</FormDescription>
                      </FormItem>
                    )}
                  />
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>

          <Button
            type="submit"
            className="fixed bottom-12 right-12 h-20 w-20 rounded-[30px] shadow-[0_20px_50px_rgba(37,99,235,0.4)] z-50 bg-blue-600 text-white hover:bg-blue-700 transition-all hover:scale-110 active:scale-95 group"
            disabled={isSaving}
          >
            {isSaving ? (
              <Loader2 className="h-10 w-10 animate-spin" />
            ) : (
              <Save className="h-10 w-10 group-hover:rotate-12 transition-transform" />
            )}
          </Button>
        </form>
      </Form>
      
      <div className="mt-8 flex justify-center pb-20">
        <p className="text-[10px] font-black text-slate-300 uppercase tracking-[0.2em] italic">© MultiTienda Engine v2.0 • Security Core Active</p>
      </div>
    </div>
  );
}
