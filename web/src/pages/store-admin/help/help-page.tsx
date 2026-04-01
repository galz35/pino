import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '@/components/ui/accordion';
import { HelpCircle, BookOpen, MessageCircle, Phone } from 'lucide-react';

const faqs = [
    { q: '¿Cómo abrir un turno de caja?', a: 'Ve a "Caja Registradora" y haz clic en "Abrir Turno". Ingresa el monto de apertura y confirma.' },
    { q: '¿Cómo procesar una venta?', a: 'Desde la pantalla de facturación o POS, busca los productos por nombre o código de barra, ajusta cantidades y haz clic en "Cobrar".' },
    { q: '¿Cómo hacer una devolución?', a: 'En la pantalla de facturación, usa el menú "Opciones" y selecciona "Devoluciones". Busca la venta original e indica los productos a devolver.' },
    { q: '¿Cómo cerrar el turno de caja?', a: 'Ve a "Caja Registradora", haz clic en "Cerrar Turno" e ingresa el monto de cierre real para calcular la diferencia.' },
    { q: '¿Cómo agregar un nuevo producto?', a: 'Ve a "Productos", haz clic en el botón verde "+" y llena los campos requeridos: nombre, código de barra, precio y departamento.' },
    { q: '¿Cómo gestionar el inventario?', a: 'En "Inventario > Movimientos" puedes registrar entradas y salidas de producto. Cada movimiento actualiza el stock automáticamente.' },
    { q: '¿Qué es el Despachador?', a: 'Es un módulo para crear "comandas" de productos sin cobrar inmediatamente. Las comandas aparecen en "Pedidos Pendientes" para ser cobradas después.' },
    { q: '¿Cómo funcionan las Autorizaciones?', a: 'Cuando un cajero solicita un permiso especial (como un límite de crédito), la solicitud aparece en tiempo real en la pantalla del administrador.' },
];

export default function HelpPage() {
    return (
        <div className="space-y-6 max-w-3xl mx-auto">
            <div>
                <h1 className="text-3xl font-bold tracking-tight flex items-center gap-2">
                    <HelpCircle className="h-8 w-8 text-primary" />
                    Centro de Ayuda
                </h1>
                <p className="text-muted-foreground mt-1">
                    Encuentra respuestas a las preguntas más comunes sobre el sistema MultiTienda.
                </p>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <BookOpen className="h-5 w-5" />
                        Preguntas Frecuentes
                    </CardTitle>
                    <CardDescription>Haz clic en una pregunta para ver la respuesta.</CardDescription>
                </CardHeader>
                <CardContent>
                    <Accordion type="single" collapsible className="w-full">
                        {faqs.map((faq, i) => (
                            <AccordionItem value={`faq-${i}`} key={i}>
                                <AccordionTrigger className="text-left">{faq.q}</AccordionTrigger>
                                <AccordionContent className="text-muted-foreground">{faq.a}</AccordionContent>
                            </AccordionItem>
                        ))}
                    </Accordion>
                </CardContent>
            </Card>

            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2"><MessageCircle className="h-5 w-5" />Soporte</CardTitle>
                </CardHeader>
                <CardContent>
                    <p className="text-sm text-muted-foreground">
                        Si necesitas ayuda adicional, contacta al administrador del sistema o escribe a soporte técnico.
                    </p>
                </CardContent>
            </Card>
        </div>
    );
}
