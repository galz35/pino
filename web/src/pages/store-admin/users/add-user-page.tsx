import { useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { 
  UserPlus, 
  ArrowLeft, 
  Eye, 
  EyeOff, 
  Save, 
  Loader2,
  Mail,
  Lock,
  User as UserIcon,
  ShieldAlert
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { toast } from '@/lib/swalert';
import apiClient from '@/services/api-client';

const userFormSchema = z.object({
  name: z.string().min(3, 'El nombre es requerido.'),
  email: z.string().email('Correo electrónico no válido.'),
  password: z.string().min(6, 'La contraseña debe tener al menos 6 caracteres.'),
  role: z.enum(['Cashier', 'Bodeguero', 'Ayudante de Bodega']),
});

export default function AddUserPage() {
  const { storeId } = useParams();
  const navigate = useNavigate();
  const [isSaving, setIsSaving] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  const form = useForm<z.infer<typeof userFormSchema>>({
    resolver: zodResolver(userFormSchema),
    defaultValues: {
      name: '',
      email: '',
      password: '',
      role: 'Cashier',
    },
  });

  async function onSubmit(values: z.infer<typeof userFormSchema>) {
    if (!storeId) return;
    setIsSaving(true);
    
    try {
      await apiClient.post('/auth/register', {
        name: values.name,
        email: values.email,
        password: values.password,
        role: values.role,
        storeIds: [storeId],
      });
      
      toast.success('Usuario Creado', 'El colaborador ha sido agregado al sistema.');
      navigate(`/store/${storeId}/users`);
    } catch (error: any) {
      console.error(error);
      let errorMessage = 'No se pudo crear el usuario.';
      if (error.response?.data?.message === 'El correo ya está registrado') {
          errorMessage = 'El correo electrónico ya está en uso.';
      }
      toast.error('Error', errorMessage);
    } finally {
      setIsSaving(false);
    }
  }

  return (
    <div className="p-6 md:p-8 max-w-4xl mx-auto space-y-8 animate-in fade-in duration-700">
      <div className="flex flex-col gap-2">
        <Link to={`/store/${storeId}/users`} className="flex items-center text-sm font-bold text-slate-400 hover:text-primary transition-colors mb-2 w-fit">
          <ArrowLeft className="h-4 w-4 mr-1" />
          Volver a Usuarios
        </Link>
        <h1 className="text-4xl font-black tracking-tight text-slate-800 flex items-center gap-3 uppercase italic">
          <UserPlus className="h-10 w-10 text-primary" />
          Nuevo Colaborador
        </h1>
        <p className="text-slate-500 font-bold uppercase tracking-[0.3em] text-[10px] underline decoration-primary decoration-4 underline-offset-8">Alta de Personal</p>
      </div>

      <Card className="border-none shadow-[20px_20px_60px_#ccced1,-20px_-20px_60px_#ffffff] bg-[#f0f2f5] rounded-[40px] overflow-hidden">
        <CardHeader className="bg-primary/5 p-8 border-b border-white">
          <CardTitle className="text-2xl font-black text-slate-800 uppercase">Datos del Usuario</CardTitle>
          <CardDescription className="text-slate-500 font-medium">
            Completa la información para asignar acceso a esta sucursal.
          </CardDescription>
        </CardHeader>
        <CardContent className="p-8">
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel className="flex items-center gap-2 text-xs font-black uppercase text-slate-500 tracking-widest ml-2">
                         <UserIcon className="h-4 w-4 text-primary" /> Nombre Completo
                      </FormLabel>
                      <FormControl>
                        <Input 
                          placeholder="Ej. Juan Pérez" 
                          className="h-14 rounded-2xl bg-white border-none shadow-[inset_4px_4px_8px_#ebeced,inset_-4px_-4px_8px_#ffffff] font-bold px-6 focus-visible:ring-primary"
                          {...field} 
                        />
                      </FormControl>
                      <FormMessage className="ml-2 font-bold italic" />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="email"
                  render={({ field }) => (
                    <FormItem>
                       <FormLabel className="flex items-center gap-2 text-xs font-black uppercase text-slate-500 tracking-widest ml-2">
                         <Mail className="h-4 w-4 text-primary" /> Correo Electrónico
                      </FormLabel>
                      <FormControl>
                        <Input 
                          type="email" 
                          placeholder="usuario@tuempresa.com" 
                          className="h-14 rounded-2xl bg-white border-none shadow-[inset_4px_4px_8px_#ebeced,inset_-4px_-4px_8px_#ffffff] font-bold px-6 focus-visible:ring-primary"
                          {...field} 
                        />
                      </FormControl>
                      <FormMessage className="ml-2 font-bold italic" />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="password"
                  render={({ field }) => (
                    <FormItem>
                       <FormLabel className="flex items-center gap-2 text-xs font-black uppercase text-slate-500 tracking-widest ml-2">
                         <Lock className="h-4 w-4 text-primary" /> Contraseña de Acceso
                      </FormLabel>
                      <FormControl>
                        <div className="relative">
                          <Input
                            type={showPassword ? 'text' : 'password'}
                            placeholder="••••••••"
                            className="h-14 rounded-2xl bg-white border-none shadow-[inset_4px_4px_8px_#ebeced,inset_-4px_-4px_8px_#ffffff] font-bold px-6 focus-visible:ring-primary"
                            {...field}
                          />
                          <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            className="absolute right-2 top-1/2 -translate-y-1/2 h-10 w-10 hover:bg-slate-100 rounded-xl transition-colors text-slate-400"
                            onClick={() => setShowPassword(!showPassword)}
                          >
                            {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                          </Button>
                        </div>
                      </FormControl>
                      <FormMessage className="ml-2 font-bold italic" />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="role"
                  render={({ field }) => (
                    <FormItem>
                       <FormLabel className="flex items-center gap-2 text-xs font-black uppercase text-slate-500 tracking-widest ml-2">
                         <ShieldAlert className="h-4 w-4 text-primary" /> Nivel de Privilegios
                      </FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger className="h-14 rounded-2xl bg-white border-none shadow-[inset_4px_4px_8px_#ebeced,inset_-4px_-4px_8px_#ffffff] font-bold px-6 focus:ring-primary">
                            <SelectValue placeholder="Selecciona un rol" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent className="rounded-2xl border-none shadow-xl">
                          <SelectItem value="Cashier" className="font-bold cursor-pointer rounded-xl">CAJERO</SelectItem>
                          <SelectItem value="Bodeguero" className="font-bold cursor-pointer rounded-xl">BODEGUERO</SelectItem>
                          <SelectItem value="Ayudante de Bodega" className="font-bold cursor-pointer rounded-xl">AYUDANTE DE BODEGA</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage className="ml-2 font-bold italic" />
                    </FormItem>
                  )}
                />
              </div>

              <div className="pt-8 flex justify-end">
                <Button
                  type="submit"
                  disabled={isSaving}
                  className="h-14 px-8 rounded-2xl bg-primary hover:bg-primary/90 text-white font-black uppercase tracking-widest shadow-xl shadow-primary/20 transition-all active:scale-95"
                >
                  {isSaving ? (
                    <>
                      <Loader2 className="mr-3 h-5 w-5 animate-spin" />
                      Procesando
                    </>
                  ) : (
                    <>
                      <Save className="mr-3 h-5 w-5" />
                      Confirmar Alta
                    </>
                  )}
                </Button>
              </div>

            </form>
          </Form>
        </CardContent>
      </Card>
    </div>
  );
}
