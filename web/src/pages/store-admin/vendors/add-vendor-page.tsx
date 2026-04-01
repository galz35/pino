import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useToast } from '@/hooks/use-toast';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useState } from 'react';
import { ArrowLeft, Eye, EyeOff, Save, Loader2 } from 'lucide-react';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import apiClient from '@/services/api-client';

const userFormSchema = z.object({
    name: z.string().min(3, 'El nombre debe tener al menos 3 caracteres.'),
    email: z.string().email('Correo electrónico inválido.'),
    password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres.'),
    role: z.enum(['Vendedor Ambulante', 'Gestor de Ventas', 'Rutero']),
});

export default function AddVendorPage() {
    const { toast } = useToast();
    const navigate = useNavigate();
    const { storeId } = useParams<{ storeId: string }>();
    const [isSaving, setIsSaving] = useState(false);
    const [showPassword, setShowPassword] = useState(false);

    const form = useForm<z.infer<typeof userFormSchema>>({ resolver: zodResolver(userFormSchema), defaultValues: { name: '', email: '', password: '', role: 'Vendedor Ambulante' } });

    async function onSubmit(values: z.infer<typeof userFormSchema>) {
        setIsSaving(true);
        try {
            await apiClient.post('/users', { ...values, storeId });
            toast({ title: 'Vendedor Creado', description: 'Creado exitosamente.' });
            navigate(`/store/${storeId}/vendors`);
        } catch (error: any) {
            toast({ variant: 'destructive', title: 'Error', description: error?.response?.data?.message || 'No se pudo crear.' });
        } finally { setIsSaving(false); }
    }

    return (
        <div>
            <div className="mb-6"><Button variant="ghost" asChild><Link to={`/store/${storeId}/vendors`}><ArrowLeft className="mr-2" />Volver a Vendedores</Link></Button></div>
            <div className="flex justify-center">
                <Card className="w-full max-w-2xl">
                    <CardHeader><CardTitle>Agregar Nuevo Personal de Ruta</CardTitle><CardDescription>Crea un nuevo usuario para ventas en calle.</CardDescription></CardHeader>
                    <CardContent>
                        <Form {...form}><form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                            <FormField control={form.control} name="name" render={({ field }) => (<FormItem><FormLabel>Nombre Completo</FormLabel><FormControl><Input placeholder="John Doe" {...field} /></FormControl><FormMessage /></FormItem>)} />
                            <FormField control={form.control} name="email" render={({ field }) => (<FormItem><FormLabel>Correo Electrónico</FormLabel><FormControl><Input type="email" placeholder="vendedor@ejemplo.com" {...field} /></FormControl><FormMessage /></FormItem>)} />
                            <FormField control={form.control} name="password" render={({ field }) => (
                                <FormItem><FormLabel>Contraseña</FormLabel><FormControl>
                                    <div className="relative"><Input type={showPassword ? 'text' : 'password'} placeholder="••••••••" {...field} />
                                        <Button type="button" variant="ghost" size="icon" className="absolute inset-y-0 right-0 h-full px-3 py-2 hover:bg-transparent" onClick={() => setShowPassword(!showPassword)}>
                                            {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                        </Button>
                                    </div>
                                </FormControl><FormMessage /></FormItem>
                            )} />
                            <FormField control={form.control} name="role" render={({ field }) => (
                                <FormItem><FormLabel>Rol</FormLabel>
                                    <Select onValueChange={field.onChange} defaultValue={field.value}><FormControl><SelectTrigger><SelectValue /></SelectTrigger></FormControl>
                                        <SelectContent><SelectItem value="Vendedor Ambulante">Vendedor Ambulante</SelectItem><SelectItem value="Gestor de Ventas">Gestor de Ventas</SelectItem><SelectItem value="Rutero">Rutero</SelectItem></SelectContent>
                                    </Select><FormMessage /></FormItem>
                            )} />
                            <Button type="submit" className="fixed bottom-8 right-8 h-14 w-14 rounded-full shadow-lg z-50 bg-accent text-accent-foreground hover:bg-accent/90" disabled={isSaving}>
                                {isSaving ? <Loader2 className="h-5 w-5 animate-spin" /> : <Save className="h-6 w-6" />}<span className="sr-only">Guardar</span>
                            </Button>
                        </form></Form>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
