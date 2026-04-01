import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { Button } from '@/components/ui/button';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { toast } from '@/lib/swalert';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, Plus, Trash2, Edit, Check, X } from 'lucide-react';
import { useEffect, useState } from 'react';
import apiClient from '@/services/api-client';
import { logError } from '@/lib/error-logger';
import { Separator } from '@/components/ui/separator';
import { Skeleton } from '@/components/ui/skeleton';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog';

const departmentFormSchema = z.object({
  name: z.string().min(2, {
    message: 'El nombre debe tener al menos 2 caracteres.',
  }),
});

interface Department {
  id: string;
  name: string;
}

export default function DepartmentsPage() {
  const params = useParams();
  const storeId = params.storeId as string;
  const [isSaving, setIsSaving] = useState(false);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editingName, setEditingName] = useState('');

  const fetchDepartments = async () => {
    try {
      const response = await apiClient.get('/departments', { params: { storeId } });
      setDepartments(response.data.map((d: any) => ({ ...d, name: d.name || d.nombre })));
    } catch (error) {
      logError(error, { location: 'departments-page-fetch' });
      toast.error('Error', 'No se pudieron cargar los departamentos.');
    } finally {
      setLoading(false);
    }
  };

  async function deleteDepartment(id: string) {
    try {
      await apiClient.delete(`/departments/${id}`);
      fetchDepartments(); // Refresh
      toast.success('Departamento Eliminado', 'El departamento ha sido eliminado correctamente.');
    } catch (error) {
      logError(error, {
        location: 'departments-page-delete',
        additionalInfo: { departmentId: id, storeId },
      });
      toast.error('Error', 'No se pudo eliminar el departamento.');
    }
  }

  const handleEditClick = (dept: Department) => {
    setEditingId(dept.id);
    setEditingName(dept.name);
  };

  const handleCancelEdit = () => {
    setEditingId(null);
    setEditingName('');
  };

  const form = useForm<z.infer<typeof departmentFormSchema>>({
    resolver: zodResolver(departmentFormSchema),
    defaultValues: {
      name: '',
    },
  });

  useEffect(() => {
    if (!storeId) return;
    fetchDepartments();
  }, [storeId]);

  async function onSubmit(values: z.infer<typeof departmentFormSchema>) {
    setIsSaving(true);
    if (!storeId) return;
    try {
      await apiClient.post('/departments', {
        name: values.name,
        storeId,
      });
      fetchDepartments(); // Refresh
      toast.success('Departamento Agregado', `"${values.name}" ha sido agregado.`);
      form.reset();
    } catch (error) {
      logError(error, { location: 'departments-page-add', additionalInfo: { values, storeId } });
      toast.error('Error', 'No se pudo agregar el departamento.');
    } finally {
      setIsSaving(false);
    }
  }

  async function handleUpdateDepartment() {
    if (!editingId || !editingName.trim()) return;
    try {
      await apiClient.patch(`/departments/${editingId}`, {
        name: editingName,
      });
      fetchDepartments(); // Refresh
      toast.success('Departamento Actualizado', 'El nombre ha sido actualizado.');
      setEditingId(null);
      setEditingName('');
    } catch (error) {
      logError(error, { location: 'departments-page-update', additionalInfo: { editingId, editingName } });
      toast.error('Error', 'No se pudo actualizar el departamento.');
    }
  }

  return (
    <div>
      <div className="mb-6">
        <Button variant="ghost" asChild>
          <Link to={`/store/${storeId}/products`}>
            <ArrowLeft className="mr-2" />
            Volver a Productos
          </Link>
        </Button>
      </div>
      <div className="flex justify-center">
        <Card className="w-full max-w-md">
          <CardHeader>
            <CardTitle>Departamentos</CardTitle>
            <CardDescription>
              Gestiona los departamentos para organizar tus productos.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem className="flex-grow">
                      <FormLabel>Nombre del Departamento</FormLabel>
                      <FormControl>
                        <Input placeholder="Ej. Bebidas" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <Button
                  type="submit"
                  className="fixed bottom-8 right-8 h-14 w-14 rounded-full shadow-lg z-50 bg-accent text-accent-foreground hover:bg-accent/90"
                  disabled={isSaving}
                >
                  {isSaving ? (
                    <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  ) : (
                    <Plus className="h-6 w-6" />
                  )}
                  <span className="sr-only">Agregar Departamento</span>
                </Button>
              </form>
            </Form>

            <Separator className="my-6" />

            <div>
              <h3 className="text-lg font-medium mb-4">Departamentos Existentes</h3>
              {loading ? (
                <div className="space-y-2">
                  <Skeleton className="h-10 w-full" />
                  <Skeleton className="h-10 w-full" />
                  <Skeleton className="h-10 w-full" />
                </div>
              ) : departments.length > 0 ? (
                <ul className="space-y-2">
                  {departments.map((dept) => (
                    <li key={dept.id} className="flex items-center justify-between p-2 rounded-md border group">
                      {editingId === dept.id ? (
                        <Input
                          value={editingName}
                          onChange={(e) => setEditingName(e.target.value)}
                          className="h-8"
                        />
                      ) : (
                        <span className="text-sm font-medium">{dept.name}</span>
                      )}

                      <div className="flex items-center gap-1">
                        {editingId === dept.id ? (
                          <>
                            <Button variant="ghost" size="icon" onClick={handleUpdateDepartment} className="h-8 w-8">
                              <Check className="h-4 w-4 text-green-600" />
                            </Button>
                            <Button variant="ghost" size="icon" onClick={handleCancelEdit} className="h-8 w-8">
                              <X className="h-4 w-4 text-gray-600" />
                            </Button>
                          </>
                        ) : (
                          <>
                            <Button variant="ghost" size="icon" onClick={() => handleEditClick(dept)} className="h-8 w-8 opacity-0 group-hover:opacity-100 transition-opacity">
                              <Edit className="h-4 w-4" />
                            </Button>
                            <AlertDialog>
                              <AlertDialogTrigger asChild>
                                <Button variant="ghost" size="icon" className="h-8 w-8 opacity-0 group-hover:opacity-100 transition-opacity">
                                  <Trash2 className="h-4 w-4 text-destructive" />
                                </Button>
                              </AlertDialogTrigger>
                              <AlertDialogContent>
                                <AlertDialogHeader>
                                  <AlertDialogTitle>¿Estás seguro?</AlertDialogTitle>
                                  <AlertDialogDescription>
                                    Esta acción no se puede deshacer. Esto eliminará permanentemente el departamento &quot;{dept.name}&quot;.
                                  </AlertDialogDescription>
                                </AlertDialogHeader>
                                <AlertDialogFooter>
                                  <AlertDialogCancel>Cancelar</AlertDialogCancel>
                                  <AlertDialogAction onClick={() => deleteDepartment(dept.id)}>
                                    Eliminar
                                  </AlertDialogAction>
                                </AlertDialogFooter>
                              </AlertDialogContent>
                            </AlertDialog>
                          </>
                        )}
                      </div>
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="text-sm text-muted-foreground text-center">No hay departamentos agregados todavía.</p>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
