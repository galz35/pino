import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

export default function MasterHelpPage() {
    return (
        <div>
            <div className="mb-6"><h1 className="text-2xl font-bold tracking-tight">Centro de Ayuda</h1><p className="text-muted-foreground">Consulta el manual de usuario para resolver tus dudas.</p></div>
            <Card>
                <CardHeader><CardTitle>Manual del Master-Admin</CardTitle><CardDescription>Guía rápida sobre las funciones principales.</CardDescription></CardHeader>
                <CardContent>
                    <Accordion type="single" collapsible className="w-full">
                        <AccordionItem value="item-1"><AccordionTrigger>Gestión de Tiendas</AccordionTrigger>
                            <AccordionContent><p className="mb-2">La sección de <strong>Tiendas</strong> te permite ver y administrar todas las sucursales registradas.</p>
                                <ul className="list-disc space-y-1 pl-5"><li><strong>Agregar una tienda:</strong> Usa el botón flotante (+) para acceder al formulario.</li><li><strong>Ver detalles:</strong> Haz clic en cualquier tienda para desplegar sus detalles.</li><li><strong>Editar una tienda:</strong> Modifica la información desde la lista.</li></ul>
                            </AccordionContent>
                        </AccordionItem>
                        <AccordionItem value="item-2"><AccordionTrigger>Gestión de Usuarios</AccordionTrigger>
                            <AccordionContent><p className="mb-2">Crea y administra los accesos al sistema. Roles principales:</p>
                                <ul className="list-disc space-y-1 pl-5">
                                    <li><strong>Master-Admin:</strong> Acceso total a todas las funciones.</li>
                                    <li><strong>Administrador de Tienda:</strong> Acceso restringido a una tienda específica.</li>
                                    <li><strong>Gestor de Ventas (Preventa):</strong> Rol móvil para levantar pedidos en calle.</li>
                                    <li><strong>Rutero (Entrega):</strong> Rol móvil para entregar pedidos.</li>
                                    <li><strong>Bodeguero:</strong> Acceso exclusivo a gestión de inventario.</li>
                                    <li><strong>Crear un usuario:</strong> Usa el botón (+) y completa el formulario.</li>
                                    <li><strong>Editar un usuario:</strong> Haz clic y presiona "Editar Usuario".</li>
                                </ul>
                            </AccordionContent>
                        </AccordionItem>
                        <AccordionItem value="item-3"><AccordionTrigger>Gestión de Licencias</AccordionTrigger>
                            <AccordionContent><p className="mb-2">Una tienda necesita licencia activa para operar.</p>
                                <ul className="list-disc space-y-1 pl-5">
                                    <li><strong>Agregar licencia:</strong> Si aparece "Sin Licencia", haz clic en "Agregar Licencia".</li>
                                    <li><strong>Tipos:</strong> Mensuales, anuales o fijas.</li>
                                    <li><strong>Estados:</strong> "Activa", "Pronto a expirar" (30 días) o "Expirada".</li>
                                </ul>
                            </AccordionContent>
                        </AccordionItem>
                        <AccordionItem value="item-4"><AccordionTrigger>Monitor del Sistema</AccordionTrigger>
                            <AccordionContent><p>Consola en tiempo real que registra errores. Te permite supervisar la salud del sistema y diagnosticar problemas rápidamente.</p></AccordionContent>
                        </AccordionItem>
                    </Accordion>
                </CardContent>
            </Card>
        </div>
    );
}
