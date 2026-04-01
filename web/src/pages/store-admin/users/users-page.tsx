import { Button } from "@/components/ui/button";
import { FloatingActionButton } from "@/components/floating-action-button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Users } from "lucide-react";
import { useEffect, useState } from "react";
import apiClient from '@/services/api-client';
import { Skeleton } from "@/components/ui/skeleton";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion';
import { Badge } from "@/components/ui/badge";
import { useParams, Link } from "react-router-dom";
import { toast, alert as swalert } from '@/lib/swalert';

interface User {
  uid: string;
  name: string;
  email: string;
  role: string;
  id?: string;
}

export default function StoreUsersPage() {
  const params = useParams();
  const storeId = params.storeId as string;
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchUsers = async () => {
    try {
      const response = await apiClient.get('/users', { params: { storeId } });
      setUsers(response.data);
      setLoading(false);
    } catch (err) {
      console.error("Error fetching store users:", err);
      setError("No se pudieron cargar los usuarios de la tienda.");
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!storeId) return;
    fetchUsers();
  }, [storeId]);

  const renderContent = () => {
    if (loading) {
      return (
        <div className="space-y-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-12 w-full" />
          ))}
        </div>
      );
    }

    if (error) {
      return (
        <Alert variant="destructive">
          <Users className="h-4 w-4" />
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      );
    }

    if (users.length === 0) {
      return (
        <Alert>
          <Users className="h-4 w-4" />
          <AlertTitle>No hay usuarios</AlertTitle>
          <AlertDescription>
            Aún no has agregado ningún usuario a esta tienda.
          </AlertDescription>
        </Alert>
      );
    }

    return (
      <div className="rounded-md border">
        <Accordion type="single" collapsible className="w-full">
          {users.map((user) => {
            const userId = user.uid || user.id || '';
            return (
              <AccordionItem value={userId} key={userId}>
                <AccordionTrigger className="px-6 py-4 hover:no-underline">
                  <div className="flex items-center justify-between w-full">
                    <span className="font-medium text-left">{user.name}</span>
                    <Badge variant="secondary">
                      {user.role}
                    </Badge>
                  </div>
                </AccordionTrigger>
                <AccordionContent className="px-6 pb-4 bg-muted/50">
                  <div className="flex flex-col gap-4">
                    <p className="text-sm">
                      <strong>Correo:</strong> {user.email}
                    </p>
                    <div className="flex gap-2">
                      <Button variant="outline" size="sm" asChild>
                        <Link to={`/store/${storeId}/users/edit/${userId}`}>
                          Editar
                        </Link>
                      </Button>
                      <Button
                        variant="destructive"
                        size="sm"
                        onClick={async () => {
                          const result = await swalert.confirm(`¿Estás seguro de que deseas eliminar a ${user.name}?`, 'Esta acción no se puede deshacer.');
                          if (result.isConfirmed) {
                            try {
                              await apiClient.delete(`/users/${userId}`);
                              toast.success("Usuario eliminado", "El usuario ha sido removido de la tienda.");
                              fetchUsers();
                            } catch (error) {
                              console.error("Error deleting user:", error);
                              toast.error("Error", "No se pudo eliminar al usuario.");
                            }
                          }
                        }}
                      >
                        Eliminar
                      </Button>
                    </div>
                  </div>
                </AccordionContent>
              </AccordionItem>
            )
          })}
        </Accordion>
      </div>
    )
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Usuarios de la Tienda</h1>
          <p className="text-muted-foreground">
            Gestiona los cajeros, bodegueros y vendedores de tu tienda.
          </p>
        </div>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Lista de Usuarios</CardTitle>
          <CardDescription>
            Administra el acceso de los empleados a esta tienda.
          </CardDescription>
        </CardHeader>
        <CardContent>
          {renderContent()}
        </CardContent>
      </Card>
      <FloatingActionButton href={`/store/${storeId}/users/add`} />
    </div>
  );
}
